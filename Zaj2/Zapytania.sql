Use sklep
go

-- Funkcje Skalarne
SELECT * FROM Klienci
/* 
go
CREATE FUNCTION dbo.ObliczWiek (@DataUrodzenia DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Wiek INT
    SET @Wiek = DATEDIFF(YEAR, @DataUrodzenia, GETDATE())
          
    RETURN @Wiek
END 
*/
GO

SELECT imie, dbo.ObliczWiek(DataUrodzenia) AS Wiek from Klienci
/* 
go
CREATE FUNCTION dbo.SumOfMinutes (@Godziny as INT, @Minuty as INT)
RETURNS INT
AS
BEGIN
    RETURN (@Godziny * 60) + @Minuty
END
 */
GO
SELECT dbo.SumOfMinutes(2, 30) AS SumaMinut

/* 
go
CREATE FUNCTION VAT (@Cena as DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @cena+@Cena * 0.23
END */
GO
SELECT Nazwa, Cena, dbo.VAT(Cena) AS VAT FROM Produkty
/* 
go
CREATE FUNCTION dbo.CheckNumber (@NumerTelefonu NVARCHAR(11))
RETURNS VARCHAR(1)
AS
BEGIN
    DECLARE @Wynik VARCHAR(1)
    IF @NumerTelefonu LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]'
        SET @Wynik = 1
    ELSE
        SET @Wynik = 0

    RETURN @Wynik
END */

SELECT dbo.CheckNumber('123-123-123') AS PoprawnyNumerTelefonu
/* 
go
CREATE FUNCTION dbo.FirstTenChars (@Tekst NVARCHAR(100))
RETURNS NVARCHAR(10)
AS
BEGIN
    RETURN LEFT(@Tekst, 10)
END */
GO
SELECT dbo.FirstTenChars('To jest przykladowy tekst') AS Pierwsze10Znakow

/* 
go
CREATE FUNCTION dbo.LengthOfString (@Tekst NVARCHAR(100))
RETURNS INT
AS
BEGIN
    RETURN LEN(@Tekst)
END */
GO
SELECT dbo.LengthOfString('To jest przykladowy tekst') AS DlugoscTekstu

/* 
go
CREATE FUNCTION dbo.CzyPelnoletni (@DataUrodzenia DATE)
RETURNS VARCHAR(3)
AS
BEGIN
    DECLARE @Wiek INT
    DECLARE @Pelnoletni VARCHAR(3)
    SET @Wiek = DATEDIFF(YEAR, @DataUrodzenia, GETDATE())
    SET @Pelnoletni = CASE WHEN @Wiek >= 18 THEN 'Tak' ELSE 'Nie' END
    RETURN @Pelnoletni
END 
 */
GO

SELECT imie, dbo.CzyPelnoletni(DataUrodzenia) AS Wiek from Klienci

/* go
CREATE FUNCTION dbo.UpperText (@Text NVARCHAR(100))
RETURNS NVARCHAR(100)
AS
BEGIN
    RETURN UPPER(@Text)
END
GO */
SELECT dbo.UpperText('to jest przykladowy tekst') AS UpperText
/* go
CREATE FUNCTION dbo.SumaZamowienia (@IloscSztuk INT, @Cena DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @IloscSztuk * @Cena
END */
GO
SELECT dbo.SumaZamowienia(5, 10.00) AS SumaZamowienia
/* go
 CREATE FUNCTION dbo.DayDiff (@Data1 DATE, @Data2 DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @Data1, @Data2)
END */
GO
SELECT dbo.DayDiff('2023-01-01', '2023-01-10') AS RóżnicaDni

-- Funkcje Tabelaryczne
/* go
CREATE FUNCTION dbo.KlienciZamowieniaWroku (@Rok INT)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT k.KlientID, k.Imie, k.Nazwisko,z.DataZamowienia
    FROM Klienci k
    JOIN Zamowienia z ON k.KlientID = z.KlientID
    WHERE YEAR(z.DataZamowienia) = @Rok
); */
go
SELECT * FROM dbo.KlienciZamowieniaWroku(2025);

/* 
GO
create FUNCTION dbo.ProduktyWhereCena (@Cena DECIMAL(10,2))
RETURNS TABLE
AS
RETURN
(
    SELECT Nazwa, Cena FROM Produkty WHERE Cena > @Cena
); */
SELECT * from dbo.ProduktyWhereCena(1000);

