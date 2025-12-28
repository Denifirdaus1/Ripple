# Supabase Database Best Practices - Deep Research

**ID:** K_001 | **Domain:** Supabase/Database
**Created:** 2025-12-28 | **Source:** Context7 + Exa MCP Research

---

## Executive Summary

Riset ini mengkompilasi best practices untuk membangun database schema Supabase yang **aman**, **scalable**, dan **production-ready** untuk aplikasi produktivitas Ripple.

---

## 1. 🔐 Row Level Security (RLS) Best Practices

### 1.1 Fundamental Rules

```sql
-- ✅ WAJIB: Enable RLS pada SEMUA tabel di public schema
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

-- ✅ BEST PRACTICE: Explicit null check untuk auth.uid()
-- Ini mencegah silent failures dan memperjelas intent
CREATE POLICY "Users can manage own todos" ON todos
FOR ALL USING (auth.uid() IS NOT NULL AND auth.uid() = user_id);

-- ❌ AVOID: Tanpa null check (bisa silent fail)
-- USING (auth.uid() = user_id)
```

### 1.2 RLS Performance Optimization

```sql
-- ✅ WAJIB: Index pada kolom yang dipakai di RLS policies
CREATE INDEX idx_todos_user_id ON todos USING btree (user_id);
CREATE INDEX idx_notes_user_id ON notes USING btree (user_id);

-- ✅ BEST PRACTICE: Wrap auth.uid() dalam SELECT untuk performance
CREATE POLICY "rls_optimized" ON todos
TO authenticated
USING ((SELECT auth.uid()) = user_id);  -- Note: subquery wrapper
```

### 1.3 Security Definer Functions

Untuk complex queries yang melibatkan JOIN antar tabel dengan RLS:

```sql
-- Buat function di schema terpisah (bukan public!) untuk keamanan
CREATE SCHEMA IF NOT EXISTS private;

CREATE OR REPLACE FUNCTION private.user_has_role(required_role TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM roles 
        WHERE user_id = (SELECT auth.uid()) 
        AND role = required_role
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Gunakan di policy
CREATE POLICY "Admin access" ON admin_data
FOR ALL USING (private.user_has_role('admin'));
```

> ⚠️ **WARNING**: Security definer functions bypass RLS. Gunakan dengan sangat hati-hati dan SELALU tempatkan di schema non-public.

### 1.4 Separate Policies per Operation

```sql
-- ✅ BEST PRACTICE: Policies terpisah per operation untuk granular control
CREATE POLICY "todos_select" ON todos FOR SELECT 
TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "todos_insert" ON todos FOR INSERT 
TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "todos_update" ON todos FOR UPDATE 
TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "todos_delete" ON todos FOR DELETE 
TO authenticated USING (auth.uid() = user_id);
```

---

## 2. 🔒 Security Hardening Checklist

### 2.1 Authentication Security

```sql
-- ✅ MFA Enforcement untuk sensitive operations
-- Check AAL (Authentication Assurance Level) di policies
CREATE POLICY "Sensitive operations require MFA" ON sensitive_table
FOR ALL USING (
    auth.uid() IS NOT NULL 
    AND (SELECT auth.jwt() ->> 'aal') = 'aal2'  -- Requires MFA
);
```

### 2.2 Network Security

| Setting | Recommendation | Location |
|---------|---------------|----------|
| SSL Enforcement | ✅ Enable | Dashboard > Settings > SSL |
| Network Restrictions | ✅ Configure allowed IPs | Dashboard > Settings > Network |
| Connection Pooling | ✅ Enable for production | Dashboard > Settings > Database |

### 2.3 Secret Management dengan Vault

```sql
-- Simpan API keys dan secrets di Vault, BUKAN di environment variables
SELECT vault.create_secret(
    'my_api_key',           -- key
    'sk-xxx-secret-value',  -- value  
    'OpenAI API Key'        -- description
);

-- Akses secrets dengan aman
SELECT decrypted_secret 
FROM vault.decrypted_secrets 
WHERE name = 'my_api_key';
```

### 2.4 Production Password Policy

> 🚨 **CRITICAL**: 
> - JANGAN pernah share `postgres` password dengan tim
> - Semua perubahan harus via version-controlled migrations
> - Gunakan CI/CD (GitHub Actions) dengan approval workflows

---

## 3. ⏰ Cron Jobs & Scheduled Functions

