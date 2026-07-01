<?php

namespace App\Http\Traits;

use App\Helpers\ApiResponse as ApiResponseHelper;
use Illuminate\Http\JsonResponse;
use Illuminate\Pagination\AbstractPaginator;

trait ApiResponse
{
    protected function success(
        mixed $data = null,
        string $message = '',
        int $code = 200,
        array $extra = [],
    ): JsonResponse {
        return ApiResponseHelper::success(
            $data,
            $message !== '' ? $message : null,
            $code,
            $extra,
        );
    }

    protected function created(mixed $data, string $message = 'تم الإنشاء بنجاح'): JsonResponse
    {
        return ApiResponseHelper::created($data, $message);
    }

    protected function error(
        string $message,
        int $code = 400,
        ?array $errors = null,
        mixed $data = null,
    ): JsonResponse {
        return ApiResponseHelper::error($message, $code, $errors, $data);
    }

    protected function notFound(string $message = 'المورد المطلوب غير موجود.'): JsonResponse
    {
        return ApiResponseHelper::notFound($message);
    }

    protected function forbidden(string $message = 'غير مسموح بالوصول.'): JsonResponse
    {
        return ApiResponseHelper::forbidden($message);
    }

    protected function conflict(string $message, mixed $data = null): JsonResponse
    {
        return ApiResponseHelper::conflict($message, $data);
    }

    /**
     * @param  AbstractPaginator|array<string, mixed>  $collection
     */
    protected function paginated(
        AbstractPaginator|array $collection,
        string $message = '',
    ): JsonResponse {
        return ApiResponseHelper::paginated(
            $collection,
            $message !== '' ? $message : null,
        );
    }

    /**
     * @param  array<string, mixed>|null  $details
     */
    protected function codedError(
        string $code,
        string $message,
        int $status = 400,
        ?array $details = null,
    ): JsonResponse {
        return ApiResponseHelper::codedError($code, $message, $status, $details);
    }
}
