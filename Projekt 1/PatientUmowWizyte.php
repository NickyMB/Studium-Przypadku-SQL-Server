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

// Odczyt danych z żądania
$data = json_decode(file_get_contents("php://input"), true);
if (!$data || !isset($data['doctorId'], $data['data'], $data['godzina'])) {
    echo json_encode(["status" => "error", "message" => "Nieprawidłowe dane wejściowe."]);
    exit;
}

$doctorId = $data['doctorId'];
$dataWizyty = $data['data'];
// $godzinaWizyty = $data['godzina'];

// Wstawienie wizyty do bazy danych
$sql = "INSERT INTO Appointments (DoctorsID, Data) VALUES (?, ?)";
$params = array($doctorId, $dataWizyty);
$stmt = sqlsrv_query($conn, $sql, $params);

if ($stmt === false) {
    echo json_encode(["status" => "error", "message" => "Błąd podczas zapisywania wizyty."]);
    exit;
}

// Sukces
echo json_encode(["status" => "success", "message" => "Wizyta została umówiona pomyślnie."]);
sqlsrv_close($conn);
