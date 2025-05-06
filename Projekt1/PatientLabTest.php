<?php
header('Content-Type: application/json'); // Ustawienie nagłówka JSON

// Połączenie z bazą danych
$serverName = "localhost\MSSQLSERVER01";
$connectionOptions = array(
    "Database" => "HMS",
    "Uid" => "Pacjent",
    "PWD" => "Pacjent1"
);
$conn = sqlsrv_connect($serverName, $connectionOptions);

if (!$conn) {
    echo json_encode(["status" => "error", "message" => "Błąd połączenia z bazą danych."]);
    exit;
}

// Pobranie danych z żądania
$data = json_decode(file_get_contents("php://input"), true);
if (!$data || !isset($data['ID'])) {
    echo json_encode(["status" => "error", "message" => "Nieprawidłowe dane wejściowe."]);
    exit;
}

$appointmentId = $data['ID'];

$sql = "SELECT LabTest.TypBadania TypBadania, LabTest.Wynik Wynik,LabTest.Data DataTestu FROM LabTest WHERE AppointmentsID = ?";
$params = array($appointmentId);
$stmt = sqlsrv_query($conn, $sql, $params);

if ($stmt === false) {
    echo json_encode(["status" => "error", "message" => "Błąd podczas pobierania danych."]);
    exit;
}

$labTests = [];
while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
    $row['DataTestu'] =$row['DataTestu']->format('Y-m-d\ H:i'); // Format ISO 8601
    $labTests[] = $row;
}

// Zwrócenie wyników jako JSON
echo json_encode(["status" => "success", "data" => $labTests]);
sqlsrv_close($conn);
?>