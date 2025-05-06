function ShowPrescriptions(IDWizyty) {
    const testTable = document.getElementById("ReceptyBody");
    const dataToSend = { IDWizyty: IDWizyty };

    fetch('Doctor_Scripts/PatientPrescriptions.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(dataToSend)
    })
        .then(response => response.json())
        .then(data => {
            if (data.status === "success" && Array.isArray(data.data)) {
                testTable.innerHTML = ""; // Wyczyść tabelę przed dodaniem nowych danych

                // Pobierz listę leków
                fetch('Doctor_Scripts/Medications.php', { method: 'GET' })
                    .then(response => response.json())
                    .then(medicationsData => {
                        if (medicationsData.status === "success" && Array.isArray(medicationsData.data)) {
                            const medications = medicationsData.data;

                            // Generuj wiersze tabeli
                            data.data.forEach(test => {
                                let options = medications.map(
                                    med => `<option value="${med.UId}" ${med.UId == test.KodLeku ? 'selected' : ''}>${med.UNazwa}</option>`
                                ).join("");

                                testTable.innerHTML += `
                                    <tr>
                                        <td>
                                            ${test.NazwaLeku}
                                        </td>
                                        <td>
                                            ${test.Dawka}
                                        </td>
                                        <td>
                                            ${test.Dawkowanie}
                                        </td>
                                    </tr>
                                `;
                            });

                            // Dodaj przycisk do otwierania okienka
                            testTable.innerHTML += `
                                <tr>
                                    <td colspan="3">
                                        <button onclick="openModal(${IDWizyty})">Dodaj nową receptę</button>
                                    </td>
                                </tr>
                            `;
                        }
                    });
            }
        });
}

function submitPrescription(IDRecepty) {
    const lekID = document.getElementById(`Lek${IDRecepty}`).value;
    const dawka = document.getElementById(`Dawka${IDRecepty}`).value;
    const dawkowanie = document.getElementById(`Dawkowanie${IDRecepty}`).value;

    const formData = new FormData();
    formData.append("IDRecepty", IDRecepty);
    formData.append("LekID", lekID);
    formData.append("Dawka", dawka);
    formData.append("Dawkowanie", dawkowanie);

    fetch('Doctor_Scripts/DoctorPrescriptionsEdit.php', {
        method: 'POST',
        body: formData
    })
        .then(response => response.json())
        .then(data => {
            if (data.status === "success") {
                alert("Dane zostały zaktualizowane pomyślnie!");
            } else {
                alert("Wystąpił błąd podczas zapisywania danych.");
            }
        });
}

function addPrescription(IDWizyty) {
    const formData = new FormData();
    formData.append("WizytaID", IDWizyty);

    fetch('Doctor_Scripts/DoctorAddPrescriptions.php', {
        method: 'POST',
        body: formData
    })
        .then(response => response.json())
        .then(data => {
            if (data.status === "success") {
                ShowPrescriptions(IDWizyty); // Odśwież tabelę
            } else {
                alert("Wystąpił błąd podczas dodawania recepty.");
            }
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

let currentVisitID = null; // Przechowuje ID aktualnej wizyty

function openModal(IDWizyty) {
    currentVisitID = IDWizyty; // Ustaw ID wizyty
    const modal = document.getElementById("addPrescriptionModal");
    const overlay = document.getElementById("modalOverlay");

    // Pobierz listę leków z serwera
    fetch('Doctor_Scripts/Medications.php', { method: 'GET' })
        .then(response => response.json())
        .then(data => {
            if (data.status === "success" && Array.isArray(data.data)) {
                const select = document.getElementById("Lek");
                select.innerHTML = '<option value="">-- Wybierz lek --</option>';
                data.data.forEach(med => {
                    select.innerHTML += `<option value="${med.UId}">${med.UNazwa}</option>`;
                });
            } else {
                alert("Wystąpił błąd podczas pobierania listy leków.");
            }
        });

    modal.style.display = "block";
    overlay.style.display = "block";
}

function closeModal() {
    const modal = document.getElementById("addPrescriptionModal");
    const overlay = document.getElementById("modalOverlay");
    modal.style.display = "none";
    overlay.style.display = "none";
}

function submitNewPrescription() {
    const lekID = document.getElementById("Lek").value;
    const dawka = document.getElementById("Dawka").value;
    const dawkowanie = document.getElementById("Dawkowanie").value;

    if (!lekID || !dawka || !dawkowanie) {
        alert("Wszystkie pola są wymagane!");
        return;
    }
    var currentPatientID = document.getElementById("ListaPacjentow").value; // Pobierz ID pacjenta

    const formData = new FormData();
    formData.append("LekID", lekID);
    formData.append("Dawka", dawka);
    formData.append("Dawkowanie", dawkowanie);
    formData.append("PatientID", currentPatientID);
    console.log("ID pacjenta:", currentPatientID, lekID, dawka, dawkowanie); // Debugging line
    fetch('Doctor_Scripts/DoctorAddPrescriptions.php', {
        method: 'POST',
        body: formData
    })
        .then(response => response.json())
        .then(data => {
            if (data.status === "success") {
                alert("Recepta została dodana pomyślnie!");
                closeModal();
                ShowPrescriptions(currentVisitID); // Odśwież tabelę recept
            } else {
                alert("Wystąpił błąd podczas dodawania recepty.");
            }
        })
        .catch(error => {
            console.error("Wystąpił błąd:", error);
            alert("Wystąpił błąd podczas dodawania recepty.");
        });
}