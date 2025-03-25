<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin</title>
</head>
<body>
    
</body>
</html>

<?php
$serverName = "localhost\MSSQLSERVER01"; // Serwer SQL Server, lokalnie
$connectionOptions = array(
    "Database" => "HMS", // Nazwa bazy danych
    "Uid" => "administrator", // Użytkownik
    "PWD" => "admin1" // Hasło użytkownika
);

// Tworzenie połączenia
$conn = sqlsrv_connect($serverName, $connectionOptions);

// Sprawdzanie połączenia
if( !$conn ) {
    die( print_r(sqlsrv_errors(), true));
} else {
    echo "Witaj administratorze!<br>";
}

    // Query to fetch all data from Medications table
    $qr = "SELECT * FROM [dbo].[Patients]";
    $result = sqlsrv_query($conn, $qr);

    // Check if query execution was successful
    if ($result === false) {
        die(print_r(sqlsrv_errors(), true));
    }

    // Fetch data and encode it as JSON
    $medications = array();
    $i = 0;
    while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC)) {
        echo "<div class='patients' id='patient{$i}'>";
        echo "ID: " . $row['ID'] . "<br>";
        echo "Pesel: " . $row['Pesel'] . "<br>";
        echo "Imię: " . $row['Imie'] . "<br>";
        echo "Nazwisko: " . $row['Nazwisko'] . "<br>";
        echo "Adres: " . $row['Adres'] . "<br>";
        echo "Telefon: " . $row['Telefon'] . "<br>";
        echo "Data Urodzenia: " . $row['DataUrodzenia']->format('Y-m-d') . "<br><br>";
        echo "</div>";
        $i++;
    }

sqlsrv_close($conn);
?>