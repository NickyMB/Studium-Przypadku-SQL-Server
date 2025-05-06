<?php
include "Connect.php"; // Include the connection file

if ($_SERVER['REQUEST_METHOD'] === 'POST') { // Sprawdź, czy żądanie jest metodą POST
    $NazwaBadania = $_POST['NazwaBadania'] ?? null; // Pobierz wartość pola NazwaBadania
    $WynikBadania = $_POST['WynikBadania'] ?? null; // Pobierz wartość pola WynikBadania
    $DataBadania = $_POST['DataBadania'] ?? null; // Pobierz wartość pola DataBadania
    $IdBadania = $_POST['IdBadania'] ?? null; // Pobierz wartość pola IdBadania
    if ($DataBadania) {
        $DataBadania = date('Y-m-d H:i:s', strtotime($DataBadania)); // Formatowanie daty
    }
    // Debugging log (opcjonalne, do usunięcia w środowisku produkcyjnym)
    // echo "<script>console.log('IdBadania: $IdBadania', 'Data Badania', $DataBadania, $WynikBadania, $NazwaBadania);</script>";

    // Sprawdź, czy wszystkie wymagane dane są ustawione
    if ($IdBadania && $NazwaBadania && $WynikBadania && $DataBadania) {
        // Poprawione zapytanie SQL
        $sql = "UPDATE LabTest SET TypBadania = ?, Wynik = ?, Data = ? WHERE ID = ?";
        $params = array($NazwaBadania, $WynikBadania, $DataBadania, $IdBadania); // Parametry zapytania

        $stmt = sqlsrv_query($conn, $sql, $params); // Wykonaj zapytanie
        if ($stmt === false) { // Sprawdź, czy zapytanie się powiodło
            echo json_encode(['status' => 'error', 'message' => 'Błąd podczas aktualizacji danych', 'details' => sqlsrv_errors()]);
        } else {
            echo json_encode(['status' => 'success', 'message' => 'Dane zostały zaktualizowane pomyślnie']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Błąd: Wszystkie pola są wymagane.']);
    }
}

sqlsrv_close($conn); // Zamknij połączenie z bazą danych
?>