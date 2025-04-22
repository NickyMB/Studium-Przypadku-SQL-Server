<link rel="stylesheet" href="CSS/Admin.css">
<title>Admin</title>

    <h1>Witaj administratorze!</h1>
    <div class="container">
        <div id="UsersContainer"></div>
        <div id="EditContainer">
            <form method="POST" action="">
                <input type="hidden" id="PatientID" name="PatientID">
                <input type="hidden" id="isEditing" name="isEditing" value="false"> <!-- Hidden field -->
                <label for="PatientName">Imię:</label><br>
                <input type="text" id="PatientName" name="PatientName"><br>
                <label for="PatientSurname">Nazwisko:</label><br>
                <input type="text" id="PatientSurname" name="PatientSurname"><br>
                <label for="Pesel">Pesel:</label><br>
                <input type="text" id="Pesel" name="Pesel"><br>
                <label for="Adres">Adres:</label><br>
                <input type="map" id="Adres" name="Adres"><br>
                <label for="Mobile">Telefon:</label><br>
                <input type="tel" pattern="[0-9]*" inputmode="numeric" maxlength="12" id="Mobile" name="Mobile"><br>
                <label for="BirthDate">Data Urodzenia:</label><br>
                <input type="date" id="BirthDate" name="BirthDate"><br>
                <label for="Department">Oddział:</label><br>
                <select id="Department" name="Department"></select><br><br>
                <button type="submit" name="action" value="save">Zapisz</button>
                <button type="submit" name="action" value="delete" onclick="return confirmDelete()">Usuń</button>
                <input type="reset" value="Resetuj">
            </form>
        </div>
    </container>

<script>
    let selectedPatientId = null; // To store the ID of the selected patient

    // Function to display users
    function displayUsers(data) {
        const container = document.getElementById("UsersContainer");
        container.innerHTML = ""; // Clear previous content
        console.log(data); // Log data to console for debugging
        let i = 0; // Initialize counter
        data.forEach((user) => {
            const userDiv = document.createElement("div");
            userDiv.id = `user${i}`; // Set unique ID
            userDiv.className = "user"; // Add class for styling
            userDiv.innerHTML = `
                <p><strong>ID:</strong> ${user.ID}</p>
                <p><strong>PESEL:</strong> ${user.Pesel}</p>
                <p><strong>Imię:</strong> ${user.Imie}</p>
                <p><strong>Nazwisko:</strong> ${user.Nazwisko}</p>
                <p><strong>Adres:</strong> ${user.Adres}</p>
                <p><strong>Telefon:</strong> ${user.Telefon}</p>
                <p><strong>Data Urodzenia:</strong> ${user.DataUrodzenia}</p>
                <p><strong>Oddział:</strong> ${user.Nazwa}</p>
            `;
            userDiv.onclick = () => populateForm(user); // Add click event
            container.appendChild(userDiv);
            i++; // Increment counter
        });
    }

    // Populate the form with the selected patient's data
    function populateForm(user) {
        selectedPatientId = user.ID; // Store the ID of the selected patient
        document.getElementById("PatientID").value = user.ID; // Hidden input for ID
        document.getElementById("isEditing").value = "true"; // Set editing mode
        document.getElementById("PatientName").value = user.Imie;
        document.getElementById("PatientSurname").value = user.Nazwisko;
        document.getElementById("Pesel").value = user.Pesel;
        document.getElementById("Adres").value = user.Adres;
        document.getElementById("Mobile").value = user.Telefon;
        document.getElementById("BirthDate").value = user.DataUrodzenia;
        document.getElementById("Department").value = user.Nazwa;
    }

    function confirmDelete() {
        const patientId = document.getElementById("PatientID").value;
        if (!patientId) {
            alert("Nie wybrano pacjenta do usunięcia.");
            return false; // Prevent form submission
        }
        return confirm("Czy na pewno chcesz usunąć tego pacjenta?");
    }
</script>
<?php
$serverName = "localhost\\MSSQLSERVER01"; // Serwer SQL Server, lokalnie
$connectionOptions = array(
    "Database" => "HMS", // Nazwa bazy danych
    "Uid" => "administrator", // Użytkownik
    "PWD" => "admin1" // Hasło użytkownika
);

// Tworzenie połączenia
$conn = sqlsrv_connect($serverName, $connectionOptions);

