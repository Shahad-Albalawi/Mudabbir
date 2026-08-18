<?php

namespace App\Http\Requests\Concerns;

trait PaginatedListRules
{
    /**
     * @return array<string, list<string>>
     */
    protected function paginatedListRules(): array
    {
        return [
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ];
    }

    public function perPage(int $default = 15): int
    {
        return min(max((int) $this->query('per_page', $default), 1), 100);
    }
}
