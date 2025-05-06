<?php
header('Content-Type: application/json'); // Ensure the response is JSON

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if the required data is sent
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['ID']) && !empty($input['ID'])) {
        $doctorId = htmlspecialchars($input['ID'], ENT_QUOTES, 'UTF-8');

        include "Connect.php"; // Include the connection file 

        // Check if the connection is established
        if ($conn === false) {
            echo json_encode(['status' => 'error', 'message' => 'Database connection failed', 'details' => sqlsrv_errors()]);
            exit;
        }

        // Query to get the list of patients
        $query = "SELECT DISTINCT P.ID, P.Imie, P.Nazwisko AS Pacjent 
                  FROM Patients P 
                  JOIN Appointments A ON P.ID = A.PatientsID 
                  JOIN Doctors D ON A.DoctorsID = D.ID WHERE D.ID = ?";
        $params = array($doctorId);
        $result = sqlsrv_query($conn, $query, $params);

        // Check if the query was successful
        if ($result === false) {
            echo json_encode(['status' => 'error', 'message' => 'Query failed', 'details' => sqlsrv_errors()]);
            exit;
        }

        $data = [];

        // Loop through the results and prepare the data
        while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC)) {
            if (isset($row['ID']) && isset($row['Imie'])) {
                $data[] = [
                    'id' => $row['ID'],
                    'name' => htmlspecialchars($row['Imie']) . " " . htmlspecialchars($row['Pacjent'])
                ];
            }
        }

        echo json_encode(['status' => 'success', 'data' => $data]);
        sqlsrv_close($conn);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid doctor ID']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}
?>