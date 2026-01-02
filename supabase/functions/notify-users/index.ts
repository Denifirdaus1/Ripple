// Setup: 
// 1. Create a Firebase Service Account and save as "service-account.json".
// 2. Deploy this function: rules are handled by passing the file.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.1'
import serviceAccount from './service-account.json' with { type: 'json' }

// We need to fetch an access token manually because firebase-admin is not fully compatible with Deno Deploy environment sometimes,
// OR we can use a pure REST approach to avoid heavy dependencies.
// However, 'firebase-admin' via esm.sh works in many Deno contexts now.
// Let's try the JWT approach for Google Auth to be lightweight and safe.
import { JWT } from 'https://deno.land/x/google_deno_integration@v1.1/mod.ts';

console.log("Hello from notify-users!");

Deno.serve(async (req) => {
    try {
        // 1. Init Supabase Client
        const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
        const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
        const supabase = createClient(supabaseUrl, supabaseKey);

        // 2. Query Todos due for notification
        // Logic: notification_sent = false AND start_time is present and passed (or within specific window)
        // For MVP robustness: start_time <= now() AND notification_sent = false
        const now = new Date().toISOString();

        // We fetch todos that are due.
        const { data: todos, error: todoError } = await supabase
            .from('todos')
            .select('id, user_id, title, start_time')
            .eq('notification_sent', false)
            .lte('start_time', now)
            .limit(20); // Process in batches to avoid timeout

        if (todoError) throw todoError;
        if (!todos || todos.length === 0) {
            return new Response(JSON.stringify({ message: 'No todos to notify' }), { headers: { 'Content-Type': 'application/json' } });
        }

        // 3. Authenticate with Firebase (Get Access Token)
        // Using JWT to sign and get token for scope https://www.googleapis.com/auth/firebase.messaging
        const jwtClient = new JWT({
            email: serviceAccount.client_email,
            key: serviceAccount.private_key,
            scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
        });

        const accessToken = await jwtClient.fetchToken();

        // 4. Send Notifications
        const results = [];

        for (const todo of todos) {
            // Get User's FCM Token
            const { data: devices } = await supabase
                .from('user_devices')
                .select('fcm_token')
                .eq('user_id', todo.user_id)
                .eq('is_active', true)
                .limit(1);

            if (devices && devices.length > 0) {
                const token = devices[0].fcm_token;

                // Send via FCM HTTP v1 API
                const fcmUrl = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;

                const response = await fetch(fcmUrl, {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${accessToken}`,
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        message: {
                            token: token,
                            notification: {
                                title: 'Reminder',
                                body: `It's time for: ${todo.title}`,
                            },
                            data: {
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                todo_id: todo.id,
                            }
                        }
                    })
                });

                results.push({ todoId: todo.id, status: response.status });
            }

            // 5. Update Todo Status
            await supabase
                .from('todos')
                .update({ notification_sent: true })
                .eq('id', todo.id);
        }

        return new Response(
            JSON.stringify({ success: true, processed: results.length, details: results }),
            { headers: { "Content-Type": "application/json" } }
        );

    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: { 'Content-Type': 'application/json' } });
    }
});
