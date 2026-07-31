<?php

namespace App\Services\Confinamento;

use App\Models\Confinamento\LocalEstoque;

class LocalEstoqueService
{
    public function list(): array
    {
        return LocalEstoque::orderBy("nome")->get();
    }

    public function findById($id): mixed
    {
        return LocalEstoque::find($id) ?: LocalEstoque::findByMd5($id);
    }

    public function create(array $payload): void
    {
        LocalEstoque::create($payload);
    }

    public function update($id, array $payload): void
    {
        LocalEstoque::updateBy($id, $payload);
    }

    public function delete($id): void
    {
        LocalEstoque::deleteById($id);
    }
}
