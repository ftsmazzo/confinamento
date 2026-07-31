<?php

namespace App\Services\Confinamento;

use App\Models\Confinamento\Piquete;

class PiqueteService
{
    public function list(): array
    {
        return Piquete::orderBy("nome")->get();
    }

    public function findById($id): mixed
    {
        return Piquete::find($id) ?: Piquete::findByMd5($id);
    }

    public function create(array $payload): void
    {
        Piquete::create($payload);
    }

    public function update($id, array $payload): void
    {
        Piquete::updateBy($id, $payload);
    }

    public function delete($id): void
    {
        Piquete::deleteById($id);
    }
}
