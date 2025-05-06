<?php
include "Connect.php"; // Połączenie z bazą danych

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $LekID = $_POST['LekID'] ?? null;
    $Dawka = $_POST['Dawka'] ?? null;
    $Dawkowanie = $_POST['Dawkowanie'] ?? null;
    $PatientID = $_POST['PatientID'] ?? null; // Dodano ID pacjenta

    if ($LekID && $Dawka && $Dawkowanie && $PatientID) {
        $query = "INSERT INTO Prescriptions (KodLeku, Dawka, Dawkowanie, PatientsId) VALUES (?, ?, ?, ?)";
        $params = [ $LekID, $Dawka, $Dawkowanie, $PatientID];
        $stmt = sqlsrv_query($conn, $query, $params);
        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Błąd podczas dodawania recepty', 'details' => sqlsrv_errors()]);
        } else {
            echo json_encode(['status' => 'success', 'message' => 'Recepta została dodana pomyślnie']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Nieprawidłowe dane wejściowe']);
    }
}

sqlsrv_close($conn);
?>