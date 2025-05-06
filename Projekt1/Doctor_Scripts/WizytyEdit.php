<?php
include "Connect.php"; // Include the connection file

if ($_SERVER['REQUEST_METHOD'] === 'POST') { // Sprawdź, czy żądanie jest metodą POST
    $Diagnoza = $_POST['Diagnoza'] ?? null; // Pobierz wartość pola Diagnoza
    $idWizyty = $_POST['IDWizyty'] ?? null; // Pobierz wartość ukrytego inputu IDWizyty

    if ($idWizyty !== null && $Diagnoza !== null) { // Sprawdź, czy obie wartości są ustawione
        $sql = "UPDATE Appointments SET Diagnoza = ? WHERE ID = ?"; // SQL query do aktualizacji
        $params = array($Diagnoza, $idWizyty); // Parametry zapytania

        $stmt = sqlsrv_query($conn, $sql, $params); // Wykonaj zapytanie
        if ($stmt === false) { // Sprawdź, czy zapytanie się powiodło
            die(print_r(sqlsrv_errors(), true)); // Wyświetl błędy w przypadku niepowodzenia
        } else {
            echo "Dane zostały zaktualizowane pomyślnie.";
        }
    } else {
        echo "Błąd: Wszystkie pola są wymagane.";
    }
}

sqlsrv_close($conn); // Zamknij połączenie z bazą danych
?>