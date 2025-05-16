<?php
if (isset($_GET['download_xml'])) {
    $serverName = "localhost\\MSSQLSERVER01";
    $connectionOptions = array(
        "Database" => "HMS",
        "Uid" => "Farmaceuta",
        "PWD" => "Farmaceuta1"
    );
    $conn = sqlsrv_connect($serverName, $connectionOptions);
    $queryallMeds = "SELECT * FROM Medications";
    $stmtallMeds = sqlsrv_query($conn, $queryallMeds);
    $medicationsAllData = [];
    while ($row = sqlsrv_fetch_array($stmtallMeds, SQLSRV_FETCH_ASSOC)) {
        if (isset($row['TerminWaznosci']) && $row['TerminWaznosci'] instanceof DateTime) {
            $row['TerminWaznosci'] = $row['TerminWaznosci']->format('Y-m-d');
        }
        $medicationsAllData[] = $row;
    }
    sqlsrv_close($conn);

    $xml = new SimpleXMLElement('<Medications/>');
    foreach ($medicationsAllData as $med) {
        $medElem = $xml->addChild('Medication');
        foreach ($med as $key => $value) {
            $medElem->addChild($key, htmlspecialchars($value));
        }
    }
    header('Content-Disposition: attachment; filename="medications.xml"');
    header('Content-Type: application/xml');
    echo $xml->asXML();
    exit;
}
?>
<link rel="stylesheet" href="CSS/Chemist.css">
    <title>Medications</title>
    <form method="get" action="">
    <button type="submit" name="download_xml" value="1">Pobierz leki jako XML</button>
</form>
    <script>
        let selectedMedicationId = null; // To store the ID of the selected medication

        // JavaScript function to display data
        function displayMedications(data) {
            const container = document.getElementById("medicationsContainer");
            container.innerHTML = ""; // Clear previous content
            let i = 0; // Initialize counter
            data.forEach((medication) => {
                const medicationDiv = document.createElement("div");
                medicationDiv.id = `medication${i}`; // Set unique ID
                medicationDiv.className = "medication"; // Add class for styling
                medicationDiv.innerHTML = `
                    <p><strong>Nazwa:</strong> ${medication.Nazwa}</p>
                    <p><strong>Dostępność:</strong> ${medication.Dostepnosc}</p>
                    <p><strong>Producent:</strong> ${medication.Producent}</p>
                    <p><strong>Termin Ważności:</strong> ${medication.TerminWaznosci}</p>

                `;
                medicationDiv.onclick = () => populateForm(medication); // Add click event
                container.appendChild(medicationDiv);
                i++; // Increment counter
            });
        }

        // Populate the form with the selected medication's data
        function populateForm(medication) {
            selectedMedicationId = medication.ID; // Store the ID of the selected medication
            document.getElementById("medicationId").value = medication.ID; // Hidden input for ID
            document.getElementById("medicationName").value = medication.Nazwa;
            document.getElementById("availability").value = medication.Dostepnosc;
            document.getElementById("manufacturer").value = medication.Producent;
            document.getElementById("expiryDate").value = medication.TerminWaznosci;
        }
    </script>

    <h1>Witaj farmaceuto!</h1>
    <div class="container">
        <div id="medicationsContainer"></div>
        <div id="editContainer">
            <form method="POST" action="">
                <input type="hidden" id="medicationId" name="medicationId"> <!-- Hidden input for ID -->
                <label for="medicationName">Nazwa leku:</label><br>
                <input type="text" id="medicationName" name="medicationName"><br>
                <label for="availability">Dostępność:</label><br>
                <input type="text" id="availability" name="availability"><br>
                <label for="manufacturer">Producent:</label><br>
                <input type="text" id="manufacturer" name="manufacturer"><br>
                <label for="expiryDate">Termin ważności:</label><br>
                <input type="date" id="expiryDate" name="expiryDate"><br><br>
                <button type="submit" name = "action" value="update">Zapisz</button>
                <button type="submit" name = "action" value="add">Add New</button>
                <button type="submit" name = "action" value="del">Remove</button>
                <input type="reset" value="Resetuj">       
            </form>
        </div>
    </div>

    <?php
    // Połączenie z bazą
    $serverName = "localhost\\MSSQLSERVER01"; // SQL Server instance
    $connectionOptions = array(
        "Database" => "HMS", // Database name
        "Uid" => "Farmaceuta", // Username
        "PWD" => "Farmaceuta1" // Password
    );

    // Create connection
    $conn = sqlsrv_connect($serverName, $connectionOptions);

    // Check connection
    if (!$conn) {
        die(print_r(sqlsrv_errors(), true));
    }


    // Handle form submission to update the database
    if ($_SERVER["REQUEST_METHOD"] === "POST") {
        $action = $_POST["action"];
        $id = $_POST["medicationId"];
        $name = $_POST["medicationName"];
        $availability = $_POST["availability"];
        $manufacturer = $_POST["manufacturer"];
        $expiryDate = $_POST["expiryDate"];
if ($action == "update") {
        // Prepare the SQL query to update the medication
        $sql = "UPDATE [dbo].[Medications]
                SET Nazwa = ?, Dostepnosc = ?, Producent = ?, TerminWaznosci = ?
                WHERE ID = ?";
        $params = array($name, $availability, $manufacturer, $expiryDate, $id);

        $stmt = sqlsrv_query($conn, $sql, $params);

        if ($stmt === false) {
            echo "<script>alert('Wystąpił błąd podczas aktualizacji danych.');</script>";
        } else {

            echo "<script>alert('Dane leku zostały zaktualizowane.');</script>";
        }
    }
    elseif ($action =="add")
    {
        $sql = "INSERT INTO [dbo].[Medications] (Nazwa, Dostepnosc, Producent, TerminWaznosci)
                VALUES (?, ?, ?, ?)";
        $params = array($name, $availability, $manufacturer, $expiryDate);
        $stmt = sqlsrv_query($conn, $sql, $params);
        if ($stmt === false) {
            echo "<script>alert('Wystąpił błąd podczas dodawania danych.');</script>";
        } else {
            echo "<script>alert('Dane leku zostały dodanhe!');</script>";;
        }
    }
    elseif ($action =="del"){
        $sql = "DELETE FROM [dbo].[Medications] WHERE ID = $id";
        $stmt = sqlsrv_query($conn, $sql);
        if ($stmt === false) {
            echo "<script>alert('Lek nie został usunięty!');</script>";;
        } else {
            echo "<script>alert('Lek został usunięty!');</script>";;
        }
    }
    }
    // Query to fetch all data from Medications table
    $qr = "SELECT * FROM [dbo].[Medications]";
    $result = sqlsrv_query($conn, $qr);

    // Check if query execution was successful
    if ($result === false) {
        die(print_r(sqlsrv_errors(), true));
    }

    // Fetch data and encode it as JSON
    $medications = array();
    while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC)) {
        $row['TerminWaznosci'] = $row['TerminWaznosci']->format('Y-m-d'); // Format date
        $medications[] = $row;
    }


