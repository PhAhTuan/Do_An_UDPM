<?php
include __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';
try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
    $stmt = $pdo->query("SHOW COLUMNS FROM users");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    print_r($columns);
} catch (Exception $e) {
    echo $e->getMessage();
}
