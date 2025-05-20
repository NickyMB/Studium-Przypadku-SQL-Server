-- Tworzenie nowej bazy danych
CREATE DATABASE SklepDB;
GO
USE SklepDB;
GO

-- Tabela Klienci
CREATE TABLE Klienci
(
    ID INT PRIMARY KEY IDENTITY(1,1),
    Imie NVARCHAR(50),
    Nazwisko NVARCHAR(50),
    Email NVARCHAR(100) UNIQUE,
    Haslo NVARCHAR(100)
    -- potrzebne do zadania 10
);
GO

-- Tabela Produkty
CREATE TABLE Produkty
(
    ID INT PRIMARY KEY IDENTITY(1,1),
    Nazwa NVARCHAR(100),
    Cena DECIMAL(10,2),
    StanMagazynowy INT
);
GO

-- Tabela Zamówienia
CREATE TABLE Zamowienia
(
    ID INT PRIMARY KEY IDENTITY(1,1),
    KlientID INT,
    DataZamowienia DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Nowe',
    FOREIGN KEY (KlientID) REFERENCES Klienci(ID)
);
GO

-- Tabela Szczegóły Zamówienia
CREATE TABLE SzczegolyZamowienia
(
    ID INT PRIMARY KEY IDENTITY(1,1),
    ZamowienieID INT,
    ProduktID INT,
    Ilosc INT,
    Cena DECIMAL(10,2),
    FOREIGN KEY (ZamowienieID) REFERENCES Zamowienia(ID),
    FOREIGN KEY (ProduktID) REFERENCES Produkty(ID)
);
GO



-- Wstawienie przykładowych danych
INSERT INTO Klienci
    (Imie, Nazwisko, Email, Haslo)
VALUES
    ('Jan', 'Kowalski', 'jan.kowalski@example.com', 'Haslo1231'),
    ('Anna', 'Nowak', 'anna.nowak@example.com', 'Haslo1232');
GO

INSERT INTO Produkty
    (Nazwa, Cena, StanMagazynowy)
VALUES
    ('Laptop HP', 4200.00, 10),
    ('Telefon Xiaomi', 1900.00, 20),
    ('Mysz bezprzewodowa', 120.00, 50),
    ('Monitor ASUS', 850.00, 15);
GO

INSERT INTO Zamowienia
    (KlientID)
VALUES
    (1),
    (2);
GO

INSERT INTO SzczegolyZamowienia
    (ZamowienieID, ProduktID, Ilosc, Cena)
VALUES
    (1, 1, 1, 4200.00),
    (1, 2, 1, 1900.00),
    (2, 3, 2, 120.00);
GO
-- ; 1. 🛡 Trigger_LogZamowienia
-- ; Cel: Zapisz do tabeli logującej każde nowe zamówienie.
-- ; Typ: AFTER INSERT