/* go
CREATE FUNCTION dbo.ProduktCzasZamowienia (@Data1 DATE, @Data2 DATE)
RETURNS TABLE
AS
RETURN
(
    SELECT P.Nazwa, SUM(ZZ.Ilosc) AS Ilosc
    FROM Produkty P
    JOIN ZamowieniaZawartosc ZZ ON P.ProduktID = ZZ.ProduktID
    JOIN Zamowienia Z ON ZZ.ZamowienieID = Z.ZamowienieID
    WHERE Z.DataZamowienia BETWEEN @Data1 AND @Data2
    GROUP BY P.Nazwa
); */
go
SELECT * FROM dbo.ProduktCzasZamowienia('2025-01-01', '2025-12-31');
/* 
go
CREATE FUNCTION dbo.KlientFormMiasto (@Miasto NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT CONCAT(K.Imie,' ', K.Nazwisko) AS Klient, M.Nazwa AS Miasto
    FROM Klienci K
    JOIN Miasta M ON K.MiastoID = M.MiastoID
    WHERE M.Nazwa = @Miasto
); */
GO
SELECT * FROM dbo.KlientFormMiasto('Warszawa');
/* GO
CREATE FUNCTION dbo.ZamowieniaKlientow30dni()
RETURNS TABLE
AS
RETURN
(
    SELECT COUNT(Z.ZamowienieID) AS IloscZamowien, CONCAT(K.Imie,' ', K.Nazwisko) AS Klient 
    FROM Klienci K 
    JOIN Zamowienia Z ON K.KlientID = Z.KlientID 
    WHERE DATEDIFF(DAY,Z.DataZamowienia,GETDATE())<=30 
    GROUP BY K.Imie, K.Nazwisko
); */
GO
SELECT * FROM dbo.ZamowieniaKlientow30dni();
CREATE FUNCTION dbo.ProduktyPonizej(@StanMagazynowy INT)
/* go
RETURNS TABLE
AS
RETURN
(
    SELECT Nazwa, StanMagazynowy FROM Produkty WHERE StanMagazynowy < @StanMagazynowy
); */
GO
SELECT * FROM dbo.ProduktyPonizej(10);
/* GO
CREATE FUNCTION dbo.ZamowieniaOstatnie7dni()
RETURNS TABLE
AS
RETURN
(
    SELECT Z.ZamowienieID,P.Nazwa FROM Zamowienia Z join ZamowieniaZawartosc ZZ on Z.ZamowienieID=ZZ.ZamowienieID Join Produkty P on P.ProduktID = ZZ.ProduktID WHERE DATEDIFF(DAY,Z.DataZamowienia,GETDATE())<=7
); */
GO
SELECT * FROM dbo.ZamowieniaOstatnie7dni();

/* go
create FUNCTION dbo.ZamowieniaKlientow(@Kraj NVARCHAR(50))
RETURNS TABLE
AS
RETURN
    
    (
        SELECT P.Nazwa,CONCAT(K.Imie,' ', K.Nazwisko) AS Klient FROM Zamowienia Z join ZamowieniaZawartosc ZZ on Z.ZamowienieID=ZZ.ZamowienieID Join Produkty P on P.ProduktID = ZZ.ProduktID JOIN Klienci K on K.KlientID = Z.KlientID WHERE Kraj = @Kraj
    ); */
GO
SELECT * FROM dbo.ZamowieniaKlientow('Polska');
/* Go
CREATE FUNCTION dbo.SredniaSumaZamowienia()
RETURNS TABLE
AS
RETURN
(
    SELECT AVG(P.cena * ZZ.Ilosc) SredniaSumaZamowienia, CONCAT(K.Imie,' ', K.Nazwisko) AS Klient FROM Zamowienia Z join ZamowieniaZawartosc ZZ on Z.ZamowienieID=ZZ.ZamowienieID Join Produkty P on P.ProduktID = ZZ.ProduktID JOIN Klienci K on K.KlientID = Z.KlientID GROUP BY K.Imie, K.Nazwisko
); */
GO
SELECT * FROM dbo.SredniaSumaZamowienia();

