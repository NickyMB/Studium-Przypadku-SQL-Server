CREATE DATABASE HMS;
GO
USE HMS;
GO

-- Partycje
CREATE PARTITION FUNCTION PF_Appointments_ByYear(DATETIME)
AS RANGE RIGHT FOR VALUES ('2023-01-01', '2024-01-01', '2025-01-01', '2026-01-01', '2027-01-01');
GO
CREATE PARTITION SCHEME PF_Appointments
AS PARTITION PF_Appointments_ByYear
ALL TO ([PRIMARY]);
GO

-- Tabele Główne
CREATE TABLE [Departments]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Nazwa] VARCHAR(50) NOT NULL,
    [Adres] VARCHAR(100) NOT NULL,
    [LiczbaLozek] INT NOT NULL
);
GO

CREATE TABLE [Patients]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Pesel] CHAR(11) NOT NULL UNIQUE,
    [Imie] VARCHAR(50) NOT NULL,
    [Nazwisko] VARCHAR(50) NOT NULL,
    [Adres] VARCHAR(100) NOT NULL,
    [Telefon] VARCHAR(15),
    [DataUrodzenia] DATE NOT NULL,
    [DepartmentsId] INT,
    FOREIGN KEY ([DepartmentsId]) REFERENCES [Departments]([ID]) ON DELETE CASCADE
);
GO

CREATE TABLE [Doctors]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Imie] VARCHAR(50) NOT NULL,
    [Specjalizacja] VARCHAR(100) NOT NULL,
    [NrLicencji] VARCHAR(50) NOT NULL UNIQUE,
    [Telefon] VARCHAR(15) NOT NULL
);
GO

CREATE TABLE [Medications]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Nazwa] VARCHAR(50) NOT NULL,
    [Dostepnosc] INT NOT NULL,
    [Producent] VARCHAR(100) NOT NULL,
    [TerminWaznosci] DATE NOT NULL
);
GO

CREATE TABLE [Prescriptions]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [KodLeku] INT,
    [Dawka] VARCHAR(50) NOT NULL,
    [Dawkowanie] VARCHAR(50) NOT NULL,
    [PatientsId] INT,
    FOREIGN KEY ([PatientsId]) REFERENCES [Patients]([ID]) ON DELETE CASCADE,
    FOREIGN KEY ([KodLeku]) REFERENCES [Medications]([ID]) ON DELETE CASCADE
);
GO

CREATE TABLE [Appointments]
(
    [ID] INT IDENTITY (1, 1) NOT NULL,
    [Data] DATETIME NOT NULL,
    [Diagnoza] VARCHAR(255),
    [DoctorsID] INT,
    [PatientsID] INT,
    PRIMARY KEY ([ID], [Data]),
    FOREIGN KEY ([DoctorsID]) REFERENCES [Doctors]([ID]) ON DELETE CASCADE,
    FOREIGN KEY ([PatientsID]) REFERENCES [Patients]([ID]) ON DELETE CASCADE
)
ON PF_Appointments (Data);
GO

CREATE TABLE [LabTest]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [TypBadania] VARCHAR(50) NOT NULL,
    [Wynik] VARCHAR(50) NOT NULL,
    [Data] DATETIME NOT NULL,
    [AppointmentsID] INT,
    [AppointmentsData] DATETIME NOT NULL,
    FOREIGN KEY ([AppointmentsID],[AppointmentsData]) REFERENCES [Appointments]([ID], [Data]) ON DELETE CASCADE
);
GO

CREATE TABLE [MedicalStaff]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Pielegniarki_Ilosc] INT,
    [Laboranci_Ilosc] INT,
    [TechnicyMedyczni_Ilosc] INT,
    [DepartmentsID] INT,
    FOREIGN KEY ([DepartmentsID]) REFERENCES [Departments]([ID]) ON DELETE CASCADE
);
GO

