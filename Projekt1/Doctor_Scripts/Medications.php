<?php
include "Connect.php"; // Połączenie z bazą danych

header('Content-Type: application/json'); // Ustawienie nagłówka JSON

if ($conn === false) {
    echo json_encode(['status' => 'error', 'message' => 'Błąd połączenia z bazą danych']);
    exit;
}

$query = "SELECT M.ID AS UId, M.Nazwa AS UNazwa FROM Medications M";
$stmt = sqlsrv_query($conn, $query);

if ($stmt === false) {
    echo json_encode(['status' => 'error', 'message' => 'Błąd podczas pobierania danych', 'details' => sqlsrv_errors()]);
    exit;
}

$medications = [];
while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
    $medications[] = [
        'UId' => $row['UId'],
        'UNazwa' => $row['UNazwa']
    ];
}

echo json_encode(['status' => 'success', 'data' => $medications]);

sqlsrv_close($conn);
?>