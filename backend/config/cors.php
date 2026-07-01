<?php

$defaultOrigins = [
    'https://yourdomain.com',
    'http://localhost:3000',
    'http://localhost:8080',
];

$corsOrigins = env('CORS_ALLOWED_ORIGINS');

if ($corsOrigins === null || trim($corsOrigins) === '') {
    $allowedOrigins = $defaultOrigins;
} else {
    $allowedOrigins = array_values(array_filter(array_map(
        'trim',
        explode(',', $corsOrigins)
    )));
}

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Applied to API routes via App\Http\Middleware\Cors (see Http\Kernel).
    | Override origins in production with CORS_ALLOWED_ORIGINS in .env.
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],

    'allowed_origins' => $allowedOrigins,

    'allowed_origins_patterns' => [],

    'allowed_headers' => [
        'Content-Type',
        'Authorization',
        'Accept',
        'X-Requested-With',
    ],

    'exposed_headers' => [
        'X-RateLimit-Limit',
        'X-RateLimit-Remaining',
    ],

    'max_age' => 0,

    'supports_credentials' => false,

];
