
CREATE DATABASE HMS;

Use HMS;
Go
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
    [Pesel] CHAR(11) NOT NULL,
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
    [NrLicencji] VARCHAR(50) NOT NULL,
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
    [KodLeku] INT NOT NULL,
    [Dawka] VARCHAR(50) NOT NULL,
    [Dawkowanie] VARCHAR(50) NOT NULL,
    [PatientsId] INT,
    FOREIGN KEY ([PatientsId]) REFERENCES [Patients]([ID]),
    FOREIGN KEY ([KodLeku]) REFERENCES [Medications]([ID]),

);

CREATE TABLE [Appointments]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Data] DATETIME NOT NULL,
    [Diagnoza] VARCHAR(255) NOT NULL,
    [DoctorsId] INT,
    [PatientsId] INT,
    FOREIGN KEY ([DoctorsId]) REFERENCES [Doctors]([ID]),
    FOREIGN KEY ([PatientsId]) REFERENCES [Patients]([ID]),
);
CREATE TABLE [LabTest]
(
    [ID] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [TypBadania] VARCHAR(50) NOT NULL,
    [Wynik] VARCHAR(50) NOT NULL,
    [Data] DATETIME NOT NULL,
    [AppointmentsID] INT,
    FOREIGN KEY ([AppointmentsId]) REFERENCES [Appointments]([ID]),

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

CREATE INDEX IX_Appointments_Doctors_FK
ON Appointments(DoctorsID);

CREATE INDEX IX_Appointments_Patients_FK
ON Appointments(PatientsID);
    -- Tabela Patients
CREATE INDEX IX_Patients_Departments_FK
ON Patients(DepartmentsID);
    -- Tabela Prescriptions
CREATE INDEX IX_Prescriptions_Patients_FK
ON Prescriptions(PatientsID);

CREATE INDEX IX_Prescriptions_Medications_FK
ON Prescriptions(KodLeku);

CREATE INDEX IX_Prescriptions_Patients_Medications
ON Prescriptions(PatientsID, KodLeku);
    -- Tabela LabTest
CREATE INDEX IX_LabTest_Appointments_FK
ON LabTest(AppointmentsID);
    --Tabela MedicallStaff
CREATE INDEX IX_MedicalStaff_Departments_FK
ON MedicalStaff(DepartmentsID);
