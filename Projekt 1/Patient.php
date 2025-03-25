<?php
$serverName = "localhost\MSSQLSERVER01"; // Serwer SQL Server, lokalnie
$connectionOptions = array(
    "Database" => "HMS", // Nazwa bazy danych
    "Uid" => "Pacjent", // Użytkownik
    "PWD" => "Pacjent1" // Hasło użytkownika
);

// Tworzenie połączenia
$conn = sqlsrv_connect($serverName, $connectionOptions);

// Sprawdzanie połączenia
if( !$conn ) {
    die( print_r(sqlsrv_errors(), true));
} else {
    echo "Witaj pacjencie!";
}
?>