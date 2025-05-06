<?php
include "Connect.php"; // Połączenie z bazą danych

header('Content-Type: application/json'); // Ustawienie nagłówka JSON

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $IDRecepty = $_POST['IDRecepty'] ?? null;
    $LekID = $_POST['LekID'] ?? null;
    $Dawka = $_POST['Dawka'] ?? null;
    $Dawkowanie = $_POST['Dawkowanie'] ?? null;

    // Sprawdź, czy wszystkie wymagane dane są ustawione
    if ($IDRecepty && $LekID && $Dawka && $Dawkowanie) {
        $query = "UPDATE Prescriptions SET LekID = ?, Dawka = ?, Dawkowanie = ? WHERE ID = ?";
        $params = [$LekID, $Dawka, $Dawkowanie, $IDRecepty];
        $stmt = sqlsrv_query($conn, $query, $params);

        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Błąd podczas aktualizacji danych', 'details' => sqlsrv_errors()]);
        } else {
            echo json_encode(['status' => 'success', 'message' => 'Dane zostały zaktualizowane pomyślnie']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Nieprawidłowe dane wejściowe']);
    }
}

sqlsrv_close($conn);
?>