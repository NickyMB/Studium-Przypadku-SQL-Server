CREATE DATABASE HMS;

Use HMS;

-- Tabele Główne
CREATE TABLE [Departments]
(
    [Id] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Nazwa] VARCHAR(50) NOT NULL,
    [Adres] VARCHAR(100) NOT NULL,
    [LiczbaLozek] INT NOT NULL,
);
CREATE TABLE [Patients]
(
    [Id] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Pesel] TINYINT NOT NULL,
    [Imie] VARCHAR(50) NOT NULL,
    [Nazwisko] VARCHAR(50) NOT NULL,
    [Adres] VARCHAR(100) NOT NULL,
    [TELEFON] INT,
    [DataUrodzenia] DATE NOT NULL,

    [DepartmentsID] INT,
    FOREIGN KEY ([DepartmentsID]) REFERENCES [Departments]([Id]),
);

CREATE TABLE [Doctors]
(
    [Id] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Imie] VARCHAR(50) NOT NULL,
    [Specjalizajca] VARCHAR(100) NOT NULL,
    [NrLicencji] VARCHAR(50) NOT NULL,
    [Telefon] int NOT NULL,

);

CREATE TABLE [Medications]
(
    [Id] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Nazwa] VARCHAR(50) NOT NULL,
    [Dosepnosc] INT NOT NULL,
    [Producent] VARCHAR NOT NULL,
    [TerminWaznosci] DATE NOT NULL,
);
CREATE TABLE [Prescriptions]
(
    [Id] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [KodLeku] INT NOT NULL,
    [Dawka] VARCHAR(50) NOT NULL,
    [Dawkowanie] VARCHAR(50) NOT NULL,
    [PatientsId] INT,
    FOREIGN KEY ([PatientsId]) REFERENCES [Patients]([Id]),
    FOREIGN KEY ([KodLeku]) REFERENCES [Medications]([Id]),

);

CREATE TABLE [Appointments]
(
    [Id] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Data] DATETIME NOT NULL,
    [Diagnoza] VARCHAR NOT NULL,
    [DoctorsId] INT,
    [PatientsId] INT,
    FOREIGN KEY ([DoctorsId]) REFERENCES [Doctors]([Id]),
    FOREIGN KEY ([PatientsId]) REFERENCES [Patients]([Id]),
);
CREATE TABLE [LabTest]
(
    [Id] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [TypBadania] VARCHAR(50) NOT NULL,
    [Wynik] VARCHAR(50) NOT NULL,
    [Data] DATETIME NOT NULL,
    [AppointmentsID] INT,
    FOREIGN KEY ([AppointmentsId]) REFERENCES [Appointments]([Id]),

);
CREATE TABLE [MedicalStaff]
(
    [Id] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [Pielegniarki_Ilosc] INT,
    [Laboranci_Ilosc] VARCHAR(50),
    [TechnicyMedyczni_Ilosc] VARCHAR(50),

    [DepartmentsID] INT,
    FOREIGN KEY ([DepartmentsID]) REFERENCES [Departments]([Id]),
);

-- Tabele Pośrednie

CREATE TABLE [Patients_Prescriptions]
(
    [Id] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [PatientsId] INT NOT NULL,
    [AppointmentsId] INT NOT NULL,
    FOREIGN KEY ([PatientsId]) REFERENCES [Patients]([Id]),
    FOREIGN KEY ([AppointmentsId]) REFERENCES [Appointments]([Id]),
)
