-- ==============================================
-- MINI PROJEKT GRUPOWY – SYSTEM ZAMÓWIEŃ
-- ==============================================
-- Dane wejściowe (symulacja importu z Excela)
-- ==============================================

CREATE TABLE Klienci
(
    ID INT PRIMARY KEY,
    Imie NVARCHAR(50),
    Nazwisko NVARCHAR(50),
    Email NVARCHAR(100)
);

CREATE TABLE Produkty
(
    ID INT PRIMARY KEY,
    Nazwa NVARCHAR(100),
    Cena DECIMAL(10,2),
    Dostepny BIT
);

CREATE TABLE Zamowienia
(
    ID INT PRIMARY KEY,
    ID_Klienta INT FOREIGN KEY REFERENCES Klienci(ID),
    ID_Produktu INT FOREIGN KEY REFERENCES Produkty(ID),
    Ilosc INT,
    Data DATETIME,
    Kwota DECIMAL(10,2)
);

CREATE TABLE LogZamowien
(
    ID INT IDENTITY,
    ID_Zamowienia INT,
    DataDodania DATETIME DEFAULT GETDATE(),
    Komunikat NVARCHAR(255)
);

-- Przykładowe dane
INSERT INTO Klienci
VALUES
    (1, 'Anna', 'Kowalska', 'anna.k@example.com'),
    (2, 'Tomasz', 'Nowak', 'tomasz.n@example.com'),
    (3, 'Julia', 'Wiśniewska', 'julia.w@example.com'),
    (4, 'Marcin', 'Zieliński', 'marcin.z@example.com');

INSERT INTO Produkty
VALUES
    (1, 'Laptop', 3500.00, 1),
    (2, 'Monitor', 1200.00, 1),
    (3, 'Mysz', 100.00, 1),
    (4, 'Drukarka', 800.00, 0);

INSERT INTO Zamowienia
VALUES
    (1, 1, 1, 1, '2024-04-01', 3500.00),
    (2, 2, 2, 2, '2024-04-03', 2400.00),
    (3, 3, 3, 3, '2024-04-05', 300.00),
    (4, 2, 4, 1, '2024-04-10', 800.00);

-- TODO: Funkcja rangująca - TOP 5 klientów wg kwoty zamówień

CREATE OR ALTER FUNCTION dbo.RankKlientow()
RETURNS TABLE
AS
RETURN (
    SELECT top 5
    K.ID,
    K.Imie,
    K.Nazwisko,
    SUM(Z.Kwota) AS SumaZamowien,
    RANK() OVER (ORDER BY SUM(Z.Kwota) DESC) AS Pozycja
FROM Klienci K
    JOIN Zamowienia Z ON K.ID = Z.ID_Klienta
GROUP BY K.ID, K.Imie, K.Nazwisko
);

SELECT *
FROM dbo.RankKlientow();

-- TODO: Funkcja skalarną – klasyfikacja lojalnościowa (brązowy, srebrny, złoty)


CREATE OR ALTER FUNCTION dbo.KlasyfikacjaLojalnosci(@ID INT)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Lojalnosc NVARCHAR(20) = 'Brązowy';
    -- Default value
    SELECT @Lojalnosc = CASE
        WHEN SUM(Z.Kwota) > 10000 THEN 'Złoty'
        WHEN SUM(Z.Kwota) > 5000 THEN 'Srebrny'
        ELSE 'Brązowy'
    END
    FROM Zamowienia Z
    WHERE Z.ID_Klienta = @ID;
    RETURN @Lojalnosc;
END;


SELECT K.ID, K.Imie, K.Nazwisko, dbo.KlasyfikacjaLojalnosci(K.ID) AS Lojalnosc
from Klienci K;

-- TODO: Funkcja tabelaryczna – zwraca duże zamówienia powyżej kwoty

