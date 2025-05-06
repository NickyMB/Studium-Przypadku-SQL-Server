CREATE DATABASE HMS;
go
Use HMS;
go

-- Partycje
--Appointments

CREATE PARTITION FUNCTION PF_Appointments_ByYear(DATETIME)
AS RANGE RIGHT FOR VALUES ('2023-01-01', '2024-01-01', '2025-01-01', '2026-01-01', '2027-01-01');
go
CREATE PARTITION SCHEME PF_Appointments
AS PARTITION PF_Appointments_ByYear
ALL TO ([PRIMARY]);  

go
-- Tabele Główne
CREATE TABLE [Departments]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Nazwa] VARCHAR(50) NOT NULL,
    [Adres] VARCHAR(100) NOT NULL,
    [LiczbaLozek] INT NOT NULL,
);
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
    FOREIGN KEY ([DepartmentsId]) REFERENCES [Departments]([ID]),
);

CREATE TABLE [Doctors]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Imie] VARCHAR(50) NOT NULL,
    [Specjalizacja] VARCHAR(100) NOT NULL,
    [NrLicencji] VARCHAR(50) NOT NULL UNIQUE,
    [Telefon] VARCHAR(15) NOT NULL,

);

CREATE TABLE [Medications]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Nazwa] VARCHAR(50) NOT NULL,
    [Dostepnosc] INT NOT NULL,
    [Producent] VARCHAR(100) NOT NULL,
    [TerminWaznosci] DATE NOT NULL,
);
CREATE TABLE [Prescriptions]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [KodLeku] INT,
    [Dawka] VARCHAR(50) NOT NULL,
    [Dawkowanie] VARCHAR(50) NOT NULL,
    [PatientsId] INT,
    FOREIGN KEY ([PatientsId]) REFERENCES [Patients]([ID]),
    FOREIGN KEY ([KodLeku]) REFERENCES [Medications]([ID]) on delete CASCADE,
);

CREATE TABLE [Appointments]
(
    [ID] INT IDENTITY (1, 1) NOT NULL,
    [Data] DATETIME NOT NULL ,
    [Diagnoza] VARCHAR(255),
    [DoctorsID] INT,
    [PatientsID] INT,
    PRIMARY KEY ([ID], [Data]),
    FOREIGN KEY ([DoctorsID]) REFERENCES [Doctors]([ID]),
    FOREIGN KEY ([PatientsID]) REFERENCES [Patients]([ID]),
)
ON PF_Appointments (Data);

CREATE TABLE [LabTest]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [TypBadania] VARCHAR(50) NOT NULL,
    [Wynik] VARCHAR(50) NOT NULL,
    [Data] DATETIME NOT NULL,
    [AppointmentsID] INT,
    FOREIGN KEY ([AppointmentsID],[AppointmentsData] ) REFERENCES [Appointments]([ID], [Data]),

);
CREATE TABLE [MedicalStaff]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Pielegniarki_Ilosc] INT,
    [Laboranci_Ilosc] INT,
    [TechnicyMedyczni_Ilosc] INT,

    [DepartmentsID] INT,
    FOREIGN KEY ([DepartmentsID]) REFERENCES [Departments]([ID]),
);

-- Tabele Pośrednie


-- Index Klucza obcego
-- Tabela Appointemts
CREATE INDEX IX_Appointments_Doctors_Patients
ON Appointments(DoctorsID, PatientsID);
go
CREATE INDEX IX_Appointments_Doctors_FK
ON Appointments(DoctorsID);
go
CREATE INDEX IX_Appointments_Patients_FK
ON Appointments(PatientsID);
 go
-- Tabela Patients
CREATE INDEX IX_Patients_Departments_FK
ON Patients(DepartmentsID);
  go
