<?php
ini_set('display_errors', '0');
error_reporting(E_ALL);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function ttsProxyJsonError(int $status, string $message, array $extra = []): void {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(array_merge([
        'success' => false,
        'message' => $message,
    ], $extra), JSON_UNESCAPED_UNICODE);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    ttsProxyJsonError(405, 'Endpoint chỉ hỗ trợ phương thức POST.');
}

$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, true);
if (!is_array($input)) {
    ttsProxyJsonError(400, 'Dữ liệu gửi lên không đúng định dạng JSON.');
}

$text = trim((string)($input['text'] ?? ''));
if ($text === '') {
    ttsProxyJsonError(400, 'Vui lòng cung cấp văn bản để đọc.');
}

$pythonTtsUrl = getenv('PYTHON_TTS_URL') ?: 'http://127.0.0.1:8000/api/tts';
$payload = json_encode(['text' => $text], JSON_UNESCAPED_UNICODE);

$ch = curl_init($pythonTtsUrl);
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HEADER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => $payload,
    CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
    CURLOPT_TIMEOUT => 30,
]);

$raw = curl_exec($ch);
if ($raw === false) {
    $error = curl_error($ch);
    error_log('Python TTS proxy curl error: ' . $error);
    ttsProxyJsonError(502, 'Chưa kết nối được server Python gTTS. Hãy mở terminal, vào thư mục tts và chạy lệnh: uvicorn server:app --port 8001');
}

$httpCode = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
$headerSize = (int)curl_getinfo($ch, CURLINFO_HEADER_SIZE);
$headers = substr($raw, 0, $headerSize);
$body = substr($raw, $headerSize);

if ($httpCode < 200 || $httpCode >= 300) {
    $decoded = json_decode($body, true);
    $message = $decoded['detail'] ?? $decoded['message'] ?? 'Server Python gTTS chưa tạo được giọng nói.';
    ttsProxyJsonError(502, $message, ['upstreamStatus' => $httpCode]);
}

$contentType = 'audio/mpeg';
if (preg_match('/^content-type:\s*([^;\r\n]+)/im', $headers, $match)) {
    $contentType = trim($match[1]);
}

header('Content-Type: ' . $contentType);
header('Cache-Control: no-store');
header('Content-Length: ' . strlen($body));
echo $body;