-- Tworzenie tabeli logującej zamówienia
CREATE TABLE LogZamowienia
(
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ZamowienieID INT,
    KlientID INT,
    DataZamowienia DATETIME,
    Status NVARCHAR(20),
    DataLogu DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER Trigger_LogZamowienia
ON Zamowienia
AFTER INSERT
AS
BEGIN
    INSERT INTO LogZamowienia
        (ZamowienieID, KlientID, DataZamowienia, Status)
    SELECT
        i.ID,
        i.KlientID,
        i.DataZamowienia,
        i.Status
    FROM inserted i;
END
GO

SELECT *
FROM LogZamowienia;




-- ; 2. 🔒 Trigger_BlokuStanMagazynowyUjemny
-- ; Cel: Zablokuj aktualizację produktu, jeśli nowy StanMagazynowy < 0.
-- ; Typ: INSTEAD OF UPDATE

GO
CREATE OR ALTER TRIGGER Trigger_BlokuStanMagazynowyUjemny
ON Produkty
INSTEAD OF UPDATE
AS 
BEGIN
    DECLARE @StanMagazynowy INT;
    SELECT @StanMagazynowy = StanMagazynowy
    FROM inserted;

    IF @StanMagazynowy = 0
    BEGIN
    THROW 50000, 'Stan magazynowy nie może być ujemny', 1;
    ROLLBACK TRANSACTION;
END

-- Wykonaj update dla wszystkich pól
UPDATE p
    SET
        p.Nazwa = i.Nazwa,
        p.Cena = i.Cena,
        p.StanMagazynowy = i.StanMagazynowy
    FROM Produkty p
    INNER JOIN inserted i ON p.ID = i.ID;
END

GO


SELECT *
from Produkty;


UPDATE Produkty SET StanMagazynowy = 0 WHERE StanMagazynowy = 10;
UPDATE Produkty SET Cena = '200' WHERE ID = 3;


-- ; 3. ✉️ Trigger_EmailUnikalny
-- ; Cel: Zapobiegaj dodaniu klienta z duplikatem e-maila (jeśli nie używamy UNIQUE).
-- ; Typ: INSTEAD OF INSERT
GO
CREATE OR ALTER TRIGGER Trigger_EmailUnikalny
ON Klienci
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Email NVARCHAR(100);
    SELECT @Email = Email
    FROM inserted;

    if exists (select *
    from Klienci
    where Email = @Email)
   BEGIN
        PRINT 'Email już istnieje';
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Klienci
            (Imie, Nazwisko, Email, Haslo)
        SELECT Imie, Nazwisko, Email, Haslo
        FROM inserted;
    END
END

SELECT *
FROM Klienci;

INSERT INTO Klienci
    (Imie, Nazwisko, Email, Haslo)
VALUES
    ('Katarzyna', 'Wójcik', 'jan.kowalski@example.com', 'Haslo1231')


-- ; 4. 🧾 Trigger_AktualizacjaDatyZmiany
-- ; Cel: Dodaj kolumnę DataModyfikacji do Produkty, a trigger ma ją aktualizować przy UPDATE.
-- ; Typ: AFTER UPDATE

ALTER TABLE Produkty
ADD DataModyfikacji DATETIME ;
GO
CREATE TRIGGER Trigger_AktualizacjaDatyZmiany
ON Produkty
AFTER UPDATE
AS
BEGIN
    UPDATE Produkty
    SET DataModyfikacji = GETDATE()
    FROM Produkty p
        INNER JOIN inserted i ON p.ID = i.ID;
END

SELECT *
FROM Produkty;
UPDATE Produkty SET StanMagazynowy = 2 WHERE ID = 2;

-- ; 5. 🚨 Trigger_PowiadomONiskimStanie
-- ; Cel: Po zmniejszeniu StanMagazynowy, jeśli spadnie poniżej 5, wyświetl PRINT z ostrzeżeniem.
-- ; Typ: AFTER UPDATE

CREATE TRIGGER Trigger_PowiadomONiskimStanie
ON Produkty
AFTER UPDATE
AS
BEGIN
    DECLARE @StanMagazynowy INT;
    SELECT @StanMagazynowy = StanMagazynowy
    FROM inserted;

    IF @StanMagazynowy < 5
    BEGIN
        PRINT 'Uwaga! Stan magazynowy poniżej 5.';
    END
END

SELECT *
FROM Produkty;
UPDATE Produkty SET StanMagazynowy = 2 WHERE ID = 2;

-- ; 6. 🧹 Trigger_AutoUsunZamowienie
-- ; Cel: Po usunięciu klienta usuń też jego zamówienia.
-- ; Typ: AFTER DELETE

CREATE TRIGGER Trigger_AutoUsunZamowienie
ON Klienci
AFTER DELETE
AS
BEGIN
    DELETE FROM Zamowienia
    WHERE KlientID IN (SELECT ID
    FROM deleted);
END

DELETE FROM Klienci WHERE ID = 3;

-- ; 7. 📉 Trigger_AutoZmniejszStanPoZamowieniu
-- ; Cel: Gdy dodano rekord do SzczegolyZamowienia, zmniejsz StanMagazynowy produktu.
-- ; Typ: AFTER INSERT

CREATE TRIGGER Trigger_AutoZmniejszStanPoZamowieniu
ON SzczegolyZamowienia
AFTER INSERT
AS
BEGIN
    Declare @ProduktID INT, @Ilosc INT;
    SELECT @ProduktID = ProduktID, @Ilosc = Ilosc
    FROM inserted;
    UPDATE Produkty
    SET StanMagazynowy = StanMagazynowy - @Ilosc
    WHERE ID = @ProduktID;
END
GO
SELECT *
FROM Produkty;
insert into SzczegolyZamowienia
    (ZamowienieID, ProduktID, Ilosc, Cena)
VALUES
    (1, 1, 1, 4200.00)
SELECT *
from Produkty


-- ; 8. 🧱 Trigger_BlokadaZmianyCeny
-- ; Cel: Zablokuj zmianę ceny, jeśli różnica jest większa niż 50%.
-- ; Typ: INSTEAD OF UPDATE
DROP TRIGGER IF EXISTS Trigger_BlokuStanMagazynowyUjemny;
GO

CREATE OR ALTER TRIGGER Trigger_BlokadaZmianyCeny
ON Produkty
INSTEAD OF UPDATE
AS
BEGIN
    -- Blokada na zmianę ceny o więcej niż 50%
    IF EXISTS (
        SELECT 1
    FROM inserted i
        JOIN Produkty p ON i.ID = p.ID
    WHERE ABS(i.Cena - p.Cena) / NULLIF(p.Cena,0) > 0.5
    )
    BEGIN
        PRINT 'Nie można zmienić ceny o więcej niż 50%';
        THROW 50000, 'Nie można zmienić ceny o więcej niż 50%', 1;
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Wykonaj update dla wszystkich pól
    UPDATE p
    SET
        p.Nazwa = i.Nazwa,
        p.Cena = i.Cena,
        p.StanMagazynowy = i.StanMagazynowy
    FROM Produkty p
        INNER JOIN inserted i ON p.ID = i.ID;
END
GO

SELECT *
FROM Produkty;

UPDATE Produkty
SET Cena = '2500'
WHERE ID = 2;
-- ; 9. 📜 Trigger_LogZmianyHasla
-- ; Cel: Loguj do osobnej tabeli każde hasło klienta przy zmianie (dla celów audytu).
-- ; Typ: AFTER UPDATE

CREATE TABLE LogZmianyHasla
(
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    KlientID INT,
    StareHaslo NVARCHAR(100),
    NoweHaslo NVARCHAR(100),
    DataZmiany DATETIME DEFAULT GETDATE()
);
GO
CREATE TRIGGER Trigger_LogZmianyHasla
ON Klienci
AFTER UPDATE
AS
BEGIN
    DECLARE @KlientID INT, @StareHaslo NVARCHAR(100), @NoweHaslo NVARCHAR(100);
    SELECT @KlientID = ID, @StareHaslo = Haslo
    FROM deleted;
    SELECT @NoweHaslo = Haslo
    FROM inserted;
    INSERT INTO LogZmianyHasla
        (KlientID, StareHaslo, NoweHaslo)
    VALUES
        (@KlientID, @StareHaslo, @NoweHaslo);
END

UPDATE Klienci set Haslo = 'Haslo1234' WHERE ID = 1;

select *
from LogZmianyHasla;
-- ; 10. 🕵️‍♂️ Trigger_WykryjDuplikatyProduktow
-- ; Cel: Przy próbie dodania nowego produktu o takiej samej nazwie i cenie – zablokuj operację.
-- ; Typ: INSTEAD OF INSERT

CREATE OR ALTER TRIGGER Trigger_WykryjDuplikatyProduktow
ON Produkty
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Nazwa NVARCHAR(100), @Cena DECIMAL(10,2);
    SELECT @Nazwa = Nazwa, @Cena = Cena
    FROM inserted;
    IF EXISTS (
        SELECT 1
    FROM Produkty
    WHERE Nazwa = @Nazwa AND Cena = @Cena
    )
    BEGIN
        PRINT 'Produkt o tej samej nazwie i cenie już istnieje.';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    INSERT INTO Produkty
        (Nazwa, Cena, StanMagazynowy)
    SELECT Nazwa, Cena, StanMagazynowy
    FROM inserted;
END

SELECT *
from Produkty;
INSERT INTO Produkty
    (Nazwa, Cena, StanMagazynowy)
VALUES
    ('Monitor ASUS', '850.00', 15);