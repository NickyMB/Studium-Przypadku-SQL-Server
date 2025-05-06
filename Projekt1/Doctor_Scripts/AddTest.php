<?php
include "Connect.php"; // Połączenie z bazą danych

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $WizytaID = $_POST['WizytaID'] ?? null;
    $NazwaBadania = $_POST['NazwaBadania'] ?? null;
    $WynikBadania = $_POST['WynikBadania'] ?? null;
    $DataBadania = $_POST['DataBadania'] ?? null;

    if ($WizytaID && $NazwaBadania && $WynikBadania && $DataBadania) {
        $query = "INSERT INTO LabTest (AppointmentsID, TypBadania, Wynik, Data) VALUES (?, ?, ?, ?)";
        $params = [$WizytaID, $NazwaBadania, $WynikBadania, $DataBadania];
        $stmt = sqlsrv_query($conn, $query, $params);

        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Błąd podczas dodawania badania', 'details' => sqlsrv_errors()]);
        } else {
            echo json_encode(['status' => 'success', 'message' => 'Badanie zostało dodane pomyślnie']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Nieprawidłowe dane wejściowe']);
    }
}

sqlsrv_close($conn);
?>