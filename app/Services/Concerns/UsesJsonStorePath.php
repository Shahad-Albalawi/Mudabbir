<?php

namespace App\Services\Concerns;

use Illuminate\Support\Facades\File;

trait UsesJsonStorePath
{
    protected function jsonStorePath(string $filename): string
    {
        $subdir = (string) config('mudabbir.json_store_subdir');
        $dir = $subdir !== ''
            ? storage_path('app/'.$subdir)
            : storage_path('app');

        File::ensureDirectoryExists($dir);

        return $dir.DIRECTORY_SEPARATOR.$filename;
    }
}
