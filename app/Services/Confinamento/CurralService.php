<?php

namespace App\Services\Confinamento;

use App\Models\Confinamento\Curral;

class CurralService
{
    public function list(): array
    {
        return Curral::orderBy("nome")->get();
    }

    public function findById($id): mixed
    {
        return Curral::find($id) ?: Curral::findByMd5($id);
    }

    public function create(array $payload): void
    {
        Curral::create($payload);
    }

    public function update($id, array $payload): void
    {
        Curral::updateBy($id, $payload);
    }

    public function delete($id): void
    {
        Curral::deleteById($id);
    }
}
