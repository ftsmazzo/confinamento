<?php

namespace App\Services\Confinamento;

use App\Models\Confinamento\Unidade;

class UnidadeService
{
    public function list(): array
    {
        return Unidade::orderBy("nome")->get();
    }

    public function findById($id): mixed
    {
        return Unidade::find($id) ?: Unidade::findByMd5($id);
    }

    public function create(array $payload): void
    {
        Unidade::create($payload);
    }

    public function update($id, array $payload): void
    {
        Unidade::updateBy($id, $payload);
    }

    public function delete($id): void
    {
        Unidade::deleteById($id);
    }
}
