<?php

return [
    'api_key' => env('OPENAI_API_KEY', ''),
    'base_url' => env('OPENAI_BASE_URL', 'https://api.openai.com/v1'),
    'model' => env('OPENAI_MODEL', 'gpt-4o-mini'),
    'timeout' => env('OPENAI_TIMEOUT_SECONDS', 30),
    'connect_timeout' => env('OPENAI_CONNECT_TIMEOUT_SECONDS', 10),
    'retries' => env('OPENAI_RETRIES', 2),
    'retry_sleep_ms' => env('OPENAI_RETRY_SLEEP_MS', 250),
    'verify_ssl' => env('OPENAI_VERIFY_SSL', true),
];
