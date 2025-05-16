<?php
include "Connect.php"; // Połączenie z bazą danych

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $WizytaID = $_POST['WizytaID'] ?? null;
    $NazwaBadania = $_POST['NazwaBadania'] ?? null;
    $WynikBadania = $_POST['WynikBadania'] ?? null;
    $DataBadania = $_POST['DataBadania'] ?? null;

    if ($WizytaID && $NazwaBadania && $WynikBadania && $DataBadania) {
        // Pobierz datę wizyty (AppointmentsData)
        $sql = "SELECT Data FROM Appointments WHERE ID = ?";
        $stmt = sqlsrv_query($conn, $sql, [$WizytaID]);
        $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
        $AppointmentsData = $row ? $row['Data'] : null;

        if (!$AppointmentsData) {
            echo json_encode(['status' => 'error', 'message' => 'Nie znaleziono daty wizyty.']);
            exit;
        }

        $query = "INSERT INTO LabTest (AppointmentsID, TypBadania, Wynik, Data, AppointmentsData) VALUES (?, ?, ?, ?, ?)";
        $params = [$WizytaID, $NazwaBadania, $WynikBadania, $DataBadania, $AppointmentsData];
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