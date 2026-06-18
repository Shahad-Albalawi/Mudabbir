<?php

return [
    'api_key' => env('GEMINI_API_KEY', ''),
    'base_url' => env('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com/v1beta'),
    'model' => env('GEMINI_MODEL', 'gemini-2.0-flash'),
    'timeout' => env('GEMINI_TIMEOUT_SECONDS', 30),
    'connect_timeout' => env('GEMINI_CONNECT_TIMEOUT_SECONDS', 10),
    'retries' => env('GEMINI_RETRIES', 2),
    'retry_sleep_ms' => env('GEMINI_RETRY_SLEEP_MS', 250),
    'verify_ssl' => env('GEMINI_VERIFY_SSL', true),
];
