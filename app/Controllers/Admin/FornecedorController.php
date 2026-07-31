<?php
namespace App\Controllers\Admin;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Config;
use App\Core\Redirect;
use App\Core\Request;
use App\Enums\EstadoBrasileiro;
use App\Models\Fornecedor;
use App\Lib\Cnpj;
use App\Models\FornecedorRamo;
use App\Models\FornecedorSituacao;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Reader\IReadFilter;
use PhpOffice\PhpSpreadsheet\Shared\Date as ExcelDate;

class FornecedorController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Fornecedores",
            "active_menu" => "fornecedores-fornecedores",
            "page" => [
                "title" => "Fornecedores",
                "desc" => "Cadastre e gerencie seus fornecedores",
            ],
            "csrf" => $this->csrf->generate(),
            "pessoa_opcoes" => $this->pessoaOpcoesFornecedor(),
            "pessoa_fixa" => $this->pessoaFixaFornecedor(),
            "uppers" => implode(",", Fornecedor::getUppers()),
            "required" => implode(",", Fornecedor::getRequired()),
            "estados_br" => array_map(
                fn (EstadoBrasileiro $estado) => $estado->value,
                EstadoBrasileiro::cases()
            ),
        ]);
    }

    public function index(): void
    {
        $this->authorize("fornecedor_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Fornecedores" => ["url" => false, "current" => true],
            ],
            "page" => [
                "title" => "Fornecedores",
                "desc" => "Cadastre e gerencie seus fornecedores",
            ],
        ]);

        $fornecedores = Fornecedor::leftJoin("fornecedor_situacao as s", "f.id_situacao", "=", "s.id")
            ->leftJoin("fornecedor_ramo as r", "f.id_ramo", "=", "r.id")
            ->select("f.*", "s.descricao as situacao_descricao", "s.cor as situacao_cor", "r.descricao as ramo_descricao")
            ->orderBy("f.razao")
            ->get();

        $permissao = [
            "inserir" => $this->auth->allow("fornecedor_inserir"),
            "editar" => $this->auth->allow("fornecedor_editar"),
            "excluir" => $this->auth->allow("fornecedor_excluir"),
            "situacao" => $this->auth->allow("fornecedor_situacao_gerenciar"),
            "ramo" => $this->auth->allow("fornecedor_ramo_gerenciar"),
        ];

        foreach ($fornecedores as $fornecedor) {
            $fornecedor->hash = md5($fornecedor->id);
            $fornecedor->tipo_print = $fornecedor->pessoa === "J" ? "PJ" : "PF";
            $fornecedor->principal_print = trim((string) ($fornecedor->razao ?: $fornecedor->nome)) ?: "-";
            $fornecedor->secundario_print = trim((string) ($fornecedor->nome ?: "")) ?: "-";
            $fornecedor->documento_print = $this->formatDocumento($fornecedor->pessoa, $fornecedor->documento);
            $fornecedor->contato_print = trim((string) ($fornecedor->contato ?: $fornecedor->telefone ?: $fornecedor->whatsapp)) ?: "-";
            $fornecedor->ramo_print = $fornecedor->ramo_descricao ?: "-";
            $fornecedor->situacao_print = !empty($fornecedor->id_situacao)
                ? $this->badgeColor(
                    $fornecedor->situacao_descricao ?: "Sem situação",
                    $fornecedor->situacao_cor ?: "#6c757d"
                ) : '<i class="text-black-50">Não definido</i>';
            $fornecedor->location_print = trim(implode(" - ", array_filter([
                $fornecedor->cidade,
                $fornecedor->estado,
            ]))) ?: "-";
            $fornecedor->disabled = $permissao["excluir"] ? "" : "disabled";
            $fornecedor->action = $permissao["excluir"] ? 'onclick="Delete(\'fornecedores/delete\', \'' . $fornecedor->id . '\')"' : "";
            $fornecedor->title = $permissao["excluir"] ? "Excluir fornecedor" : "Sem permissão";
        }

        echo $this->view->render("admin/fornecedor/lista", [
            "dados" => $fornecedores,
            "permissao" => $permissao,
            "modelo_importacao_url" => $this->importTemplateUrl(),
        ]);
    }

    public function new(): void
    {
        $this->authorize("fornecedor_inserir");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Fornecedores" => ["url" => $this->router->route("admin.fornecedor.index"), "current" => false],
                "Novo Fornecedor" => ["url" => false, "current" => true],
            ],
            "page" => [
                "title" => "Novo Fornecedor",
                "desc" => "Preencha os dados básicos do fornecedor",
            ],
        ]);

        echo $this->view->render("admin/fornecedor/novo", [
            "csrf" => $this->csrf->generate(),
            "situacoes" => FornecedorSituacao::orderBy("descricao")->get(),
            "ramos" => FornecedorRamo::orderBy("descricao")->get(),
            "url_back" => $this->router->route("admin.fornecedor.index"),
            "pessoa_padrao" => $this->defaultPessoaFornecedor(),
            "pessoa_opcoes" => $this->pessoaOpcoesFornecedor(),
            "pessoa_fixa" => $this->pessoaFixaFornecedor(),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("fornecedor_inserir");

        $data = $this->normalizedData($request);

        Fornecedor::create($data);

        $this->message->success("Fornecedor cadastrado com sucesso");
        $this->router->redirect("admin.fornecedor.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("fornecedor_editar");

        $data = new Data($request->all());
        $fornecedor = Fornecedor::find($data->id) ?: Fornecedor::findByMd5($data->id);

        if (!$fornecedor) {
            $this->message->warning("Fornecedor não encontrado");
            $this->router->redirect("admin.fornecedor.index");
        }

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Fornecedores" => ["url" => $this->router->route("admin.fornecedor.index"), "current" => false],
                "Editar Fornecedor" => ["url" => false, "current" => true],
            ],
            "page" => [
                "title" => "Editar Fornecedor",
                "desc" => "Atualize os dados do fornecedor",
            ],
        ]);

        echo $this->view->render("admin/fornecedor/editar", [
            "csrf" => $this->csrf->generate(),
            "fornecedor" => $fornecedor,
            "situacoes" => FornecedorSituacao::orderBy("descricao")->get(),
            "ramos" => FornecedorRamo::orderBy("descricao")->get(),
            "url_back" => $this->router->route("admin.fornecedor.index"),
            "pessoa_opcoes" => $this->pessoaOpcoesFornecedor(),
            "pessoa_fixa" => $this->pessoaFixaFornecedor(),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("fornecedor_editar");

        $data = new Data($request->all());
        $fornecedor = Fornecedor::find($data->id) ?: Fornecedor::findByMd5($data->id);

        if (!$fornecedor) {
            $this->message->warning("Fornecedor não encontrado");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizedData($request, true);
        Fornecedor::updateBy($fornecedor->id, $payload);

        $this->message->success("Fornecedor atualizado com sucesso");
        $this->router->redirect("admin.fornecedor.editar", ["id" => $fornecedor->hash()]);
    }

    public function delete(Request $request): void
    {
        $this->authorize("fornecedor_excluir");

        $data = new Data($request->all());
        $fornecedor = Fornecedor::findByMd5($data->id);

        if (!$fornecedor) {
            $this->message->warning("Fornecedor não encontrado");
            Redirect::referer();
        }

        Fornecedor::updateBy($fornecedor->id, [
            "trash" => 1,
            "deleted_by" => $this->user->uid,
            "deleted_at" => date("Y-m-d H:i:s"),
        ]);

        $this->message->success("Fornecedor removido com sucesso");
        Redirect::referer();
    }

    public function find(Request $request): void
    {
        $data = new Data($request->all());
        $cnpj = $this->normalizeImportDocumento($data->cnpj ?? $data->documento ?? "");

        header("Content-Type: application/json; charset=utf-8");

        if (strlen($cnpj) !== 14) {
            echo json_encode([
                "error" => true,
                "message" => "Informe um CNPJ válido.",
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        if (preg_match('/[A-Z]/', $cnpj)) {
            echo json_encode([
                "error" => true,
                "message" => "CNPJ alfanumerico validado, mas a consulta automática ainda não está disponível.",
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        try {
            $info = (new Cnpj())->get($cnpj);
        } catch (\Throwable $e) {
            echo json_encode([
                "error" => true,
                "message" => $e->getMessage(),
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        echo json_encode([
            "error" => false,
            "message" => "CNPJ localizado com sucesso.",
            "data" => [
                "pessoa" => "J",
                "documento" => $info["cnpj"] ?? $cnpj,
                "razao" => $info["nome"] ?? "",
                "nome" => $info["fantasia"] ?? ($info["nome"] ?? ""),
                "nascimento" => $info["abertura"] ?? "",
                "contato" => $info["responsavel"] ?? "",
                "telefone" => $info["telefone"] ?? "",
                "email" => $info["email"] ?? "",
                "site" => $info["site"] ?? "",
                "cep" => $info["cep"] ?? "",
                "endereco" => $info["logradouro"] ?? "",
                "numero" => $info["numero"] ?? "",
                "complemento" => $info["complemento"] ?? "",
                "bairro" => $info["bairro"] ?? "",
                "cidade" => $info["municipio"] ?? "",
                "estado" => $info["uf"] ?? "",
                "pais" => "Brasil",
            ],
        ], JSON_UNESCAPED_UNICODE);
    }

    public function importUpload(Request $request): void
    {
        $this->authorize("fornecedor_inserir");
        $allowIncomplete = !empty($_POST["permitir_incompletos"]);

        if (empty($_FILES["arquivo"]["tmp_name"]) || empty($_FILES["arquivo"]["name"])) {
            $this->message->flash("Selecione uma planilha para importar", "warning", "exclamation-triangle", "alert");
            Redirect::referer();
            return;
        }

        $file = $_FILES["arquivo"];
        $extension = strtolower(pathinfo((string) $file["name"], PATHINFO_EXTENSION));

        if (!in_array($extension, ["xlsx", "xls", "csv"], true)) {
            $this->message->flash("Envie uma planilha no formato XLSX, XLS ou CSV", "warning", "exclamation-triangle", "alert");
            Redirect::referer();
            return;
        }

        $dir = base_path("storage/tmp/fornecedores/importacoes");
        if (!is_dir($dir)) {
            @mkdir($dir, 0777, true);
        }

        $safeName = preg_replace('/[^a-zA-Z0-9_.-]/', '_', pathinfo((string) $file["name"], PATHINFO_FILENAME));
        $target = $dir . DIRECTORY_SEPARATOR . $safeName . "." . $extension;

        if (!move_uploaded_file($file["tmp_name"], $target)) {
            $this->message->flash("Não foi possivel salvar a planilha enviada", "warning", "exclamation-triangle", "alert");
            Redirect::referer();
            return;
        }

        try {
            $summary = $this->processFornecedorImport($target, $allowIncomplete);
            $message = $this->buildImportResultAlert($summary);
            $hasIssues = (int) ($summary["issues_count"] ?? 0) > 0;
            $this->message->flash(
                $message,
                $hasIssues ? "warning" : "success",
                $hasIssues ? "exclamation-triangle" : "check-circle",
                "alert"
            );
        } catch (\Throwable $e) {
            $this->message->flash("Não foi possivel importar a planilha: " . htmlspecialchars($e->getMessage(), ENT_QUOTES, "UTF-8"), "danger", "exclamation-circle", "alert");
        }

        $this->router->redirect("admin.fornecedor.index");
    }

    private function processFornecedorImport(string $path, bool $allowIncomplete = false): array
    {
        $reader = IOFactory::createReaderForFile($path);
        $reader->setReadDataOnly(true);

        $sheetInfo = $reader->listWorksheetInfo($path);
        if (empty($sheetInfo[0]['totalRows'])) {
            throw new \RuntimeException("A planilha enviada está vazia.");
        }

        $totalRows = (int) $sheetInfo[0]['totalRows'];
        $totalColumns = (int) ($sheetInfo[0]['totalColumns'] ?? 0);
        $lastColumn = Coordinate::stringFromColumnIndex(max(1, $totalColumns ?: 21));

        $headers = $this->readImportHeaders($reader, $path, $lastColumn);
        $columns = $this->mapImportColumns($headers);

        if ((!$allowIncomplete) && (empty($columns['pessoa']) || empty($columns['documento']))) {
            throw new \RuntimeException("A planilha não contém as colunas obrigatórias de Pessoa e Documento.");
        }

        $situacoes = FornecedorSituacao::orderBy("descricao")->get();
        $situacaoCache = [];
        foreach ($situacoes as $situacao) {
            $situacaoCache[$this->normalizeImportKey($situacao->descricao)] = (int) $situacao->id;
        }

        $existingDocuments = [];
        foreach (Fornecedor::select("documento")->get() as $fornecedor) {
            $documento = $this->normalizeImportDocumento($fornecedor->documento ?? "");
            if ($documento !== "") {
                $existingDocuments[$documento] = true;
            }
        }

        $imported = 0;
        $skipped = 0;
        $issues = [];
        $seenDocuments = [];
        $chunkSize = 300;
        $insertColumns = [
            "id_situacao",
            "pessoa",
            "documento",
            "rg_ie",
            "razao",
            "nome",
            "nascimento",
            "contato",
            "telefone",
            "whatsapp",
            "email",
            "site",
            "cep",
            "endereco",
            "numero",
            "complemento",
            "bairro",
            "cidade",
            "estado",
            "pais",
            "observacoes",
            "trash",
            "created_by",
        ];

        for ($startRow = 2; $startRow <= $totalRows; $startRow += $chunkSize) {
            $endRow = min($totalRows, $startRow + $chunkSize - 1);
            $chunkRows = $this->readImportChunk($reader, $path, $startRow, $endRow, $lastColumn);
            $chunkInsertRows = [];

            foreach ($chunkRows as $rowNumber => $row) {
                $line = (int) $rowNumber;
                $rowDataResult = $this->buildImportRow($row, $columns, $situacaoCache, $line, $allowIncomplete);

                if (!empty($rowDataResult['error'])) {
                    $skipped++;
                    $issues[] = [
                        "line" => $line,
                        "type" => "error",
                        "message" => $rowDataResult['error'],
                    ];
                    continue;
                }

                $rowData = $rowDataResult['data'];

                if (!empty($rowData['documento'])) {
                    if (isset($existingDocuments[$rowData['documento']]) || isset($seenDocuments[$rowData['documento']])) {
                        $skipped++;
                        $issues[] = [
                            "line" => $line,
                            "type" => "duplicate",
                            "message" => "Fornecedor duplicado. Documento {$rowData['documento']} já existe.",
                        ];
                        continue;
                    }

                    $seenDocuments[$rowData['documento']] = true;
                }

                $rowData = $this->normalizeImportInsertRow($rowData);
                $rowData['created_by'] = $this->user->uid;
                $rowData['trash'] = 0;

                $chunkInsertRows[] = $rowData;
            }

            if ($chunkInsertRows) {
                Fornecedor::insertMany($insertColumns, $chunkInsertRows, 300);
                $imported += count($chunkInsertRows);
            }
        }

        return [
            "imported" => $imported,
            "skipped" => $skipped,
            "issues" => $issues,
            "issues_count" => count($issues),
        ];
    }

    private function readImportHeaders($reader, string $path, string $lastColumn): array
    {
        $filter = new class(1, 1, Coordinate::columnIndexFromString($lastColumn)) implements IReadFilter {
            private int $startRow;
            private int $endRow;
            private int $maxColumn;

            public function __construct(int $startRow, int $chunkSize, int $maxColumn)
            {
                $this->startRow = $startRow;
                $this->endRow = $startRow + $chunkSize - 1;
                $this->maxColumn = $maxColumn;
            }

            public function readCell($columnAddress, $row, $worksheetName = ''): bool
            {
                return $row >= $this->startRow
                    && $row <= $this->endRow
                    && Coordinate::columnIndexFromString($columnAddress) <= $this->maxColumn;
            }
        };

        $reader->setReadFilter($filter);
        $spreadsheet = $reader->load($path);
        $sheet = $spreadsheet->getActiveSheet();

        $headers = $sheet->rangeToArray('A1:' . $lastColumn . '1', null, true, false, true);
        $spreadsheet->disconnectWorksheets();
        unset($spreadsheet);

        return $headers[1] ?? [];
    }

    private function readImportChunk($reader, string $path, int $startRow, int $endRow, string $lastColumn): array
    {
        $filter = new class($startRow, $endRow, Coordinate::columnIndexFromString($lastColumn)) implements IReadFilter {
            private int $startRow;
            private int $endRow;
            private int $maxColumn;

            public function __construct(int $startRow, int $endRow, int $maxColumn)
            {
                $this->startRow = $startRow;
                $this->endRow = $endRow;
                $this->maxColumn = $maxColumn;
            }

            public function readCell($columnAddress, $row, $worksheetName = ''): bool
            {
                return $row >= $this->startRow
                    && $row <= $this->endRow
                    && Coordinate::columnIndexFromString($columnAddress) <= $this->maxColumn;
            }
        };

        $reader->setReadFilter($filter);
        $spreadsheet = $reader->load($path);
        $sheet = $spreadsheet->getActiveSheet();

        $range = 'A' . $startRow . ':' . $lastColumn . $endRow;
        $rows = $sheet->rangeToArray($range, null, true, false, true);

        $spreadsheet->disconnectWorksheets();
        unset($spreadsheet);

        return $rows;
    }

    private function mapImportColumns(array $headers): array
    {
        $mapped = [];
        $normalized = [];

        foreach ($headers as $column => $label) {
            $normalized[$this->normalizeImportKey((string) $label)] = $column;
        }

        $aliases = [
            "pessoa" => ["TIPO DE PESSOA", "PESSOA", "TIPO PESSOA"],
            "documento" => ["CPF CNPJ", "CPF OU CNPJ", "CPF", "CNPJ"],
            "razao" => ["RAZAO SOCIAL / NOME COMPLETO", "RAZAO SOCIAL NOME COMPLETO", "RAZAO SOCIAL", "NOME COMPLETO", "RAZAO", "NOME"],
            "nome" => ["NOME FANTASIA / APELIDO", "NOME FANTASIA APELIDO", "NOME FANTASIA", "APELIDO"],
            "rg_ie" => ["IE / RG", "IE RG", "RG IE", "RG", "IE"],
            "nascimento" => ["DATA DE ABERTURA / NASCIMENTO", "DATA DE ABERTURA NASCIMENTO", "DATA DE ABERTURA", "NASCIMENTO", "ABERTURA"],
            "contato" => ["CONTATO"],
            "telefone" => ["TELEFONE", "CELULAR"],
            "whatsapp" => ["WHATSAPP"],
            "email" => ["E-MAIL", "E MAIL", "EMAIL"],
            "site" => ["SITE", "WEBSITE"],
            "situacao_descricao" => ["SITUACAO"],
            "cep" => ["CEP"],
            "endereco" => ["LOGRADOURO", "ENDERECO"],
            "numero" => ["NUMERO", "N"],
            "complemento" => ["COMPLEMENTO"],
            "bairro" => ["BAIRRO"],
            "cidade" => ["CIDADE"],
            "estado" => ["ESTADO", "UF"],
            "pais" => ["PAIS"],
            "observacoes" => ["OBSERVACOES"],
        ];

        foreach ($aliases as $key => $possibleHeaders) {
            foreach ($possibleHeaders as $alias) {
                $aliasKey = $this->normalizeImportKey($alias);
                if (isset($normalized[$aliasKey])) {
                    $mapped[$key] = $normalized[$aliasKey];
                    break;
                }
            }
        }

        $fallbacks = [
            "pessoa" => "A",
            "documento" => "B",
            "razao" => "C",
            "nome" => "D",
            "rg_ie" => "E",
            "nascimento" => "F",
            "contato" => "G",
            "telefone" => "H",
            "whatsapp" => "I",
            "email" => "J",
            "site" => "K",
            "situacao_descricao" => "L",
            "cep" => "M",
            "endereco" => "N",
            "numero" => "O",
            "complemento" => "P",
            "bairro" => "Q",
            "cidade" => "R",
            "estado" => "S",
            "pais" => "T",
            "observacoes" => "U",
        ];

        foreach ($fallbacks as $key => $column) {
            if (!isset($mapped[$key]) && isset($headers[$column])) {
                $mapped[$key] = $column;
            }
        }

        return $mapped;
    }

    private function buildImportRow(array $row, array $columns, array &$situacaoCache, int $line = 0, bool $allowIncomplete = false): array
    {
        $cell = function (string $key) use ($row, $columns) {
            return isset($columns[$key]) ? ($row[$columns[$key]] ?? null) : null;
        };

        $pessoaValue = isset($columns['pessoa']) ? ($row[$columns['pessoa']] ?? null) : null;
        $documentoValue = isset($columns['documento']) ? ($row[$columns['documento']] ?? null) : null;
        $razaoValue = $cell('razao');
        $nomeValue = $cell('nome');

        $pessoa = $this->parseImportPessoa($pessoaValue, $documentoValue);
        $documento = $this->normalizeImportDocumento($documentoValue);
        $razao = $this->normalizeImportFieldValue('razao', $razaoValue);
        $nome = $this->normalizeImportFieldValue('nome', $nomeValue);

        if (!$allowIncomplete && ($documento === "" || ($razao === "" && $nome === ""))) {
            return [
                "error" => "Linha {$line}: informe Documento e pelo menos Razão Social ou Nome.",
            ];
        }

        $documentoLength = strlen($documento);
        if ($documento !== "" && $pessoa === "J" && $documentoLength !== 14) {
            return [
                "error" => "Linha {$line}: CNPJ deve ter 14 dígitos.",
            ];
        }

        if ($documento !== "" && $pessoa === "F" && $documentoLength !== 11) {
            return [
                "error" => "Linha {$line}: CPF deve ter 11 dígitos.",
            ];
        }

        $cnpjValidator = function_exists("validaCNPJBR") ? "validaCNPJBR" : "validaCNPJ";

        if ($documento !== "" && $pessoa === "J" && function_exists($cnpjValidator) && !$cnpjValidator($documento)) {
            return [
                "error" => "Linha {$line}: CNPJ inválido.",
            ];
        }

        if ($documento !== "" && $pessoa === "F" && function_exists("validaCPF") && !validaCPF($documento)) {
            return [
                "error" => "Linha {$line}: CPF inválido.",
            ];
        }

        if ($allowIncomplete) {
            $razao = $razao ?: $nome ?: "";
            $nome = $nome ?: "";
        } else {
            $razao = $razao ?: $nome ?: $documento;
            $nome = $nome ?: $razao;
        }

        return [
            "data" => [
                "id_situacao" => $this->resolveImportSituacaoId($cell('situacao_descricao'), $situacaoCache),
                "pessoa" => $pessoa,
                "documento" => $documento ?: ($allowIncomplete ? "" : null),
                "rg_ie" => $this->normalizeImportFieldValue('rg_ie', $cell('rg_ie')),
                "razao" => $razao ?: ($allowIncomplete ? "" : null),
                "nome" => $nome ?: ($allowIncomplete ? "" : null),
                "nascimento" => $this->parseImportDate($cell('nascimento')),
                "contato" => $this->normalizeImportFieldValue('contato', $cell('contato')),
                "telefone" => only_numbers((string) $cell('telefone')),
                "whatsapp" => only_numbers((string) $cell('whatsapp')),
                "email" => $this->normalizeImportFieldValue('email', $cell('email')),
                "site" => $this->normalizeImportFieldValue('site', $cell('site')),
                "cep" => only_numbers((string) $cell('cep')),
                "endereco" => $this->normalizeImportFieldValue('endereco', $cell('endereco')),
                "numero" => $this->normalizeImportFieldValue('numero', $cell('numero')),
                "complemento" => $this->normalizeImportFieldValue('complemento', $cell('complemento')),
                "bairro" => $this->normalizeImportFieldValue('bairro', $cell('bairro')),
                "cidade" => $this->normalizeImportFieldValue('cidade', $cell('cidade')),
                "estado" => $this->normalizeImportText($cell('estado')),
                "pais" => $this->normalizeImportFieldValue('pais', $cell('pais')) ?: "Brasil",
                "observacoes" => $this->normalizeImportFieldValue('observacoes', $cell('observacoes')),
            ],
        ];
    }

    private function buildImportResultAlert(array $summary): string
    {
        $imported = (int) ($summary["imported"] ?? 0);
        $skipped = (int) ($summary["skipped"] ?? 0);
        $issues = is_array($summary["issues"] ?? null) ? $summary["issues"] : [];

        $html = [];
        $html[] = '<div class="mb-1"><strong>Importação concluída.</strong></div>';
        $html[] = '<div class="mb-1">' . $imported . ' fornecedor(es) importado(s).</div>';

        if ($skipped > 0) {
            $html[] = '<div class="mb-1">' . $skipped . ' linha(s) ignorada(s).</div>';
        }

        if (!empty($issues)) {
            $html[] = '<div class="mb-1"><strong>Ocorrências:</strong></div>';
            $html[] = '<ul class="mb-0 ps-3">';

            $limit = 20;
            foreach (array_slice($issues, 0, $limit) as $issue) {
                $line = (int) ($issue["line"] ?? 0);
                $message = (string) ($issue["message"] ?? "Erro ao processar a linha.");
                $message = preg_replace('/^Linha\\s+\\d+\\s*:\\s*/i', '', $message) ?: $message;
                $message = htmlspecialchars($message, ENT_QUOTES, 'UTF-8');
                $html[] = '<li>Linha ' . $line . ': ' . $message . '</li>';
            }

            if (count($issues) > $limit) {
                $html[] = '<li>... e mais ' . (count($issues) - $limit) . ' ocorrência(s).</li>';
            }

            $html[] = '</ul>';
        }

        return implode('', $html);
    }

    private function resolveImportSituacaoId(mixed $value, array &$cache): ?int
    {
        $label = $this->normalizeImportKey((string) $value);

        if ($label === "") {
            return null;
        }

        if (isset($cache[$label])) {
            return $cache[$label];
        }

        if (str_contains($label, "INAT")) {
            foreach ($cache as $key => $id) {
                if (str_contains($key, "INAT")) {
                    return $id;
                }
            }
        }

        if (str_contains($label, "ATIV")) {
            foreach ($cache as $key => $id) {
                if (str_contains($key, "ATIV")) {
                    return $id;
                }
            }
        }

        $bestId = null;
        $bestScore = 0;
        foreach ($cache as $key => $id) {
            similar_text($label, $key, $score);
            if ($score > $bestScore) {
                $bestScore = $score;
                $bestId = $id;
            }
        }

        if ($bestScore >= 80 && $bestId) {
            return $bestId;
        }

        $descricao = trim((string) $value);
        if ($descricao === "") {
            return null;
        }

        $situacao = FornecedorSituacao::create([
            "descricao" => $descricao,
            "cor" => "#000000",
            "ativo" => 1,
            "created_by" => $this->user->uid,
        ]);

        $cache[$label] = (int) $situacao->id;
        return (int) $situacao->id;
    }

    private function normalizeImportText(mixed $value): string
    {
        if ($value instanceof \DateTimeInterface) {
            return $value->format("Y-m-d");
        }

        $text = trim((string) $value);
        if ($text === "") {
            return "";
        }

        $text = preg_replace('/\s+/u', ' ', $text);
        return $this->toUpper($text);
    }

    private function normalizeImportEmail(mixed $value): string
    {
        $text = trim((string) $value);
        return $text !== "" ? strtolower($text) : "";
    }

    private function normalizeImportDocumento(mixed $value): string
    {
        $text = strtoupper(trim((string) $value));
        if ($text === "") {
            return "";
        }

        return preg_replace('/[^A-Za-z0-9]/', '', $text) ?: "";
    }

    private function normalizeImportFieldValue(string $field, mixed $value): string
    {
        $text = trim((string) $value);
        if ($text === "") {
            return "";
        }

        if (in_array($field, Fornecedor::getUppers(), true)) {
            return $this->toUpper($text);
        }

        return $text;
    }

    private function normalizeImportInsertRow(array $row): array
    {
        foreach (Fornecedor::getUppers() as $field) {
            if (!array_key_exists($field, $row) || $row[$field] === null || $row[$field] === '') {
                continue;
            }

            $row[$field] = $this->toUpper((string) $row[$field]);
        }

        $row['estado'] = $this->normalizeImportEstado($row['estado'] ?? null);

        return $row;
    }

    private function normalizeImportEstado(mixed $value): string
    {
        $text = $this->normalizeImportKey((string) $value);

        if ($text === '') {
            return '';
        }

        $ufMap = [
            'ACRE' => 'AC',
            'ALAGOAS' => 'AL',
            'AMAPA' => 'AP',
            'AMAZONAS' => 'AM',
            'BAHIA' => 'BA',
            'CEARA' => 'CE',
            'DISTRITO FEDERAL' => 'DF',
            'ESPIRITO SANTO' => 'ES',
            'GOIAS' => 'GO',
            'MARANHAO' => 'MA',
            'MATO GROSSO' => 'MT',
            'MATO GROSSO DO SUL' => 'MS',
            'MINAS GERAIS' => 'MG',
            'PARA' => 'PA',
            'PARAIBA' => 'PB',
            'PARANA' => 'PR',
            'PERNAMBUCO' => 'PE',
            'PIAUI' => 'PI',
            'RIO DE JANEIRO' => 'RJ',
            'RIO GRANDE DO NORTE' => 'RN',
            'RIO GRANDE DO SUL' => 'RS',
            'RONDONIA' => 'RO',
            'RORAIMA' => 'RR',
            'SANTA CATARINA' => 'SC',
            'SAO PAULO' => 'SP',
            'SERGIPE' => 'SE',
            'TOCANTINS' => 'TO',
        ];

        if (isset($ufMap[$text])) {
            return $ufMap[$text];
        }

        return in_array($text, $this->estadosBrasil(), true) ? $text : '';
    }

    private function estadosBrasil(): array
    {
        return array_map(
            static fn (EstadoBrasileiro $estado) => $estado->value,
            EstadoBrasileiro::cases()
        );
    }

    private function normalizeImportKey(string $value): string
    {
        $value = trim($value);
        if ($value === "") {
            return "";
        }

        $value = preg_replace('/\s+/u', ' ', $value);
        $value = @iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $value) ?: $value;
        $value = preg_replace('/[^A-Za-z0-9]+/', ' ', $value);
        $value = preg_replace('/\s+/u', ' ', $value);
        $value = trim($value);

        return $this->toUpper($value);
    }

    private function toUpper(string $value): string
    {
        return function_exists('mb_strtoupper')
            ? mb_strtoupper($value, 'UTF-8')
            : strtoupper($value);
    }

    private function parseImportPessoa(mixed $value, ?string $documento = null): string
    {
        $label = $this->normalizeImportKey((string) $value);
        $digits = only_numbers((string) $documento);

        $juridica = [
            "J",
            "PJ",
            "JURIDICA",
            "PESSOA JURIDICA",
            "JURIDICO",
            "EMPRESA",
        ];

        $fisica = [
            "F",
            "PF",
            "FISICA",
            "PESSOA FISICA",
        ];

        if ($label !== "") {
            foreach ($juridica as $needle) {
                if ($label === $needle || str_contains($label, $needle)) {
                    return "J";
                }
            }

            foreach ($fisica as $needle) {
                if ($label === $needle || str_contains($label, $needle)) {
                    return "F";
                }
            }
        }

        if (strlen($digits) === 14) {
            return "J";
        }

        return "F";
    }

    private function parseImportDate(mixed $value): ?string
    {
        if ($value instanceof \DateTimeInterface) {
            return $value->format("Y-m-d");
        }

        if (is_numeric($value) && (float) $value > 0) {
            try {
                return ExcelDate::excelToDateTimeObject((float) $value)->format("Y-m-d");
            } catch (\Throwable $e) {
                return null;
            }
        }

        $text = trim((string) $value);
        if ($text === "") {
            return null;
        }

        if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $text)) {
            return $text;
        }

        if (preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $text)) {
            return format_date($text);
        }

        $timestamp = strtotime($text);
        return $timestamp ? date("Y-m-d", $timestamp) : null;
    }

    private function normalizedData(Request $request, bool $update = false): array
    {
        $data = new Data($request->all());

        $data->nullIfEmpty("id_ramo");
        $data->nullIfEmpty("id_situacao");
        $data->nullIfEmpty("razao");
        $data->nullIfEmpty("nome");
        $data->nullIfEmpty("rg_ie");
        $data->nullIfEmpty("nascimento");
        $data->nullIfEmpty("contato");
        $data->nullIfEmpty("telefone");
        $data->nullIfEmpty("whatsapp");
        $data->nullIfEmpty("email");
        $data->nullIfEmpty("site");
        $data->nullIfEmpty("cep");
        $data->nullIfEmpty("endereco");
        $data->nullIfEmpty("numero");
        $data->nullIfEmpty("complemento");
        $data->nullIfEmpty("bairro");
        $data->nullIfEmpty("cidade");
        $data->nullIfEmpty("estado");
        $data->nullIfEmpty("pais");
        $data->nullIfEmpty("observacoes");

        $payload = $data->all();
        $payload["documento"] = $this->normalizeImportDocumento($payload["documento"] ?? "");
        $payload["cep"] = only_numbers((string) ($payload["cep"] ?? ""));
        $payload["telefone"] = only_numbers((string) ($payload["telefone"] ?? ""));
        $payload["whatsapp"] = only_numbers((string) ($payload["whatsapp"] ?? ""));

        unset($payload["csrf"]);
        unset($payload["id"]);

        if ($update) {
            $payload["updated_by"] = $this->user->uid;
        } else {
            $payload["trash"] = 0;
            $payload["created_by"] = $this->user->uid;
        }

        return $payload;
    }

    private function formatDocumento(?string $pessoa, ?string $documento): string
    {
        $value = $this->normalizeImportDocumento($documento ?? "");

        if (!$value) {
            return "-";
        }

        if ($pessoa === "F" && strlen($value) === 11) {
            return cpf($value);
        }

        if (strlen($value) === 14) {
            return cnpj($value);
        }

        return $value ?: "-";
    }

    private function badgeColor(string $label, string $color): string
    {
        $color = trim($color) ?: "#6c757d";
        $textColor = colorContrast($color);

        return '<span class="badge filled-outlined" style="background:' . htmlspecialchars($color, ENT_QUOTES, "UTF-8") . ';border-color:' . htmlspecialchars($color, ENT_QUOTES, "UTF-8") . ';color:' . htmlspecialchars($textColor, ENT_QUOTES, "UTF-8") . ';">' . htmlspecialchars($label, ENT_QUOTES, "UTF-8") . '</span>';
    }

    private function defaultPessoaFornecedor(): string
    {
        $value = strtoupper(trim((string) Config::get('modulos.fornecedor.default_pessoa', 'J')));

        return in_array($value, ['F', 'J'], true) ? $value : 'J';
    }

    private function pessoaOpcoesFornecedor(): array
    {
        $values = Config::get('modulos.fornecedor.allowed_pessoa', ['F', 'J']);
        $values = is_array($values) ? $values : [$values];

        $values = array_values(array_unique(array_filter(array_map(
            static fn ($value) => strtoupper(trim((string) $value)),
            $values
        ), static fn ($value) => in_array($value, ['F', 'J'], true))));

        return $values ?: ['F', 'J'];
    }

    private function pessoaFixaFornecedor(): bool
    {
        return count($this->pessoaOpcoesFornecedor()) === 1;
    }

    private function importTemplateUrl(): string
    {
        return asset("docs/modelos/modelo-importacao-fornecedores.xlsx");
    }
}