-- Tabela Prescriptions
CREATE INDEX IX_Prescriptions_Patients_FK
ON Prescriptions(PatientsID);
go
CREATE INDEX IX_Prescriptions_Medications_FK
ON Prescriptions(KodLeku);
go
CREATE INDEX IX_Prescriptions_Patients_Medications
ON Prescriptions(PatientsID, KodLeku);
go
-- Tabela LabTest
CREATE INDEX IX_LabTest_Appointments_FK
ON LabTest(AppointmentsID);
go
--Tabela MedicallStaff
CREATE INDEX IX_MedicalStaff_Departments_FK
ON MedicalStaff(DepartmentsID);
go
--Użytownicy
--Administrator
CREATE LOGIN administrator WITH PASSWORD = 'admin1';
go
CREATE USER administrator FOR LOGIN administrator;
go
ALTER ROLE db_owner ADD MEMBER administrator;
go
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO administrator;
go

-- Lekarz
CREATE ROLE lekarze;
go
GRANT SELECT, INSERT, UPDATE ON dbo.Appointments TO lekarze;
go
GRANT SELECT ON dbo.Patients TO lekarze;
go
GRANT SELECT ON dbo.Doctors TO lekarze;
go
GRANT SELECT ON OBJECT::dbo.AverageTestPerPatient TO lekarze;
go
GRANT SELECT ON OBJECT::dbo.MostCommonDoc TO lekarze;
go
GRANT SELECT, INSERT, UPDATE ON dbo.Prescriptions TO lekarze;
go
GRANT SELECT,UPDATE,INSERT ON dbo.LabTest TO lekarze;
go
GRANT SELECT ON dbo.Medications TO lekarze;
go
CREATE LOGIN Lekarz WITH PASSWORD = 'Lekarz1';
go
CREATE USER Lekarz FOR LOGIN Lekarz;

go
ALTER ROLE lekarze ADD MEMBER Lekarz;
go
--Pacjent
CREATE ROLE Pacjenci
go
GRANT SELECT,INSERT ON dbo.Appointments TO Pacjenci;
go
GRANT SELECT ON dbo.Patients TO Pacjenci;
go
GRANT SELECT ON dbo.Prescriptions TO Pacjenci;
go
GRANT SELECT ON dbo.LabTest TO Pacjenci;
go
GRANT SELECT ON dbo.Medications TO Pacjenci;
GO
grant select on dbo.doctors to Pacjenci;
go
CREATE LOGIN Pacjent WITH PASSWORD = 'Pacjent1';
go
CREATE USER Pacjent FOR LOGIN Pacjent;
go
ALTER ROLE Pacjenci ADD MEMBER Pacjent;
go

--Farmaceuta
CREATE ROLE Farmaceuci
go
GRANT SELECT,INSERT,UPDATE,DELETE on dbo.Medications To Farmaceuci;
go
CREATE LOGIN Farmaceuta WITH PASSWORD = 'Farmaceuta1';
go
CREATE USER Farmaceuta FOR LOGIN Farmaceuta;
go
ALTER ROLE Farmaceuci ADD MEMBER Farmaceuta;
go
CREATE OR ALTER FUNCTION GetDepartmentID(@Name VARCHAR(max))
RETURNS INT
AS
BEGIN
    DECLARE @DepartmentID INT;
    SELECT @DepartmentID = ID FROM Departments WHERE Nazwa = @Name;
    RETURN @DepartmentID;
END;

GO
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
select avg(AppointmentCount) as AvgAppointments, SubQuery.Imie
from (
    select count(*) as AppointmentCount, DoctorsID, Doctors.Imie
    from Appointments JOIN Doctors ON Appointments.DoctorsID = Doctors.ID
    group by DoctorsID,Doctors.Imie
) as SubQuery 
group by DoctorsID,SubQuery.Imie 
);
GO
CREATE OR ALTER TRIGGER LessMedicine
on Prescriptions
FOR INSERT
as
BEGIN
    SELECT KodLeku from inserted;
    SELECT Dostepnosc FROM Medications where ID=(SELECT KodLeku from inserted);
    UPDATE Medications SET Dostepnosc = Dostepnosc - 1 WHERE ID=(SELECT KodLeku from inserted);
    SELECT Dostepnosc FROM Medications where ID=(SELECT KodLeku from inserted);
end
