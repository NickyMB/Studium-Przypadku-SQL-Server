<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="Chemist.css">
    <title>Medications</title>
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
</head>
<body>
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

    // Close the connection
    sqlsrv_close($conn);

    // Pass data to JavaScript
    echo "<script>const medicationsData = " . json_encode($medications) . "; displayMedications(medicationsData);</script>";
    ?>
</body>
</html>
