<title>Pacjent</title>
<link rel="stylesheet" href="CSS/Patient.CSS">
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
if (!$conn) {
    die(print_r(sqlsrv_errors(), true));
} else {
    echo "<h1>Witaj pacjencie!</h1>";
}


?>
<!-- Formularz -->
<form id="Specjalizacje" method="GET" action="Patient.php">
    <label for="Specjalizacja">Wybierz specjalizację:</label>
    <select name="Specjalizacja" id="Specjalizacja" onchange="LoadDoctors()">
        <option value="Basic">-- Wybierz specjalizację --</option> <!-- Domyślna opcja -->
        <?php
        // Specjalizacje
        $sql_Specialization_List = "SELECT DISTINCT Specjalizacja FROM Doctors ORDER BY Specjalizacja ASC"; // Zapytanie SQL do pobrania danych specjalizacji
        $stmt = sqlsrv_query($conn, $sql_Specialization_List); // Wykonanie zapytania
        if ($stmt === false) {
            die(print_r(sqlsrv_errors(), true));
        }

        // Pobierz wybraną specjalizację z GET
        $selectedSpecialization = isset($_GET['Specjalizacja']) ? $_GET['Specjalizacja'] : '';

        while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            $specjalizacja = htmlspecialchars($row['Specjalizacja']); // Zabezpieczenie przed XSS
            // Sprawdź, czy to jest wybrana specjalizacja
            $selected = ($specjalizacja === $selectedSpecialization) ? 'selected' : '';
            echo "<option value='$specjalizacja' $selected>$specjalizacja</option>"; // Dodanie opcji do listy rozwijanej
        }
        ?>
    </select>
</form>
<br>
<form id="Pacjenci" method="POST" action="Patient.php">
    <label for="PacjenciLista">Wybierz pacjenta:</label>
    <select name="PacjenciLista" id="PacjenciLista" onchange="SetCookie()">
        
        <?php
        // Specjalizacje
        $sql_Pacjenci = "SELECT DISTINCT CONCAT(Imie,' ', Nazwisko) Name,ID FROM Patients ORDER BY CONCAT(Imie,' ', Nazwisko) ASC"; // Zapytanie SQL do pobrania danych specjalizacji
        $stmt = sqlsrv_query($conn, $sql_Pacjenci); // Wykonanie zapytania
        if ($stmt === false) {
            die(print_r(sqlsrv_errors(), true));
        }

        if (isset($_COOKIE['PacjentCookie'])) {
            echo "<option value='Basic'>-- Wybierz Pacjenta --</option>"; // Domyślna opcja
            echo "<script> console.log('Ciasteczko Działa.') </script>";

            while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            $Pacjenci = htmlspecialchars($row['Name']); // Zabezpieczenie przed XSS
            $IDPacjenta = htmlspecialchars($row['ID']); // Zabezpieczenie przed XSS
            if ($IDPacjenta == $_COOKIE['PacjentCookie']) {
                $selected = 'selected'; // Ustawienie opcji jako wybranej
            } else {
                $selected = ''; // Ustawienie opcji jako niewybranej
            }
            echo "<option value='$IDPacjenta' $selected>$Pacjenci</option>"; // Dodanie opcji do listy rozwijanej
        }
        } else {
            echo "<option value='Basic' selected>-- Wybierz Pacjenta --</option>"; // Domyślna opcja
            echo "<script> console.log('Ciasteczko Nie Działa.') </script>";

        while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            $Pacjenci = htmlspecialchars($row['Name']); // Zabezpieczenie przed XSS
            $IDPacjenta = htmlspecialchars($row['ID']); // Zabezpieczenie przed XSS
            echo "<option value='$IDPacjenta' $selected>$Pacjenci</option>"; // Dodanie opcji do listy rozwijanej
        }
       
        }

        ?>
    </select>
</form>


