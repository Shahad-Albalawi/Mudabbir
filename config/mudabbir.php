<?php

return [

    /*
    |--------------------------------------------------------------------------
    | JSON store subdirectory (under storage/app)
    |--------------------------------------------------------------------------
    |
    | When set (e.g. "testing" during PHPUnit), expense/goal/challenge JSON
    | files are isolated from development data.
    |
    */

    'json_store_subdir' => env('MUDABBIR_JSON_STORE_SUBDIR', ''),

    /*
    | DB health check timeout (seconds). Neon free tier cold starts need >= 5.
    */

    'health_db_timeout_seconds' => (int) env('HEALTH_DB_TIMEOUT_SECONDS', 5),

    'health_skip_ai_ping' => filter_var(
        env('MUDABBIR_HEALTH_SKIP_AI_PING', env('APP_ENV') === 'production'),
        FILTER_VALIDATE_BOOL,
    ),

];
