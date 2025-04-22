CREATE DATABASE Sklep;
GO

USE Sklep;
GO

-- Tabela Klienci
CREATE TABLE Klienci (
    KlientID INT IDENTITY(1,1) PRIMARY KEY,
    Imie NVARCHAR(50),
    Nazwisko NVARCHAR(50),
    DataUrodzenia DATE,
    MiastoID INT,
    Kraj NVARCHAR(50)
);

-- Tabela Zamowienia
CREATE TABLE Zamowienia (
    ZamowienieID INT IDENTITY(1,1) PRIMARY KEY,
    KlientID INT,
    DataZamowienia DATE,
    FOREIGN KEY (KlientID) REFERENCES Klienci(KlientID)
);

-- Tabela Produkty
CREATE TABLE Produkty (
    ProduktID INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa NVARCHAR(100),
    Cena DECIMAL(10,2),
    StanMagazynowy INT
);

-- Tabela ZamowieniaZawartosc
CREATE TABLE ZamowieniaZawartosc (
    ZamowienieID INT,
    ProduktID INT,
    Ilosc INT,
    FOREIGN KEY (ZamowienieID) REFERENCES Zamowienia(ZamowienieID),
    FOREIGN KEY (ProduktID) REFERENCES Produkty(ProduktID)
);

-- Tabela Pracownicy
CREATE TABLE Pracownicy (
    PracownikID INT IDENTITY(1,1) PRIMARY KEY,
    Imie NVARCHAR(50),
    Nazwisko NVARCHAR(50),
    CelSprzedazy DECIMAL(10,2)
);

-- Tabela Miasta
CREATE TABLE Miasta (
    MiastoID INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa NVARCHAR(100)
);

-- Dodanie klucza obcego do tabeli Klienci
ALTER TABLE Klienci
ADD FOREIGN KEY (MiastoID) REFERENCES Miasta(MiastoID);

-- Wstawianie danych testowych
INSERT INTO Miasta (Nazwa) VALUES ('Warszawa'), ('Kraków'), ('Gdańsk'), ('Wrocław'), ('Poznań');

INSERT INTO Klienci (Imie, Nazwisko, DataUrodzenia, MiastoID, Kraj) VALUES 
('Jan', 'Kowalski', '1990-03-22', 1, 'Polska'),
('Anna', 'Nowak', '2005-07-10', 2, 'Polska'),
('Piotr', 'Zieliński', '1985-12-01', 3, 'Polska'),
('Ewa', 'Wiśniewska', '2000-05-20', 4, 'Polska'),
('Tomasz', 'Lewandowski', '1995-08-15', 5, 'Polska');

INSERT INTO Produkty (Nazwa, Cena, StanMagazynowy) VALUES 
('Laptop', 3000.00, 20),
('Telefon', 1500.00, 50),
('Klawiatura', 100.00, 5),
('Myszka', 50.00, 30),
('Monitor', 800.00, 10);

INSERT INTO Zamowienia (KlientID, DataZamowienia) VALUES 
(1, '2025-03-10'),
(2, '2025-02-15'),
(3, '2025-03-25'),
(4, '2025-03-05'),
(5, '2025-03-20');

INSERT INTO ZamowieniaZawartosc (ZamowienieID, ProduktID, Ilosc) VALUES 
(1, 1, 2),
(1, 2, 1),
(2, 3, 5),
(3, 1, 1),
(4, 4, 3),
(5, 5, 2);

INSERT INTO Pracownicy (Imie, Nazwisko, CelSprzedazy) VALUES 
('Marek', 'Nowicki', 5000.00),
('Karolina', 'Wiśniewska', 7000.00),
('Paweł', 'Kaczmarek', 6000.00),
('Magdalena', 'Jankowska', 5500.00);