<script>
    // Funkcja do ustawiania ciasteczka
    function SetCookie() {
        const selectedValue = document.getElementById("PacjenciLista").value; // Pobranie wybranej wartości
        if (selectedValue && !(selectedValue == "Basic")) { // Sprawdź, czy wybrano wartość
            console.log("Wybrany pacjent:", selectedValue);
            // Przygotowanie danych do wysłania
            const postData = {
                ID: selectedValue
            };


            const xhr = new XMLHttpRequest();
            xhr.open("POST", "PatientCookies.php", true); // Plik PHP obsługujący żądanie
            xhr.setRequestHeader("Content-Type", "application/json"); // Nagłówek JSON
            xhr.onload = function() {
                console.log("Odpowiedź serwera:", xhr.responseText); // Wyświetl odpowiedź serwera w konsoli
                if (xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText); // Parsowanie odpowiedzi JSON
                        if (response.status === "success") {
                            // alert("Wizyta została umówiona pomyślnie!");
                            window.location.reload(); // Odświeżenie strony po umówieniu wizyty
                        } else {
                            alert("Błąd: " + response.message);
                        }
                    } catch (e) {
                        console.error("Błąd parsowania odpowiedzi JSON:", e);
                        console.error("Odpowiedź serwera:", xhr.responseText);
                    }
                } else {
                    console.error("Błąd żądania AJAX:", xhr.status, xhr.statusText);
                }
            };
            xhr.send(JSON.stringify(postData)); // Wysłanie danych jako JSON

        }

    }

    // Funkcja do ładowania lekarzy na podstawie wybranej specjalizacji
    function LoadDoctors() {
        const selectedValue = document.getElementById("Specjalizacja").value;
        if (selectedValue) { // Sprawdź, czy wybrano wartość
            console.log("Wybrana specjalizacja:", selectedValue);
            document.getElementById("Specjalizacje").submit(); // Wysłanie formularza
        }
    }
    // Funkcja do umawiania wizyty
    function UmowWizyte(row) {
        const cells = row.getElementsByTagName("td"); // Pobranie komórek wiersza
        if (cells.length < 3) {
            console.error("Nie można odczytać danych wiersza. Brakuje komórek.");
            return;
        }
        const patietnId = document.getElementById("PacjenciLista").value; // ID pacjenta
        const imie = cells[0].innerText; // Imię lekarza
        const data = cells[1].innerText; // Data wizyty
        const godzina = cells[2].innerText; // Godzina wizyty
        const doctorId = row.querySelector("input[name='doctorId']").value; // Pobranie ukrytego ID lekarza

        // Przygotowanie danych do wysłania
        const postData = {
            doctorId: doctorId,
            data: data,
            godzina: godzina,
            pacjentId: patietnId 
        };

        // Wysłanie danych za pomocą AJAX
        const xhr = new XMLHttpRequest();
        xhr.open("POST", "PatientUmowWizyte.php", true); // Plik PHP obsługujący żądanie
        xhr.setRequestHeader("Content-Type", "application/json"); // Nagłówek JSON
        xhr.onload = function() {
            console.log("Odpowiedź serwera:", xhr.responseText); // Wyświetl odpowiedź serwera w konsoli
            if (xhr.status === 200) {
                try {
                    const response = JSON.parse(xhr.responseText); // Parsowanie odpowiedzi JSON
                    if (response.status === "success") {
                        alert("Wizyta została umówiona pomyślnie!");
                        window.location.reload(); // Odświeżenie strony po umówieniu wizyty
                    } else {
                        alert("Błąd: " + response.message);
                    }
                } catch (e) {
                    console.error("Błąd parsowania odpowiedzi JSON:", e);
                    console.error("Odpowiedź serwera:", xhr.responseText);
                }
            } else {
                console.error("Błąd żądania AJAX:", xhr.status, xhr.statusText);
            }
        };
        xhr.send(JSON.stringify(postData)); // Wysłanie danych jako JSON
    }
    // Funkcja do ładowania badań dla wybranej wizyty
    function LoadLabTest(row) {
        const url = "PatientLabTest.php"; // URL to the PHP file handling the request
        const BadaniaDiv = document.getElementById("ListaBadan"); // Div for displaying tests
        BadaniaDiv.innerHTML = "<h2>Wyniki Badań</h2>"; // Clear previous content
        const AppId = row.querySelector("input[name='IdWizyty']").value; // Get appointment ID
        const Dane = {
            ID: AppId // Appointment ID
        };

        const xhr = new XMLHttpRequest();
        xhr.open('POST', url, true); // Set POST method and URL
        xhr.setRequestHeader('Content-Type', 'application/json'); // JSON header
        xhr.onload = () => {
            if (xhr.status === 200) {
                try {
                    const responseData = JSON.parse(xhr.responseText); // Parse JSON response
                    // console.log(responseData); // Log response to console
                    let tableContent = "<table border='1'>"; // Start table
                    tableContent += "<tr><th>Typ Badania</th><th>Wynik</th><th>Data Testu</th></tr>"; // Table headers
                    responseData.data.forEach((item) => {
                        
                        tableContent += "<tr><td>" + item.TypBadania + "</td><td>" + item.Wynik + "</td><td>" + item.DataTestu + "</td></tr>";
                    });
                    tableContent += "</table>"; // End table
                    BadaniaDiv.innerHTML += tableContent; // Assign table content to div
                } catch (e) {
                    console.error("Błąd parsowania odpowiedzi JSON:", e);
                }
            } else {
                console.error('Błąd żądania AJAX:', xhr.status, xhr.statusText);
            }
        };
        xhr.onerror = () => {
            console.error('Błąd sieci');
        };
        xhr.send(JSON.stringify(Dane)); // Send data as JSON
    }

    function LoadPrescriptions() {
        const url = "PatientListaRecept.php"; // URL to the PHP file handling the request
        const ReceptyDiv = document.getElementById("ListaRecept"); // Div for displaying tests
        ReceptyDiv.innerHTML = "<h2>Lista Recept</h2>"; // Clear previous content
        const PatientId = document.getElementById("PacjenciLista").value; // Get appointment ID
        const Dane = {
            ID: PatientId 
        };

        const xhr = new XMLHttpRequest();
        xhr.open('POST', url, true); // Set POST method and URL
        xhr.setRequestHeader('Content-Type', 'application/json'); // JSON header
        xhr.onload = () => {
            if (xhr.status === 200) {
                try {
                    const responseData = JSON.parse(xhr.responseText); // Parse JSON response
                    // console.log(responseData); // Log response to console
                     let tableContent = "<table border='1'>"; // Start table
                    tableContent += "<tr><th>Nazwa Leku</th><th>Dawkowanie</th><th>Dawka</th></tr>"; // Table headers
                    responseData.data.forEach((item) => {
                        
                        tableContent += "<tr><td>" + item.NazwaLeku + "</td><td>" + item.Dawkowanie + "</td><td>" + item.Dawka + "</td></tr>";
                    });
                    tableContent += "</table>"; // End table
                    ReceptyDiv.innerHTML += tableContent; // Assign table content to div
                } catch (e) {
                    console.error("Błąd parsowania odpowiedzi JSON:", e);
                }
            } else {
                console.error('Błąd żądania AJAX:', xhr.status, xhr.statusText);
            }
        };
        xhr.onerror = () => {
            console.error('Błąd sieci');
        };
        xhr.send(JSON.stringify(Dane)); // Send data as JSON
        
    }
