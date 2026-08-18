<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <title>{{ config('app.name') }} — {{ __('passwords.reset_subject') }}</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #1a1a1a;">
    <p>{{ __('passwords.reset_greeting', ['name' => $userName !== '' ? $userName : __('passwords.reset_user')]) }}</p>
    <p>{{ __('passwords.reset_body') }}</p>
    <p style="font-size: 28px; letter-spacing: 6px; font-weight: bold; margin: 24px 0;">
        {{ $code }}
    </p>
    <p style="color: #666; font-size: 14px;">{{ __('passwords.reset_expiry', ['minutes' => config('auth.passwords.users.expire', 60)]) }}</p>
    <p style="color: #666; font-size: 14px;">{{ __('passwords.reset_ignore') }}</p>
</body>
</html>