$queryallMeds = "SELECT * FROM Medications M";
$stmtallMeds = sqlsrv_query($conn, $queryallMeds);

if ($stmtallMeds === false) {
    echo json_encode(['status' => 'error', 'message' => 'Błąd podczas pobierania danych', 'details' => sqlsrv_errors()]);
    exit;
}

$medicationsAllData = [];
while ($row = sqlsrv_fetch_array($stmtallMeds, SQLSRV_FETCH_ASSOC)) {
    // Jeśli TerminWaznosci jest obiektem DateTime, sformatuj go
    if (isset($row['TerminWaznosci']) && $row['TerminWaznosci'] instanceof DateTime) {
        $row['TerminWaznosci'] = $row['TerminWaznosci']->format('Y-m-d');
    }
    $medicationsAllData[] = $row;
}


echo "<script>console.log(" . json_encode($medicationsAllData) . ");</script>";


    // Close the connection
    sqlsrv_close($conn);

    // Pass data to JavaScript
    echo "<script>const medicationsData = " . json_encode($medications) . "; displayMedications(medicationsData);</script>";
    ?>

<?php
if (isset($_GET['download_xml'])) {
    $medicationsAllData = [];
    // Połącz z bazą i pobierz dane jak wcześniej
    $serverName = "localhost\\MSSQLSERVER01";
    $connectionOptions = array(
        "Database" => "HMS",
        "Uid" => "Farmaceuta",
        "PWD" => "Farmaceuta1"
    );
    $conn = sqlsrv_connect($serverName, $connectionOptions);
    $queryallMeds = "SELECT * FROM Medications";
    $stmtallMeds = sqlsrv_query($conn, $queryallMeds);
    while ($row = sqlsrv_fetch_array($stmtallMeds, SQLSRV_FETCH_ASSOC)) {
        if (isset($row['TerminWaznosci']) && $row['TerminWaznosci'] instanceof DateTime) {
            $row['TerminWaznosci'] = $row['TerminWaznosci']->format('Y-m-d');
        }
        $medicationsAllData[] = $row;
    }
    sqlsrv_close($conn);

    // Konwersja do XML
    $xml = new SimpleXMLElement('<Medications/>');
    foreach ($medicationsAllData as $med) {
        $medElem = $xml->addChild('Medication');
        foreach ($med as $key => $value) {
            $medElem->addChild($key, htmlspecialchars($value));
        }
    }
    // Pobieranie pliku
    header('Content-Disposition: attachment; filename="medications.xml"');
    header('Content-Type: application/xml');
    echo $xml->asXML();
    exit;
}
?>