</script>

<div id="Container">
    
<div id="ListaLekarzy">
    <?php
    echo "<h2>Lista Lekarzy</h2>";
    // Sprawdź, czy specjalizacja została wybrana
    if (isset($_GET['Specjalizacja']) && !empty($_GET['Specjalizacja'])) {
        $Specka = $_GET['Specjalizacja']; // Pobranie wybranej specjalizacji z formularza
        if ($Specka == "Basic") {
            echo "<p>Najpierw wybierz specjalizację.</p>";
        } else {
            // Zapytanie SQL z użyciem parametru
            $Times = array('08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00'); // Godziny przyjęć

            // Generowanie dat na tydzień do przodu od dzisiaj
            $Dates = [];
            $today = new DateTime(); // Dzisiejsza data
            for ($i = 0; $i < 7; $i++) {
                $Dates[] = $today->format('Y-m-d'); // Dodanie daty w formacie YYYY-MM-DD
                $today->modify('+1 day'); // Przejście do następnego dnia
            }
            $params = array($Specka); // Parametry zapytania

            $sql_Doctors_Appointments = "SELECT Cast(Data as Date) Data, Cast(Data as Time) Czas ,Doctors.ID,Imie FROM Doctors left join Appointments ON Doctors.Id = Appointments.DoctorsID WHERE Doctors.Specjalizacja = ?"; // Zapytanie SQL do pobrania danych lekarzy i ich wizyt
            $GodzinyLekarz = sqlsrv_query($conn, $sql_Doctors_Appointments, $params); // Wykonanie zapytania z parametrami
            if ($GodzinyLekarz === false) {
                die(print_r(sqlsrv_errors(), true)); // Obsługa błędów SQL
            }

            $sql_Doctors_List = "SELECT * FROM Doctors WHERE Doctors.Specjalizacja = ?";
            $stmt = sqlsrv_query($conn, $sql_Doctors_List, $params); // Wykonanie zapytania z parametrami

            if ($stmt === false) {
                die(print_r(sqlsrv_errors(), true)); // Obsługa błędów SQL
            }

            // Pobierz wszystkie wizyty do tablicy
            $appointments = [];
            while ($appointmentRow = sqlsrv_fetch_array($GodzinyLekarz, SQLSRV_FETCH_ASSOC)) {
                $appointmentDate = $appointmentRow['Data'] instanceof DateTime ? $appointmentRow['Data']->format('Y-m-d') : $appointmentRow['Data'];
                $appointmentTime = $appointmentRow['Czas'] instanceof DateTime ? $appointmentRow['Czas']->format('H:i') : $appointmentRow['Czas'];
                $appointments[] = [
                    'date' => $appointmentDate,
                    'time' => $appointmentTime,
                    'doctorId' => $appointmentRow['ID']
                ];
            }

            // Wyświetl tabelę z dostępnymi terminami
            echo "<table border='1'>"; // Rozpoczęcie tabeli
            echo "<tr><th>Imię</th><th>Data Przyjęcia</th><th>Godzina Przyjęcia</th></tr>"; // Nagłówki tabeli

            while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
                foreach ($Dates as $date) {
                    foreach ($Times as $time) {
                        // Sprawdź, czy lekarz ma już zaplanowaną wizytę w danym dniu i godzinie
                        $appointmentExists = false;
                        foreach ($appointments as $appointment) {
                            if ($appointment['date'] === $date && $appointment['time'] === $time && $appointment['doctorId'] === $row['ID']) {
                                $appointmentExists = true;
                                break; // Przerwij pętlę, jeśli znaleziono wizytę
                            }
                        }

                        // Wyświetl wiersz tylko, jeśli lekarz nie ma wizyty w tym terminie
                        if (!$appointmentExists) {
                            echo "<tr onclick='UmowWizyte(this)'>"; // Dodanie zdarzenia onclick do wiersza
                            echo "<td>" . htmlspecialchars($row['Imie']) . "</td>"; // Wyświetlenie imienia lekarza
                            echo "<td>" . htmlspecialchars($date) . "</td>"; // Wyświetlenie daty przyjęcia
                            echo "<td>" . htmlspecialchars($time) . "</td>"; // Wyświetlenie godziny przyjęcia
                            echo "<input type='hidden' name='doctorId' value='" . htmlspecialchars($row['ID']) . "'>"; // Ukryte pole z ID lekarza
                            echo "</tr>";
                        }
                    }
                }
            }
            
            echo "</table>";
        }
    } else {
        // Wyświetl komunikat, jeśli specjalizacja nie została wybrana
        echo "<p>Najpierw wybierz specjalizację.</p>";
    }
    ?>
