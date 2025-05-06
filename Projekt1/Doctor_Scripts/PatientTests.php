<?php
include "Connect.php"; // Połączenie z bazą danych

header('Content-Type: application/json'); // Ustawienie nagłówka JSON

// Sprawdzenie połączenia z bazą danych
if ($conn === false) {
    echo json_encode(['status' => 'error', 'message' => 'Błąd połączenia z bazą danych']);
    exit;
}

// Pobranie danych z żądania
$input = file_get_contents("php://input");
$data = json_decode($input, true);

if (isset($data['IDWizyty']) && !empty($data['IDWizyty'])) {
    $idWizyty = htmlspecialchars($data['IDWizyty'], ENT_QUOTES, 'UTF-8');
    
    // Zapytanie SQL do pobrania badań dla konkretnej wizyty
    $query = "SELECT T.ID, T.TypBadania, T.Wynik, T.Data
              FROM LabTest T
              WHERE T.AppointmentsID = ?";
    $params = [$idWizyty];
    $stmt = sqlsrv_query($conn, $query, $params);

    // Sprawdzenie, czy zapytanie się powiodło
    if ($stmt === false) {
        echo json_encode(['status' => 'error', 'message' => 'Błąd podczas pobierania danych', 'details' => sqlsrv_errors()]);
        exit;
    }

    $tests = [];

    // Przetwarzanie wyników zapytania
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        $tests[] = [
            'IDBadania' => htmlspecialchars($row['ID']),
            'NazwaBadania' => htmlspecialchars($row['TypBadania']),
            'WynikBadania' => htmlspecialchars($row['Wynik']),
            'DataBadania' => $row['Data']->format('Y-m-d H:i:s') // Formatowanie daty
        ];
    }

    // Zwrócenie wyników w formacie JSON
    echo json_encode(['status' => 'success', 'data' => $tests]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Nieprawidłowe dane wejściowe']);
}

sqlsrv_close($conn); // Zamknięcie połączenia z bazą danych
?>