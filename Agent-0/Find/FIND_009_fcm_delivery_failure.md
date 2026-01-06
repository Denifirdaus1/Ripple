# Notification Tidak Terkirim ke Device

**ID:** FIND_009 | **Status:** 🔍 Investigasi | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-06 | **Update:** 2026-01-06

## 📝 Deskripsi Masalah

Notifikasi todo reminder tiba-tiba tidak berfungsi meskipun sebelumnya bekerja dengan baik. Cron job (`send-notification`) sukses dieksekusi (HTTP 200) dan todos ter-update (`notification_sent = true`), namun notifikasi tidak sampai ke device Android.

### Evidence:
1. **Edge Function Logs:**
   ```
   Processing notification for user: 78ae40ad-af51-44a4-be5c-d40c4a8816d2
   POST | 200 | https://.../functions/v1/send-notification
   ```
2. **Database State:**
   - Todos: `notification_sent = true` (marked as sent)
   - FCM Token: Active & recently updated (2026-01-06 02:08)
3. **Flutter Logs:**
   - FCM token sync: ✅ Success
   - Todo save: ✅ Success
   - No notification received on device

## 🕵️ Analisis & Hipotesis

### Potential Root Causes:

| # | Hipotesis | Kemungkinan | Status |
|---|-----------|-------------|--------|
| 1 | FCM token expired/invalid (auto-deactivated) | Medium | ⬜ Perlu Cek |
| 2 | Android Battery Optimization killing app | High | ⬜ Perlu Cek |
| 3 | FCM v1 API message format issue | Low | ⬜ Perlu Cek |
| 4 | JWT token generation failure (silent) | Medium | ⬜ Perlu Cek |
| 5 | Notification channel misconfiguration | Low | ⬜ Perlu Cek |
| 6 | Edge function tidak log FCM response detail | High | ⬜ Perlu Fix |

### Key Observations:
1. **Logs Incomplete**: Edge function hanya log "Processing notification for user" tapi tidak log hasil FCM response (success/error detail)
2. **200 OK ≠ Delivered**: FCM HTTP v1 API mengembalikan 200 OK jika request valid, tapi itu BUKAN jaminan notification terkirim ke device
3. **Silent Failure**: Jika token invalid, FCM akan return error dalam response body, tapi code hanya log jika `status !== 200`

## 💡 Ide Solusi

### Quick Fixes:
1. **Add Detailed Logging**: Log FCM response body untuk setiap request (success & error)
2. **Check FCM Console**: Buka Firebase Console > Cloud Messaging untuk lihat delivery stats
3. **Test Manual**: Kirim manual FCM test message via Firebase Console ke token yang sama

### Code Improvements:
```typescript
// Di send-notification edge function
const result = await response.json();
console.log(`FCM Response for ${device.fcm_token.substring(0, 10)}:`, JSON.stringify(result));

if (response.status === 200) {
  console.log(`✅ FCM Sent successfully: ${result.name}`);
} else {
  console.error(`❌ FCM Error:`, result.error);
}
```

### Android Device Checks:
- [ ] Pastikan Battery Optimization disabled untuk app Ripple
- [ ] Cek Settings > Apps > Ripple > Notifications
- [ ] Test dengan app di foreground vs background

## 📊 Data Reference

### User Devices Table:
```
ID: 199d3139-... | is_active: true | updated: 2026-01-06 02:08
Token: cxYKh7lkQ3yLEf2F5BnjTQ:APA91bH...
```

### Recent Scheduled Todos:
```
title: "duha" | start_time: 2026-01-06 02:10+00 | notification_sent: true
title: "solat duha" | start_time: 2026-01-06 02:00+00 | notification_sent: true
```

## 🔗 Terkait
- Topic: TOPIC_001 (Todo & Notification)
- Plan: PLAN_020 (Notification Deep Linking)
- Finding: FIND_007 (Notification Timing Issues - Resolved)