</div>

<div id="ListaWizyt">
    <!-- wyświetlanie aktualnej listy wizyt aktywnego pacjenta -->
    <?php
    if (isset($_COOKIE['PacjentCookie'])) {
        $IDPacjenta = $_COOKIE['PacjentCookie']; // ID pacjenta z ciasteczka
        $sql_Wizyty = "SELECT Appointments.ID IdWizyty, Doctors.Imie,Appointments.Data DataWizyty, Appointments.Diagnoza Diagnoza,Doctors.Specjalizacja from Doctors join Appointments on Doctors.ID = DoctorsID where PatientsID = ?"; // Zapytanie SQL do pobrania wizyt pacjenta
        $params = array($IDPacjenta); // Parametry zapytania
        $stmt = sqlsrv_query($conn, $sql_Wizyty, $params); // Wykonanie zapytania z parametrami
        
        if ($stmt === false) {
            die(print_r(sqlsrv_errors(), true)); // Obsługa błędów SQL
        }
        
        echo "<h2>Twoje Wizyty</h2>";
        echo "<table border='1' >"; // Rozpoczęcie tabeli
        echo "<tr><th>Imię Lekarza</th><th>Specjalizacja</th><th>Data Wizyty</th><th>Godzina Wizyty</th><th>Diagnoza</th></tr>"; // Nagłówki tabeli
        
        while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            echo "<tr onclick='LoadLabTest(this)'>"; // Rozpoczęcie wiersza
            echo "<td>" . htmlspecialchars($row['Imie']) . "</td>"; // Wyświetlenie imienia lekarza
            echo "<td>" . htmlspecialchars($row['Specjalizacja']) . "</td>"; // Wyświetlenie imienia lekarza
            echo "<td>" . $row['DataWizyty']->format('Y-m-d') . "</td>"; // Wyświetlenie daty w formacie YYYY-MM-DD HH:MM
            echo "<td>" . $row['DataWizyty']->format('H:i') . "</td>"; // Wyświetlenie daty w formacie YYYY-MM-DD HH:MM
            echo "<td>" . htmlspecialchars($row['Diagnoza']) . "</td>"; // Wyświetlenie imienia lekarza
            echo "<input type='hidden' name='IdWizyty' value='" . htmlspecialchars($row['IdWizyty']) . "'>"; // Ukryte pole z ID lekarza
            echo "</tr>"; // Zakończenie wiersza
        }

        echo "</table>"; // Zakończenie tabeli
    } else {
        echo "<p>Nie masz jeszcze umówionych wizyt.</p>";
    }
?>

</div>
<div id="ListaBadan">
<h2>Wyniki Badań</h2>
</div>
<div id="ListaRecept">
<h2>Lista Recept</h2>
<script>
    LoadPrescriptions(); // Wywołanie funkcji do ładowania recept
</script>
</div>
</div>
<?php
sqlsrv_close($conn);
?>