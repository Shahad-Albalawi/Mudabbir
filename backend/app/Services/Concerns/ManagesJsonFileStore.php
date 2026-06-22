<?php

namespace App\Services\Concerns;

use Illuminate\Support\Facades\File;
use RuntimeException;

/**
 * Thread-safe JSON document store with exclusive file locks and corrupt-file protection.
 */
trait ManagesJsonFileStore
{
    /**
     * @param  callable(array): mixed  $callback  Mutates the in-memory document; changes are persisted atomically.
     */
    protected function mutateStore(callable $callback)
    {
        File::ensureDirectoryExists(dirname($this->path));

        $handle = fopen($this->path, 'c+');
        if ($handle === false) {
            throw new RuntimeException('Unable to open JSON store: '.$this->path);
        }

        try {
            if (! flock($handle, LOCK_EX)) {
                throw new RuntimeException('Unable to lock JSON store: '.$this->path);
            }

            $raw = stream_get_contents($handle);
            $data = $this->decodeStoreDocument($raw);

            $result = (function () use (&$data, $callback) {
                return $callback($data);
            })();

            $encoded = json_encode($data, JSON_UNESCAPED_UNICODE);
            if ($encoded === false) {
                throw new RuntimeException('Unable to encode JSON store: '.$this->path);
            }

            ftruncate($handle, 0);
            rewind($handle);
            fwrite($handle, $encoded);
            fflush($handle);

            return $result;
        } finally {
            flock($handle, LOCK_UN);
            fclose($handle);
        }
    }

    /** @return array<string, mixed> */
    abstract protected function emptyDocument(): array;

    abstract protected function collectionKey(): string;

  /**
     * @return array<string, mixed>
     */
    protected function decodeStoreDocument(?string $raw): array
    {
        $seed = $this->emptyDocument();
        $key = $this->collectionKey();

        if ($raw === null || $raw === '') {
            return $seed;
        }

        $decoded = json_decode($raw, true);
        if (! is_array($decoded) || ! isset($decoded[$key])) {
            if (File::exists($this->path) && strlen($raw) > 0) {
                $backup = $this->path.'.corrupt.'.time().'.json';
                File::copy($this->path, $backup);
            }

            throw new RuntimeException(
                'Corrupt JSON store at '.$this->path.' — backup created; manual recovery may be required.'
            );
        }

        return $decoded;
    }
}
