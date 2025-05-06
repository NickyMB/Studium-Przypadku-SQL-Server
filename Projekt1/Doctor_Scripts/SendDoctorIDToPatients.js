document.getElementById("ListaLekarzy").addEventListener("change", function () {
    var selectedDoctor = this.value;
    const postData = {
        ID: selectedDoctor
    };
    var xhr = new XMLHttpRequest();
    document.getElementById("ListaPacjentow").innerHTML = ""; // Clear the patient list on page load
    var option = document.createElement("option");
    option.value = "0";
    option.textContent = "-- Brak Pacjentów --";
    document.getElementById("ListaPacjentow").appendChild(option);
    xhr.open("POST", "Doctor_Scripts/PatientList.PHP", true);
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.onload = function () {
        console.log("Odpowiedź z serwera:", xhr.responseText); // Debugging line
        if (xhr.status === 200) {
            try {
                const response = JSON.parse(xhr.responseText);
                if (response.status === "success") {
                    // Handle success response
                    response.data.forEach(function (item) {
                        var option = document.createElement("option");
                        option.value = item.id;
                        option.textContent = item.name;
                        document.getElementById("ListaPacjentow").appendChild(option);
                    });
                } else {
                    console.error("Błąd w odpowiedzi serwera:", response.message); // Debugging line
                }
            } catch (e) {
                console.error("Błąd podczas parsowania odpowiedzi:", e); // Debugging line
                console.log("Odpowiedź z serwera:", xhr.responseText); // Debugging line

            }
        } else {
            console.error("Błąd żądania AJAX:", xhr.status, xhr.statusText); // Debugging line
        }
    };
    xhr.send(JSON.stringify(postData));
});