### 3.1 pg_cron Setup

```sql
-- Enable extension (sudah enabled by default di Supabase)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule function setiap menit
SELECT cron.schedule(
    'generate-recurring-todos',
    '0 0 * * *',  -- Setiap hari jam 00:00
    'SELECT generate_daily_recurring_todos()'
);

-- Schedule Edge Function via HTTP
SELECT cron.schedule(
    'invoke-daily-summary',
    '0 8 * * *',  -- Setiap hari jam 8 pagi
    $$
    SELECT net.http_post(
        url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'project_url') 
               || '/functions/v1/daily-summary',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' || 
                (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'service_role_key')
        ),
        body := '{}'::jsonb
    ) AS request_id;
    $$
);
```

### 3.2 Debugging pg_cron Jobs

```sql
-- Check if scheduler is running
SELECT pid, application_name, state 
FROM pg_stat_activity 
WHERE application_name ILIKE 'pg_cron scheduler';

-- View job history
SELECT * FROM cron.job_run_details 
ORDER BY start_time DESC 
LIMIT 20;

-- View scheduled jobs
SELECT * FROM cron.job;
```

### 3.3 Logging untuk Cron Jobs

```sql
CREATE OR REPLACE FUNCTION my_scheduled_function()
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    RAISE LOG 'Cron job started at: %', NOW();
    
    -- Your logic here
    
    RAISE LOG 'Cron job completed at: %', NOW();
EXCEPTION
    WHEN OTHERS THEN
        RAISE LOG 'Cron job failed: %', SQLERRM;
        RAISE;
END;
$$;
```

---

## 4. 🔄 Recurring Events Pattern

### 4.1 Hybrid Strategy (Recommended untuk Ripple)

**Pendekatan:** Template + Lazy Generation

```sql
-- Parent todo = template
-- recurrence_rule menyimpan aturan recurrence
-- Instance di-generate on-demand atau via cron job

CREATE TABLE todos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    
    -- ... other fields ...
    
    -- Recurrence
    recurrence_rule JSONB,
    -- Format: {
    --   "days": ["mon", "wed", "fri"],
    --   "time_overrides": {"sat": {"start": "11:00", "end": "12:00"}}
    -- }
    
    parent_todo_id UUID REFERENCES todos(id),  -- NULL if this is template
    scheduled_date DATE,  -- The specific date for this instance
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index untuk query recurring templates
CREATE INDEX idx_todos_recurrence ON todos(user_id) 
WHERE recurrence_rule IS NOT NULL AND parent_todo_id IS NULL;
```

### 4.2 Generation Function

```sql
CREATE OR REPLACE FUNCTION generate_recurring_todos_for_date(target_date DATE)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    todo_record RECORD;
    day_name TEXT;
    time_override JSONB;
BEGIN
    day_name := LOWER(TO_CHAR(target_date, 'Dy'));  -- mon, tue, wed, etc.
    
    FOR todo_record IN 
        SELECT * FROM todos 
        WHERE recurrence_rule IS NOT NULL 
        AND parent_todo_id IS NULL
        AND recurrence_rule->'days' ? day_name
    LOOP
        -- Check if instance already exists
        IF NOT EXISTS (
            SELECT 1 FROM todos 
            WHERE parent_todo_id = todo_record.id 
            AND scheduled_date = target_date
        ) THEN
            -- Get time override if exists
            time_override := todo_record.recurrence_rule->'time_overrides'->day_name;
            
            -- Insert new instance
            INSERT INTO todos (
                user_id, title, description, priority,
                is_scheduled, start_time, end_time, scheduled_date,
                focus_enabled, focus_duration_minutes,
                parent_todo_id
            ) VALUES (
                todo_record.user_id,
                todo_record.title,
                todo_record.description,
                todo_record.priority,
                TRUE,
                CASE WHEN time_override IS NOT NULL 
                    THEN target_date + (time_override->>'start')::TIME
                    ELSE target_date + todo_record.start_time::TIME
                END,
                CASE WHEN time_override IS NOT NULL 
                    THEN target_date + (time_override->>'end')::TIME
                    ELSE target_date + todo_record.end_time::TIME
                END,
                target_date,
                todo_record.focus_enabled,
                todo_record.focus_duration_minutes,
                todo_record.id
            );
        END IF;
    END LOOP;
END;
$$;

-- Schedule untuk generate 7 hari ke depan setiap malam
SELECT cron.schedule(
    'generate-weekly-todos',
    '0 0 * * *',  -- Midnight every day
    $$SELECT generate_recurring_todos_for_date(CURRENT_DATE + i) 
      FROM generate_series(0, 7) AS i$$
);
```

