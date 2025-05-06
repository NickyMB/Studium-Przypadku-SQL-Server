<?php
    include "Doctor_Scripts/connect.php";
    echo "<h2>Średnia ilość badań</h2>";
    $query = "SELECT * FROM AverageTestPerPatient() ORDER BY AvgAppointments desc";
    $stmt = sqlsrv_query($conn, $query);
    if ($stmt === false) {
        die(print_r(sqlsrv_errors(), true));
    }

    echo "<table border='1'><tr>";
    // Pobierz i wyświetl nagłówki kolumn
    $fields = sqlsrv_field_metadata($stmt);
    foreach ($fields as $field) {
        echo "<th>{$field['Name']}</th>";
    }
    echo "</tr>";

    // Pobierz i wyświetl wszystkie wiersze
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        echo "<tr>";
        foreach ($row as $value) {
            echo "<td>" . htmlspecialchars($value) . "</td>";
        }
        echo "</tr>";
    }
    echo "</table>";

    sqlsrv_close($conn);
?>