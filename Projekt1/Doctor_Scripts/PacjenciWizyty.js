document.getElementById("ListaPacjentow").addEventListener("change", async function () {
    var appointmentsTable = document.getElementById("WizytyBody");
    var selectedPatient = this.value;

    const datsToSend = {
        ID: selectedPatient,
    };
    fetch('Doctor_Scripts/PatientAppointments.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(datsToSend)
    })
        .then(response => response.json())
        .then(data => {
            if (data.status === "success" && Array.isArray(data.data)) {
                appointmentsTable.innerHTML = ""; // Wyczyść tabelę przed dodaniem nowych danych
                data.data.forEach(appointment => {
                    appointmentsTable.innerHTML += `
                        <tr id="Dane" onclick="ShowTests(${appointment.IdWizyty}),ShowPrescriptions(${appointment.IdWizyty})" name="Dane">
                            <td>${appointment.DataWizyty}</td>
                            <td>
                                <form class="updateForm">
                                    <textarea id="Diagnoza${appointment.IdWizyty}" name="Diagnoza" max="255">${appointment.Diagnoza}</textarea>
                                    <input type="hidden" id="IDWizyty" name="IDWizyty" value="${appointment.IdWizyty}">
                                    <br>
                                    <button type="submit">Zapisz</button>
                                </form> 
                            </td>
                            
                        </tr>`;
                });

                // Dodaj obsługę formularzy po ich wygenerowaniu
                document.querySelectorAll(".updateForm").forEach(form => {
                    form.addEventListener("submit", function (e) {
                        e.preventDefault(); // Zatrzymaj domyślne działanie formularza
                        const formData = new FormData(this); // Pobierz dane z formularza

                        fetch('Doctor_Scripts/WizytyEdit.php', {
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
                    });
                });
            } else {
                console.error('Unexpected response structure:', data);
            }
        })
        .catch(error => {
            console.error('Wystąpił błąd:', error);
        });
});