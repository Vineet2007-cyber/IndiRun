# IndiRun — Supabase Setup & Configuration Guide (M1)

This document provides setup instructions for configuring the Supabase backend for IndiRun V1 Authentication & Profile.

---

## 1. Supabase Project Setup

1. Create a project at [supabase.com](https://supabase.com).
2. Note your **Project URL** (`https://<project-ref>.supabase.co`) and **Anon / Public Key** from **Project Settings → API**.
3. **NEVER** expose the `service_role` key in the Flutter application or commit it to source control.

---

## 2. Apply Database Migration

Open the **SQL Editor** in your Supabase Dashboard (or use the Supabase CLI) and execute the SQL file:
`supabase/migrations/20260926000000_create_profiles.sql`

This migration creates:
* **`public.profiles`** table (`id`, `display_name`, `avatar_url`, `city`, `club_tag`, `language`, `units`, `created_at`, `updated_at`).
* **Row Level Security (RLS)** policies ensuring users can only read, insert, update, and delete their own profile row (`auth.uid() = id`).
* **`handle_new_user()` trigger** that automatically provisions a profile row whenever a new user signs up via Google OAuth.
* **`avatars` storage bucket** with isolated per-user storage folder policies.

---

## 3. Google OAuth Configuration

1. In the **Google Cloud Console**:
   * Create an OAuth 2.0 Client ID (Web Application).
   * Authorized Redirect URI: `https://<your-project-ref>.supabase.co/auth/v1/callback`.
2. In the **Supabase Dashboard**:
   * Go to **Authentication → Providers → Google**.
   * Toggle **Enable Google provider**.
   * Paste the **Client ID** and **Client Secret**.
   * Under **Authentication → URL Configuration**:
     * Add `indirun://login-callback` to **Redirect URLs**.

---

## 4. Running the Flutter App with Supabase Credentials

For local development and release builds, pass credentials at compile-time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

To build a release or debug APK:

```bash
flutter build apk --debug \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

### CI / Headless Test Graceful Fallback
When `--dart-define` parameters are omitted (e.g. in GitHub Actions CI or headless test suites), the app automatically uses `InMemoryAuthRepository` and `InMemoryProfileRepository`. This guarantees that unit tests, widget tests, and builds run deterministically without requiring live network access or committed credentials.

---

## 5. Account Deletion Architecture

Under Supabase's default security model, the client SDK can delete the user's `public.profiles` row via RLS, but deleting the `auth.users` row requires either:
1. A Postgres RPC function running with `SECURITY DEFINER`:
   ```sql
   create or replace function public.delete_user_account()
   returns void
   language plpgsql
   security definer
   as $$
   begin
     delete from auth.users where id = auth.uid();
   end;
   $$;
   ```
2. Or a secure Supabase Edge Function triggered by the client.

The `SupabaseAuthRepository.deleteAccount()` method is designed to delete the application profile and call `delete_user_account`, ensuring compliance with DPDP Act / Google Play requirements without exposing privileged service keys to the client.