-- Indeksy
CREATE INDEX IX_Appointments_Doctors_Patients ON Appointments(DoctorsID, PatientsID);
GO
CREATE INDEX IX_Appointments_Doctors_FK ON Appointments(DoctorsID);
GO
CREATE INDEX IX_Appointments_Patients_FK ON Appointments(PatientsID);
GO
CREATE INDEX IX_Patients_Departments_FK ON Patients(DepartmentsID);
GO
CREATE INDEX IX_Prescriptions_Patients_FK ON Prescriptions(PatientsID);
GO
CREATE INDEX IX_Prescriptions_Medications_FK ON Prescriptions(KodLeku);
GO
CREATE INDEX IX_Prescriptions_Patients_Medications ON Prescriptions(PatientsID, KodLeku);
GO
CREATE INDEX IX_LabTest_Appointments_FK ON LabTest(AppointmentsID);
GO
CREATE INDEX IX_MedicalStaff_Departments_FK ON MedicalStaff(DepartmentsID);
GO

-- Funkcje
CREATE OR ALTER FUNCTION AverageTestPerPatient()
RETURNS TABLE
AS
RETURN
(
  SELECT AVG(AppointmentCount) AS AvgAppointments, CONCAT(SubQuery.Imie,' ',SubQuery.Nazwisko) AS Pacjent
  FROM (
    SELECT COUNT(*) AS AppointmentCount, PatientsID, Patients.Imie, Patients.Nazwisko
    FROM Appointments 
    JOIN Patients ON Appointments.PatientsID = Patients.ID
    GROUP BY PatientsID, Patients.Imie, Patients.Nazwisko
  ) AS SubQuery
  GROUP BY SubQuery.Imie, SubQuery.Nazwisko
);
GO

CREATE OR ALTER FUNCTION MostCommonDoc()
RETURNS TABLE
AS
RETURN
(
    SELECT AVG(AppointmentCount) as AvgAppointments, SubQuery.Imie
    FROM (
        SELECT COUNT(*) as AppointmentCount, DoctorsID, Doctors.Imie
        FROM Appointments JOIN Doctors ON Appointments.DoctorsID = Doctors.ID
        GROUP BY DoctorsID, Doctors.Imie
    ) as SubQuery 
    GROUP BY DoctorsID, SubQuery.Imie 
);
GO

CREATE OR ALTER FUNCTION GetDepartmentID(@Name VARCHAR(max))
RETURNS INT
AS
BEGIN
    DECLARE @DepartmentID INT;
    SELECT @DepartmentID = ID FROM Departments WHERE Nazwa = @Name;
    RETURN @DepartmentID;
END
GO

-- Trigger
CREATE OR ALTER TRIGGER LessMedicine
ON Prescriptions
FOR INSERT
AS
BEGIN
    UPDATE Medications
    SET Dostepnosc = Dostepnosc - x.Liczba
    FROM Medications m
    INNER JOIN (
        SELECT KodLeku, COUNT(*) AS Liczba
        FROM inserted
        WHERE KodLeku IS NOT NULL
        GROUP BY KodLeku
    ) x ON m.ID = x.KodLeku;
END
GO

-- Użytkownicy i role
CREATE LOGIN administrator WITH PASSWORD = 'admin1';
GO
CREATE USER administrator FOR LOGIN administrator;
GO
ALTER ROLE db_owner ADD MEMBER administrator;
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO administrator;
GO

CREATE ROLE lekarze;
GO
GRANT SELECT, INSERT, UPDATE ON dbo.Appointments TO lekarze;
GO
GRANT SELECT ON dbo.Patients TO lekarze;
GO
GRANT SELECT ON dbo.Doctors TO lekarze;
GO
GRANT SELECT ON OBJECT::dbo.AverageTestPerPatient TO lekarze;
GO
GRANT SELECT ON OBJECT::dbo.MostCommonDoc TO lekarze;
GO
GRANT SELECT, INSERT, UPDATE ON dbo.Prescriptions TO lekarze;
GO
GRANT SELECT, UPDATE, INSERT ON dbo.LabTest TO lekarze;
GO
GRANT SELECT ON dbo.Medications TO lekarze;
GO
CREATE LOGIN Lekarz WITH PASSWORD = 'Lekarz1';
GO
CREATE USER Lekarz FOR LOGIN Lekarz;
GO
ALTER ROLE lekarze ADD MEMBER Lekarz;
GO

