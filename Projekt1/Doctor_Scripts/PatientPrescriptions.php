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
    $query = "SELECT Prescriptions.ID,Medications.Nazwa NazwaLeku, KodLeku, Dawka, Dawkowanie
              FROM Prescriptions
              join Patients on Patients.ID = Prescriptions.PatientsId
              join Appointments on Appointments.PatientsID = Patients.ID
              join Medications on Medications.ID = Prescriptions.KodLeku
              WHERE Appointments.ID = ?";
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
            'NazwaLeku' => htmlspecialchars($row['NazwaLeku']),
            'Dawka' => htmlspecialchars($row['Dawka']),
            'Dawkowanie' => htmlspecialchars($row['Dawkowanie']),
            'KodLeku' => htmlspecialchars($row['KodLeku']) 
        ];
    }

    // Zwrócenie wyników w formacie JSON
    echo json_encode(['status' => 'success', 'data' => $tests]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Nieprawidłowe dane wejściowe']);
}

sqlsrv_close($conn); // Zamknięcie połączenia z bazą danych
?>