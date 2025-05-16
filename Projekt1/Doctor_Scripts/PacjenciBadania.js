function ShowTests(IDWizyty) {
    const testsTable = document.getElementById("BadaniaBody");
    const datsToSend = {
        IDWizyty: IDWizyty,
    };

    fetch('Doctor_Scripts/PatientTests.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(datsToSend)
    })
        .then(response => response.json())
        .then(data => {
            if (data.status === "success" && Array.isArray(data.data)) {
                testsTable.innerHTML = ""; // Wyczyść tabelę przed dodaniem nowych danych
                data.data.forEach(test => {
                    testsTable.innerHTML += `
                        <tr>
                            <td>
                                <input type="text" id="NazwaBadania${test.IDBadania}" name="NazwaBadania" value="${test.NazwaBadania}">
                            </td>
                            <td>
                                <input type="text" id="WynikBadania${test.IDBadania}" name="WynikBadania" value="${test.WynikBadania}">
                            </td>
                            <td>
                                <input type="datetime-local" id="DataBadania${test.IDBadania}" name="DataBadania" value="${test.DataBadania}">
                            </td>
                            <td>
                                <input type="hidden" id="IdBadania${test.IDBadania}" name="IdBadania" value="${test.IDBadania}">
                                <button type="button" onclick="submitTest(${test.IDBadania})">Zapisz</button>
                            </td>
                        </tr>
                    `;
                });

                // Dodaj przycisk "Dodaj nowe badanie"
                testsTable.innerHTML += `
                    <tr>
                        <td colspan="4">
                            <button onclick="openTestModal(${IDWizyty})">Dodaj nowe badanie</button>
                        </td>
                    </tr>
                `;
            } else {
                console.error('Unexpected response structure:', data);
            }
        })
        .catch(error => {
            console.error('Wystąpił błąd:', error);
        });
}

function submitTest(IDBadania) {
    // Pobierz dane z formularza na podstawie IDBadania
    const nazwaBadania = document.getElementById(`NazwaBadania${IDBadania}`).value;
    const wynikBadania = document.getElementById(`WynikBadania${IDBadania}`).value;
    const dataBadania = document.getElementById(`DataBadania${IDBadania}`).value;

    const formData = new FormData();
    formData.append("IdBadania", IDBadania);
    formData.append("NazwaBadania", nazwaBadania);
    formData.append("WynikBadania", wynikBadania);
    formData.append("DataBadania", dataBadania);

    fetch('Doctor_Scripts/BadaniaEdit.php', {
        method: 'POST',
        body: formData
    })
        .then(response => response.text())
        .then(data => {
            console.log("Odpowiedź z serwera:", data);
            alert("Dane zostały zaktualizowane pomyślnie!");
        })
        .catch(error => {
            console.error("Wystąpił błąd:", error);
        });
}

function openTestModal(IDWizyty) {
    console.log("Otwieranie okienka dla wizyty:", IDWizyty); // Debugging
    const modal = document.getElementById("addTestModal");
    const overlay = document.getElementById("testModalOverlay");

    modal.style.display = "block";
    overlay.style.display = "block";
    window.currentVisitID = IDWizyty; // Ustawienie globalnego ID wizyty
}

function closeTestModal() {
    const modal = document.getElementById("addTestModal");
    const overlay = document.getElementById("testModalOverlay");
    modal.style.display = "none";
    overlay.style.display = "none";
}

function submitNewTest() {
    const nazwaBadania = document.getElementById("NazwaBadania").value;
    const wynikBadania = document.getElementById("WynikBadania").value;
    let dataBadania = document.getElementById("DataBadania").value;

    if (!window.currentVisitID) {
        alert("Brak ID wizyty!");
        return;
    }

    if (!nazwaBadania || !wynikBadania || !dataBadania) {
        alert("Wszystkie pola są wymagane!");
        return;
    }

    // Poprawny format dla SQL Server: "YYYY-MM-DD HH:mm"
    dataBadania = dataBadania.replace('T', ' ');

    const formData = new FormData();
    formData.append("WizytaID", window.currentVisitID);
    formData.append("NazwaBadania", nazwaBadania);
    formData.append("WynikBadania", wynikBadania);
    formData.append("DataBadania", dataBadania);

    fetch('Doctor_Scripts/AddTest.php', {
        method: 'POST',
        body: formData
    })
        .then(response => response.json())
        .then(data => {
            if (data.status === "success") {
                alert("Badanie zostało dodane pomyślnie!");
                closeTestModal();
                ShowTests(window.currentVisitID);
            } else {
                console.error("Szczegóły błędu:", data);
                console.log("Wystąpił błąd podczas dodawania badania:\n" +
                    (data.message || "") +
                    (data.details ? "\n" + JSON.stringify(data.details) : "") +
                    (data.debug ? "\nDebug: " + JSON.stringify(data.debug) : ""));
            }
        })
        .catch(error => {
            console.error("Wystąpił błąd:", error);
            alert("Wystąpił błąd podczas dodawania badania.");
        });
}