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
    |--------------------------------------------------------------------------
    | Dual-write to legacy JSON (migration safety window)
    |--------------------------------------------------------------------------
    |
    | When true, API write endpoints mirror changes to storage/app/*.json
    | in addition to Eloquent. Reads always come from the database.
    | Set MUDABBIR_DUAL_WRITE_JSON=false after 1–2 stable days in production.
    | Optional MUDABBIR_DUAL_WRITE_JSON_UNTIL=2026-08-14 auto-disables mirroring.
    |
    */

    'dual_write_json' => env('MUDABBIR_DUAL_WRITE_JSON', true),

    'dual_write_json_until' => env('MUDABBIR_DUAL_WRITE_JSON_UNTIL'),

    /*
    | DB health check timeout (seconds). Neon free tier cold starts need >= 5.
    */

    'health_db_timeout_seconds' => (int) env('HEALTH_DB_TIMEOUT_SECONDS', 5),

    'health_skip_ai_ping' => filter_var(
        env('MUDABBIR_HEALTH_SKIP_AI_PING', env('APP_ENV') === 'production'),
        FILTER_VALIDATE_BOOL,
    ),

];