CREATE ROLE Pacjenci;
GO
GRANT SELECT, INSERT ON dbo.Appointments TO Pacjenci;
GO
GRANT SELECT ON dbo.Patients TO Pacjenci;
GO
GRANT SELECT ON dbo.Prescriptions TO Pacjenci;
GO
GRANT SELECT ON dbo.LabTest TO Pacjenci;
GO
GRANT SELECT ON dbo.Medications TO Pacjenci;
GO
GRANT SELECT ON dbo.Doctors TO Pacjenci;
GO
CREATE LOGIN Pacjent WITH PASSWORD = 'Pacjent1';
GO
CREATE USER Pacjent FOR LOGIN Pacjent;
GO
ALTER ROLE Pacjenci ADD MEMBER Pacjent;
GO

CREATE ROLE Farmaceuci;
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Medications TO Farmaceuci;
GO
CREATE LOGIN Farmaceuta WITH PASSWORD = 'Farmaceuta1';
GO
CREATE USER Farmaceuta FOR LOGIN Farmaceuta;
GO
ALTER ROLE Farmaceuci ADD MEMBER Farmaceuta;
GO

-- Dane przykładowe
INSERT INTO Departments (Nazwa, Adres, LiczbaLozek)
VALUES 
('Cardiology', '123 Heart St.', 50),
('Neurology', '456 Brain Ave.', 40),
('Orthopedics', '789 Bone Rd.', 30);
GO

INSERT INTO Patients (Pesel, Imie, Nazwisko, Adres, Telefon, DataUrodzenia, DepartmentsId)
VALUES 
('12345678901', 'John', 'Doe', '123 Main St.', '123456789', '1980-05-15', 1),
('98765432109', 'Jane', 'Smith', '456 Elm St.', '987654321', '1990-07-20', 2),
('45678912345', 'Alice', 'Johnson', '789 Oak St.', '456789123', '1975-03-10', 3);
GO

INSERT INTO Doctors (Imie, Specjalizacja, NrLicencji, Telefon)
VALUES 
('Dr. Adam', 'Cardiologist', 'CARD123', '111222333'),
('Dr. Eve', 'Neurologist', 'NEURO456', '444555666'),
('Dr. Bob', 'Orthopedic Surgeon', 'ORTH789', '777888999');
GO

INSERT INTO Medications (Nazwa, Dostepnosc, Producent, TerminWaznosci)
VALUES 
('Aspirin', 100, 'PharmaCorp', '2025-12-31'),
('Ibuprofen', 200, 'MediLife', '2026-06-30'),
('Paracetamol', 150, 'HealthPlus', '2024-09-15');
GO

INSERT INTO Prescriptions (KodLeku, Dawka, Dawkowanie, PatientsId)
VALUES 
(1, '500mg', 'Twice a day', 1),
(2, '200mg', 'Once a day', 2),
(3, '1000mg', 'Three times a day', 3);
GO

INSERT INTO Appointments (Data, Diagnoza, DoctorsID, PatientsID)
VALUES 
('2025-04-26 10:00:00', 'High blood pressure', 1, 1),
('2025-04-26 11:30:00', 'Migraine', 2, 2),
('2025-04-26 14:00:00', 'Fractured arm', 3, 3);
GO

INSERT INTO LabTest (TypBadania, Wynik, Data, AppointmentsID, AppointmentsData)
VALUES 
('Blood Test', 'Normal', '2025-04-26 12:00:00', 1, '2025-04-26 10:00:00'),
('MRI', 'No abnormalities', '2025-04-26 13:00:00', 2, '2025-04-26 11:30:00'),
('X-Ray', 'Fracture detected', '2025-04-26 15:00:00', 3, '2025-04-26 14:00:00');
GO

INSERT INTO MedicalStaff (Pielegniarki_Ilosc, Laboranci_Ilosc, TechnicyMedyczni_Ilosc, DepartmentsID)
VALUES 
(10, 5, 3, 1),
(8, 4, 2, 2),
(6, 3, 1, 3);
GO

-- Aktywacja triggera (opcjonalnie, bo po CREATE jest domyślnie aktywny)
ENABLE TRIGGER LessMedicine ON Prescriptions;
GO