<link rel="stylesheet" href="CSS/Doctor.css">
<form method="POST" action="Doctor.php">
    <label for="ListaLekarzy">Wybierz lekarza:</label>
    <select name="ListaLekarzy" id="ListaLekarzy">
        <option value="" selected>-- Wybierz Lekarza --</option>
        <?php include "Doctor_Scripts/DoctorList.PHP"; // Include the doctor list script ?>
    </select>
    <br>
    <label for="ListaPacjentow">Wybierz pacjenta:</label>
    <select name="ListaPacjentow" id="ListaPacjentow">
    <option value="">-- Brak Pacjentów --</option>
    <script src="Doctor_Scripts/SendDoctorIDToPatients.js"></script>
    </select>
</form>
    <br>
    <div id="Container">
        <div id="Wizyty">
            <h2>Wizyty</h2>
            <table id="WizytyTable" border="1">
                <thead>
                    <tr>
                        <th>Data</th>

                        <th>Opis</th>
                    </tr>
                </thead>
                <tbody id="WizytyBody">
                    <script src="Doctor_Scripts/PacjenciWizyty.js"></script>
                    <?php include "Doctor_Scripts/WizytyEdit.php" ?>           
                </tbody>
            </table>
        </div>
        <div id="Badania">
            <h2>Badania</h2>
            <table id="BadaniaTable" border="1">
                <thead>
                    <tr>
                        <th>Nazwa Badania</th>
                        <th>Wynik</th>
                        <th>Data</th>
                        <th id="edit"></th>
                    </tr>
                </thead>
                <tbody id="BadaniaBody">
                    <script src="Doctor_Scripts/PacjenciBadania.js"></script>
                    <?php include "Doctor_Scripts/BadaniaEdit.php" ?>
                </tbody>
            </table>
        </div>
        <div id="Recepty">
            <h2>Recepty</h2>
            <table id="ReceptyTable" border="1">
                <thead>
                    <tr>
                        <th>Nazwa Leku</th>
                        <th>Dawkowanie</th>
                        <th>Dawka</th>
                    </tr>
                </thead>
                <tbody id="ReceptyBody">
                    <script src="Doctor_Scripts/PacjenciRecepty.js"></script>
                    <?php 
                    // include "Doctor_Scripts/ReceptyEdit.php" ?>
                </tbody>
            </table>
        </div>
        <div id="addPrescriptionModal" style="display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border: 1px solid black; z-index: 1000;">
            <h3>Dodaj nową receptę</h3>
            <label for="Lek">Wybierz lek:</label>
            <select id="Lek"></select>
            <br><br>
            <label for="Dawka">Dawka:</label>
            <input type="text" id="Dawka" placeholder="Wprowadź dawkę">
            <br><br>
            <label for="Dawkowanie">Dawkowanie:</label>
            <input type="text" id="Dawkowanie" placeholder="Wprowadź dawkowanie">
            <br><br>
            <button onclick="submitNewPrescription()">Zapisz</button>
            <button onclick="closeModal()">Anuluj</button>
        </div>
        <div id="modalOverlay" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.5); z-index: 999;" onclick="closeModal()"></div>
        <div id="addTestModal" style="display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border: 1px solid black; z-index: 1000;">
            <h3>Dodaj nowe badanie</h3>
            <label for="NazwaBadania">Nazwa badania:</label>
            <input type="text" id="NazwaBadania" placeholder="Wprowadź nazwę badania">
            <br><br>
            <label for="WynikBadania">Wynik badania:</label>
            <input type="text" id="WynikBadania" placeholder="Wprowadź wynik badania">
            <br><br>
            <label for="DataBadania">Data badania:</label>
            <input type="datetime-local" id="DataBadania">
            <br><br>
            <button onclick="submitNewTest()">Zapisz</button>
            <button onclick="closeTestModal()">Anuluj</button>
        </div>
        <div id="testModalOverlay" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.5); z-index: 999;" onclick="closeTestModal()"></div>
    </div>
</div>

