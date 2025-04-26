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
<form id="Specjalizacje">
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

        // Pobierz wybraną specjalizację z POST
        $selectedSpecialization = isset($_POST['Specjalizacja']) ? $_POST['Specjalizacja'] : '';

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
        const imie = cells[0].innerText; // Imię lekarza
        const data = cells[1].innerText; // Data wizyty
        const godzina = cells[2].innerText; // Godzina wizyty
        const doctorId = row.querySelector("input[name='doctorId']").value; // Pobranie ukrytego ID lekarza

        // Przygotowanie danych do wysłania
        const postData = {
            doctorId: doctorId,
            data: data,
            godzina: godzina
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
</script>


<div id="ListaLekarzy">
    <?php
    // Sprawdź, czy specjalizacja została wybrana
    if (isset($_POST['Specjalizacja']) && !empty($_POST['Specjalizacja'])) {
        $Specka = $_POST['Specjalizacja']; // Pobranie wybranej specjalizacji z formularza
        if ($Specka == "Basic") {
            echo "<p>Najpierw wybierz specjalizację.</p>";
            // Ustawienie na pusty ciąg, jeśli wybrano domyślną opcję
        } else {
            // Zapytanie SQL z użyciem parametru
            $Times = array('8:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00'); // Godziny przyjęć

            // Generowanie dat na tydzień do przodu od dzisiaj
            $Dates = [];
            $today = new DateTime(); // Dzisiejsza data
            for ($i = 0; $i < 1; $i++) {
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


<?php
sqlsrv_close($conn);
?>