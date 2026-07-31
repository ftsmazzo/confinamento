<?php

$finder = PhpCsFixer\Finder::create()
    ->in(__DIR__)
    ->exclude('vendor')
    ->exclude('storage')
    ->exclude('public/assets')
    ->name('*.php')
    ->ignoreDotFiles(true)
    ->ignoreVCS(true);

return (new PhpCsFixer\Config())
    ->setRules([
        '@PSR12'                     => true,
        'array_syntax'               => ['syntax' => 'short'],
        'no_unused_imports'          => true,
        'ordered_imports'            => ['sort_algorithm' => 'alpha'],
        'single_quote'               => true,
        'trailing_comma_in_multiline'=> true,
        'no_extra_blank_lines'       => true,
    ])
    ->setFinder($finder);
