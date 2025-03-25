USE HMS;
GO

-- Insert data into Departments
INSERT INTO Departments (Nazwa, Adres, LiczbaLozek)
VALUES 
('Cardiology', '123 Heart St.', 50),
('Neurology', '456 Brain Ave.', 40),
('Orthopedics', '789 Bone Rd.', 30);

-- Insert data into Patients
INSERT INTO Patients (Pesel, Imie, Nazwisko, Adres, Telefon, DataUrodzenia, DepartmentsId)
VALUES 
('12345678901', 'John', 'Doe', '123 Main St.', '123456789', '1980-05-15', 1),
('98765432109', 'Jane', 'Smith', '456 Elm St.', '987654321', '1990-07-20', 2),
('45678912345', 'Alice', 'Johnson', '789 Oak St.', '456789123', '1975-03-10', 3);

-- Insert data into Doctors
INSERT INTO Doctors (Imie, Specjalizacja, NrLicencji, Telefon)
VALUES 
('Dr. Adam', 'Cardiologist', 'CARD123', '111222333'),
('Dr. Eve', 'Neurologist', 'NEURO456', '444555666'),
('Dr. Bob', 'Orthopedic Surgeon', 'ORTH789', '777888999');

-- Insert data into Medications
INSERT INTO Medications (Nazwa, Dostepnosc, Producent, TerminWaznosci)
VALUES 
('Aspirin', 100, 'PharmaCorp', '2025-12-31'),
('Ibuprofen', 200, 'MediLife', '2026-06-30'),
('Paracetamol', 150, 'HealthPlus', '2024-09-15');

-- Insert data into Prescriptions
INSERT INTO Prescriptions (KodLeku, Dawka, Dawkowanie, PatientsId)
VALUES 
(1, '500mg', 'Twice a day', 1),
(2, '200mg', 'Once a day', 2),
(3, '1000mg', 'Three times a day', 3);

-- Insert data into Appointments
INSERT INTO Appointments (Data, Diagnoza, DoctorsID, PatientsID)
VALUES 
('2025-03-01 10:00:00', 'High blood pressure', 1, 1),
('2025-03-02 11:30:00', 'Migraine', 2, 2),
('2025-03-03 14:00:00', 'Fractured arm', 3, 3);

-- Insert data into LabTest
INSERT INTO LabTest (TypBadania, Wynik, Data, AppointmentsID, AppointmentsData)
VALUES 
('Blood Test', 'Normal', '2025-03-01 12:00:00', 1, '2025-03-01 10:00:00'),
('MRI', 'No abnormalities', '2025-03-02 13:00:00', 2, '2025-03-02 11:30:00'),
('X-Ray', 'Fracture detected', '2025-03-03 15:00:00', 3, '2025-03-03 14:00:00');

-- Insert data into MedicalStaff
INSERT INTO MedicalStaff (Pielegniarki_Ilosc, Laboranci_Ilosc, TechnicyMedyczni_Ilosc, DepartmentsID)
VALUES 
(10, 5, 3, 1),
(8, 4, 2, 2),
(6, 3, 1, 3);

SELECT 
 *
FROM 
    Appointments a
LEFT JOIN Doctors d ON a.DoctorsID = d.ID
LEFT JOIN Patients p ON a.PatientsID = p.ID
LEFT JOIN Departments dep ON p.DepartmentsId = dep.ID
LEFT JOIN Prescriptions pr ON pr.PatientsId = p.ID
LEFT JOIN Medications m ON pr.KodLeku = m.ID
LEFT JOIN LabTest lt ON lt.AppointmentsID = a.ID AND lt.AppointmentsData = a.Data;