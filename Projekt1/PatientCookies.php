<?php
header('Content-Type: application/json'); // Ustawienie nagłówka JSON

// Sprawdź, czy dane zostały przesłane
$data = json_decode(file_get_contents("php://input"), true);
if (!$data || !isset($data['ID'])) {
    echo json_encode(["status" => "error", "message" => "Nieprawidłowe dane wejściowe."]);
    exit;
}

// Sprawdź, czy wybrano poprawnego pacjenta
$cookieName = "PacjentCookie";
$cookieValue = $data['ID'];

if ($cookieValue === "Basic") { // Ignoruj opcję "Wybierz pacjenta"
    echo json_encode(["status" => "error", "message" => "Nie wybrano poprawnego pacjenta."]);
    exit;
}

// Ustawienie ciasteczka na 30 dni
setcookie($cookieName, $cookieValue, time() + (86400 * 30), "/");

// Zwróć sukces bez sprawdzania $_COOKIE
echo json_encode(["status" => "success", "message" => "Ciasteczko zostało ustawione.", "cookieValue" => $cookieValue]);
