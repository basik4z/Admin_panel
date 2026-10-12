<?php
// Разрешаем CORS (чтобы Delta мог загрузить)
header('Access-Control-Allow-Origin: *');
header('Content-Type: text/plain; charset=utf-8');

// Твой Lua-скрипт
$lua = <<<'LUA'
-- Твой скрипт здесь
print("Hello from my site!")
LUA;

echo $lua;
?>