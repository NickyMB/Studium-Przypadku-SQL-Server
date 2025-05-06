<?php
include "Connect.php"; // Include the connection file 

// Check if the connection is established
if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
}

// Query to get the list of doctors
$query = "SELECT DISTINCT ID, Imie FROM Doctors";
$result = sqlsrv_query($conn, $query);

// Check if the query was successful
if ($result === false) {
    die(print_r(sqlsrv_errors(), true));
}

// Loop through the results and create options for the select element
while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC)) {
    if (isset($row['ID']) && isset($row['Imie'])) {
        echo "<option value='" . htmlspecialchars($row['ID']) . "'>" . htmlspecialchars($row['Imie']) . "</option>";
    }
}
// Close the connection
sqlsrv_close($conn);
?>