CREATE OR ALTER FUNCTION dbo.DuzeZamowienia(@Kwota DECIMAL(10,2))
RETURNS TABLE
AS
RETURN (
    SELECT Z.ID, K.Imie, K.Nazwisko, Z.Kwota
FROM Zamowienia Z
    JOIN Klienci K ON Z.ID_Klienta = K.ID
WHERE Z.Kwota > @Kwota
);
SELECT *
FROM dbo.DuzeZamowienia(1000);

-- TODO: XML – dane rabatowe wg poziomu lojalności

DECLARE @RabatyXML XML = 
N'<Rabaty>
   <Poziom nazwa="złoty">15</Poziom>
   <Poziom nazwa="srebrny">10</Poziom>
   <Poziom nazwa="brązowy">5</Poziom>
</Rabaty>';

WITH
    Lojalni
    AS
    (
        SELECT
            K.ID,
            K.Imie,
            K.Nazwisko,
            LOWER(dbo.KlasyfikacjaLojalnosci(K.ID)) AS Lojalnosc
        FROM Klienci K
    )
SELECT
    l.ID,
    l.Imie,
    l.Nazwisko,
    l.Lojalnosc,
    @RabatyXML.value('(/Rabaty/Poziom[@nazwa=sql:column("l.Lojalnosc")])[1]', 'INT') AS Rabat
FROM Lojalni l;


-- TODO: Procedura – dodaje zamówienie z rabatem i obsługą błędów
CREATE OR ALTER PROCEDURE pr_rabaty
    @ZamowienieID INT,
    @Rabat INT
AS
BEGIN
    IF EXISTS (SELECT 1
    FROM Zamowienia
    WHERE ID = @ZamowienieID)
    BEGIN
        DECLARE @Kwota DECIMAL(10,2);
        SELECT @Kwota = Kwota
        FROM Zamowienia
        WHERE ID = @ZamowienieID;

        IF (@Kwota > 1000)
        BEGIN
            UPDATE Zamowienia
            SET Kwota = @Kwota * (1 - @Rabat / 100.0)
            WHERE ID = @ZamowienieID;

            PRINT 'Kwota zamowienia: ' + CAST(@Kwota * (1 - @Rabat / 100.0) AS NVARCHAR(50));
        END
        ELSE
        BEGIN
            PRINT 'Rabat sie nienalezy >:(';
        END
    END
    ELSE
    BEGIN
        PRINT 'Zamowienie nie istnieje';
    END
END;
GO
EXEC pr_rabaty 5, 10;
-- TODO: Trigger – loguje duże zamówienia i błędy w dostępności

-- Nie koniecznie działa

CREATE or ALTER TRIGGER tr_zamowienia
ON Zamowienia INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT p.ID
    FROM Produkty p JOIN inserted i ON p.ID = i.ID_Produktu
    WHERE p.ID = i.ID_Produktu AND p.Dostepny = 1) 
    BEGIN
        DECLARE @Kwota DECIMAL(10,2)
        SELECT @Kwota = z.Kwota
        FROM Zamowienia z
            JOIN inserted i ON z.ID = i.ID
        WHERE z.ID = i.ID

        IF(@Kwota > 2000)
        BEGIN
            INSERT INTO LogZamowien
                (ID_Zamowienia, DataDodania, Komunikat)
            SELECT ID, Data, 'dodano duze zamowienie'
            FROM inserted

            INSERT INTO Zamowienia
                (ID, ID_Klienta, ID_Produktu, Ilosc, Data, Kwota)
            SELECT ID, ID_Klienta, ID_Produktu, Ilosc, Data, Kwota
            FROM inserted
        END
    END
END

INSERT INTO Zamowienia
    (ID, ID_Klienta, ID_Produktu, Ilosc, Data, Kwota)
VALUES
    (5, 1, 1, 2, '2024-04-15', 7000.00),
    (6, 2, 3, 1, '2024-04-20', 100.00),
    (7, 3, 4, 1, '2024-04-25', 800.00);

SELECT *
from LogZamowien