---

## 5. 📊 Focus Session Tracking (untuk "Ripple Wrapped")

```sql
CREATE TABLE focus_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    todo_id UUID REFERENCES todos(id) ON DELETE CASCADE NOT NULL,
    
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    duration_minutes INT GENERATED ALWAYS AS (
        EXTRACT(EPOCH FROM (ended_at - started_at)) / 60
    ) STORED,
    
    session_type TEXT CHECK (session_type IN ('work', 'break')) DEFAULT 'work',
    was_completed BOOLEAN DEFAULT FALSE,
    was_interrupted BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes untuk analytics
CREATE INDEX idx_focus_sessions_user_month 
ON focus_sessions(user_id, started_at);

CREATE INDEX idx_focus_sessions_analytics 
ON focus_sessions(user_id, started_at, was_completed);

-- RLS
ALTER TABLE focus_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own sessions" ON focus_sessions
FOR ALL USING (auth.uid() = user_id);
```

### Analytics View untuk Wrapped

```sql
CREATE OR REPLACE VIEW user_monthly_stats AS
SELECT 
    user_id,
    DATE_TRUNC('month', started_at) AS month,
    COUNT(*) AS total_sessions,
    SUM(duration_minutes) AS total_minutes,
    COUNT(*) FILTER (WHERE was_completed) AS completed_sessions,
    ROUND(
        COUNT(*) FILTER (WHERE was_completed)::NUMERIC / 
        NULLIF(COUNT(*), 0) * 100, 2
    ) AS completion_rate
FROM focus_sessions
WHERE ended_at IS NOT NULL
GROUP BY user_id, DATE_TRUNC('month', started_at);
```

---

## 6. 🗄️ Storage Security

```sql
-- Bucket policies untuk user files
CREATE POLICY "Users can manage own attachments"
ON storage.objects FOR ALL
USING (
    bucket_id = 'note-attachments' 
    AND (auth.uid())::TEXT = (storage.foldername(name))[1]
)
WITH CHECK (
    bucket_id = 'note-attachments' 
    AND (auth.uid())::TEXT = (storage.foldername(name))[1]
);

-- Folder structure: note-attachments/{user_id}/{note_id}/{filename}
```

---

## 7. ✅ Production Checklist

### Pre-Production

- [ ] Enable RLS on ALL public tables
- [ ] Add indexes on columns used in RLS policies
- [ ] Configure SSL enforcement
- [ ] Set up Network Restrictions
- [ ] Store secrets in Vault, not env vars
- [ ] Run Security Advisor dari Dashboard
- [ ] Run Performance Advisor dari Dashboard

### Migration Workflow

- [ ] All changes via version-controlled migrations
- [ ] Use GitHub Actions with approval workflows
- [ ] Never share postgres password
- [ ] Test migrations on staging first
- [ ] Enable "Require status checks" di GitHub

### Monitoring

- [ ] Set up pg_cron job monitoring
- [ ] Configure error alerting
- [ ] Review query performance regularly

---

## 8. Supabase Integrations untuk Ripple

| Integration | Purpose | Needed? |
|-------------|---------|---------|
| **pg_cron** | Generate recurring todos, cleanup old data | ✅ Yes |
| **pg_net** | Call Edge Functions from cron jobs | ✅ Yes |
| **Vault** | Store API keys securely | ✅ Yes |
| **Realtime** | Live updates untuk Focus Mode | ✅ Yes |
| **Storage** | Note attachments, Milestone banners | ✅ Yes |
| **Edge Functions** | Notifications, AI (future), complex logic | ✅ Yes |

---

## References

1. Supabase RLS Documentation - https://supabase.com/docs/guides/auth/row-level-security
2. Supabase Security Hardening Blog - https://supabase.com/blog/hardening-supabase
3. Supabase Production Checklist - https://supabase.com/docs/guides/deployment/going-into-prod
4. pg_cron Documentation - https://supabase.com/docs/guides/cron/quickstart
5. Supabase Vault - https://supabase.com/docs/guides/database/vault
