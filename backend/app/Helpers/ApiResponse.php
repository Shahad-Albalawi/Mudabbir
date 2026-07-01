<?php

namespace App\Helpers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Pagination\AbstractPaginator;

/**
 * Unified JSON API envelope for all Mudabbir endpoints.
 */
final class ApiResponse
{
    public const VERSION = '1.0';

    /**
     * @param  array<string, mixed>  $extra
     */
    public static function success(
        mixed $data = null,
        ?string $message = null,
        int $status = 200,
        array $extra = [],
    ): JsonResponse {
        $payload = self::envelope(
            success: true,
            data: $data,
            message: $message,
            errors: null,
        );

        if (isset($extra['meta']) && is_array($extra['meta'])) {
            $payload['meta'] = self::meta($extra['meta']);
            unset($extra['meta']);
        }

        return response()->json(array_merge($payload, $extra), $status);
    }

    public static function created(mixed $data, ?string $message = 'تم الإنشاء بنجاح'): JsonResponse
    {
        return self::success($data, $message, 201);
    }

    public static function error(
        string $message,
        int $status = 400,
        ?array $errors = null,
        mixed $data = null,
    ): JsonResponse {
        return response()->json(
            self::envelope(
                success: false,
                data: $data,
                message: $message,
                errors: $errors,
            ),
            $status,
        );
    }

    public static function validationError(
        string $message,
        array $errors,
        int $status = 422,
    ): JsonResponse {
        return self::error($message, $status, $errors);
    }

    public static function notFound(string $message = 'المورد المطلوب غير موجود.'): JsonResponse
    {
        return self::error($message, 404);
    }

    public static function forbidden(string $message = 'غير مسموح بالوصول.'): JsonResponse
    {
        return self::error($message, 403);
    }

    public static function unauthorized(string $message = 'يجب تسجيل الدخول للوصول إلى هذا المورد.'): JsonResponse
    {
        return self::error($message, 401);
    }

    public static function conflict(string $message, mixed $data = null): JsonResponse
    {
        return self::error($message, 409, null, $data);
    }

    public static function serverError(string $message = 'حدث خطأ داخلي في الخادم. يرجى المحاولة لاحقاً.'): JsonResponse
    {
        return self::error($message, 500);
    }

    /**
     * @param  AbstractPaginator|array<string, mixed>  $collection
     */
    public static function paginated(
        AbstractPaginator|array $collection,
        ?string $message = null,
    ): JsonResponse {
        if ($collection instanceof AbstractPaginator) {
            $data = $collection->items();
            if ($data !== [] && reset($data) instanceof JsonResource) {
                $data = collect($data)->map(
                    fn (JsonResource $resource): array => $resource->resolve()
                )->all();
            }

            return self::success($data, $message, 200, [
                'meta' => self::meta([
                    'current_page' => $collection->currentPage(),
                    'per_page' => $collection->perPage(),
                    'total' => $collection->total(),
                    'last_page' => $collection->lastPage(),
                ]),
            ]);
        }

        return self::success($collection, $message);
    }

    /**
     * @param  array<string, mixed>|null  $details
     */
    public static function codedError(
        string $code,
        string $message,
        int $status = 400,
        ?array $details = null,
    ): JsonResponse {
        return response()->json(array_merge(
            self::envelope(
                success: false,
                data: null,
                message: $message,
                errors: [
                    'code' => $code,
                    'details' => $details,
                ],
            ),
            [
                'status' => 'error',
            ],
        ), $status);
    }

    /**
     * @param  array<string, mixed>  $extra
     * @return array<string, mixed>
     */
    public static function meta(array $extra = []): array
    {
        return array_merge([
            'timestamp' => now()->toIso8601String(),
            'version' => self::VERSION,
        ], $extra);
    }

    /**
     * @return array<string, mixed>
     */
    private static function envelope(
        bool $success,
        mixed $data,
        ?string $message,
        mixed $errors,
    ): array {
        return [
            'success' => $success,
            'data' => $data,
            'message' => $message,
            'errors' => $errors,
            'meta' => self::meta(),
        ];
    }
}
