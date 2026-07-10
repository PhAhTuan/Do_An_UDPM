<?php
include __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';

try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
    $count = seedFaqKnowledgeFromSqlFile($pdo, __DIR__.'/database/faq_knowledge_seed.sql');
    echo "Đã cập nhật kho tri thức FAQ. Tổng số FAQ hiện có: {$count}\n";
} catch (Throwable $e) {
    http_response_code(500);
    echo "Lỗi seed FAQ: ".$e->getMessage()."\n";
}
