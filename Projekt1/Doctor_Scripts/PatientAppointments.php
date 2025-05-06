<?php
include "Connect.php"; // Include the connection file

header('Content-Type: application/json'); // Ensure the response is JSON

// Check if the connection is established
if ($conn === false) {
    echo json_encode(['status' => 'error', 'message' => 'Database connection failed', 'details' => sqlsrv_errors()]);
    exit;
}

// Get the input data
$input = file_get_contents("php://input");
$data = json_decode($input, true);

if (isset($data['ID']) && !empty($data['ID'])) {
    $pacjentId = htmlspecialchars($data['ID'], ENT_QUOTES, 'UTF-8');

    // Query to get the appointments for the patient
    $query = "SELECT A.Data AS DataWizyty, A.Diagnoza ,A.ID IdWizyty
              FROM Appointments A 
              WHERE A.PatientsID = ?";
    $params = array($pacjentId);
    $result = sqlsrv_query($conn, $query, $params);

    // Check if the query was successful
    if ($result === false) {
        echo json_encode(['status' => 'error', 'message' => 'Query failed', 'details' => sqlsrv_errors()]);
        exit;
    }

    $appointments = [];

    // Loop through the results and prepare the data
    while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC)) {
        $appointments[] = [
            'DataWizyty' => $row['DataWizyty']->format('Y-m-d H:i:s'), // Format the date
            'Diagnoza' => htmlspecialchars($row['Diagnoza']),
            'IdWizyty' => htmlspecialchars($row['IdWizyty'])
        ];
    }

    echo json_encode(['status' => 'success', 'data' => $appointments]);
} else {
    http_response_code(400); // Bad Request
    echo json_encode(['status' => 'error', 'message' => 'Invalid patient ID']);
}

sqlsrv_close($conn);
?>