// Sprawdzanie połączenia
if (!$conn) {
    die(print_r(sqlsrv_errors(), true));
}

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $action = $_POST["action"];
    $patientId = $_POST["PatientID"];
    $patientName = $_POST["PatientName"];
    $patientSurname = $_POST["PatientSurname"];
    $pesel = $_POST["Pesel"];
    $address = $_POST["Adres"];
    $mobile = $_POST["Mobile"];
    $birthDate = $_POST["BirthDate"];
    $department = $_POST["Department"];

    if ($action === "save") {
        $isEditing = $_POST["isEditing"] === "true";
        if ($isEditing) {
            // Update existing patient
            $sql = "UPDATE [dbo].[Patients]
                    SET Imie = ?, Nazwisko = ?, Adres = ?, Telefon = ?, DataUrodzenia = ?, Pesel = ?, DepartmentsID = ?
                    WHERE ID = ?";
            $qr = "SELECT dbo.GetDepartmentID(?) as id";
            $stmtDept = sqlsrv_query($conn, $qr, array($department));
            if ($stmtDept === false || !($row = sqlsrv_fetch_array($stmtDept, SQLSRV_FETCH_ASSOC))) {
                echo "<script>alert('Wystąpił błąd podczas pobierania ID oddziału.');</script>";
            } else {
                $Departmentid = $row['id'];
                $params = array($patientName, $patientSurname, $address, $mobile, $birthDate, $pesel, $Departmentid, $patientId);
                $stmt = sqlsrv_query($conn, $sql, $params);
                if ($stmt === false) {
                    echo "<script>alert('Wystąpił błąd podczas aktualizacji danych.');</script>";
                } else {
                    echo "<script>alert('Dane pacjenta zostały zaktualizowane.');</script>";
                }
            }
        } else {
            // Add new patient
            $sql = "INSERT INTO [dbo].[Patients] (Imie, Nazwisko, Adres, Telefon, DataUrodzenia, Pesel, DepartmentsID)
                    VALUES (?, ?, ?, ?, ?, ?, ?)";
            $qr = "SELECT dbo.GetDepartmentID(?) as id";
            $stmtDept = sqlsrv_query($conn, $qr, array($department));
            if ($stmtDept === false || !($row = sqlsrv_fetch_array($stmtDept, SQLSRV_FETCH_ASSOC))) {
                echo "<script>alert('Wystąpił błąd podczas pobierania ID oddziału.');</script>";
            } else {
                $Departmentid = $row['id'];
                $params = array($patientName, $patientSurname, $address, $mobile, $birthDate, $pesel, $Departmentid);
                $stmt = sqlsrv_query($conn, $sql, $params);
                if ($stmt === false) {
                    echo "<script>alert('Wystąpił błąd podczas dodawania danych.');</script>";
                } else {
                    echo "<script>alert('Nowy pacjent został dodany.');</script>";
                }
            }
        }
    } elseif ($action === "delete") {
        // Delete patient
        if (!empty($patientId)) {
            $sql = "DELETE FROM [dbo].[Patients] WHERE ID = ?";
            $params = array($patientId);
            $stmt = sqlsrv_query($conn, $sql, $params);
            if ($stmt === false) {
                echo "<script>alert('Wystąpił błąd podczas usuwania pacjenta.');</script>";
            } else {
                echo "<script>alert('Pacjent został usunięty.');</script>";
            }
        } else {
            echo "<script>alert('Nie wybrano pacjenta do usunięcia.');</script>";
        }
    }
}

// Fetch all patients with a LEFT JOIN to include those without a department
$qr = "SELECT Patients.ID, Imie,Nazwisko,Patients.Adres,Telefon,DataUrodzenia,DepartmentsID,Nazwa,Pesel FROM [dbo].[Patients] 
       LEFT JOIN [dbo].[Departments] ON Patients.DepartmentsID = Departments.ID";
$result_P = sqlsrv_query($conn, $qr);

if ($result_P === false) {
    die(print_r(sqlsrv_errors(), true)); // Debugging error
}

// Fetch and format patient data
$users = array();
while ($row = sqlsrv_fetch_array($result_P, SQLSRV_FETCH_ASSOC)) {
    if ($row === false) {
        die(print_r(sqlsrv_errors(), true)); // Debugging error
    }
    if (isset($row['DataUrodzenia'])) {
        $row['DataUrodzenia'] = $row['DataUrodzenia']->format('Y-m-d'); // Format date
    }
    $users[] = $row;
}

// Zapytanie do tabeli Departments
$qr = "SELECT Nazwa FROM [dbo].[Departments]" ;
$result_D = sqlsrv_query($conn, $qr);

// Sprawdzanie, czy zapytanie zostało wykonane poprawnie
if ($result_D === false) {
    die(print_r(sqlsrv_errors(), true));
}

// Pobieranie danych i kodowanie ich jako JSON
$Departments = array();
while ($row = sqlsrv_fetch_array($result_D, SQLSRV_FETCH_ASSOC)) {
    $Departments[] = $row;
}
// Przekazanie danych do JavaScript
echo "<script>const UsersData = " . json_encode($users) . "; displayUsers(UsersData);</script>";
echo "<script>
    const DepartmentsData = " . json_encode($Departments) . ";
    const departmentSelect = document.getElementById('Department');
    DepartmentsData.forEach(department => {
        const option = document.createElement('option');
        option.value = department.Nazwa;
        option.textContent = department.Nazwa;
        departmentSelect.appendChild(option);
    });
</script>";

// Zamknięcie połączenia
sqlsrv_close($conn);
?>
