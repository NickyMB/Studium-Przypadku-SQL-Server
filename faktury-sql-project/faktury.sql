Drop TABLE IF EXISTS Faktury;
CREATE TABLE Faktury
(
    Id INT PRIMARY KEY,
    Klient NVARCHAR(100),
    SzczegolyXML XML
);


INSERT INTO Faktury
    (Id, Klient, SzczegolyXML)
VALUES
    (
        1,
        'Jan Kowalski',
        '<Faktura>
            <NrFaktury>FV/2024/001</NrFaktury>
            <NIP>1234567890</NIP>
            <DataFaktury>2024-05-01</DataFaktury>
            <Pozycje>
                <Pozycja><Nazwa>Produkt A</Nazwa><Cena>100.00</Cena></Pozycja>
                <Pozycja><Nazwa>Produkt B</Nazwa><Cena>200.00</Cena></Pozycja>
            </Pozycje>
        </Faktura>'
    ),
    (
        2,
        'Anna Nowak',
        '<Faktura>
            <NrFaktury>FV/2024/002</NrFaktury>
            <NIP>9876543210</NIP>
            <DataFaktury>2024-05-02</DataFaktury>
            <Pozycje>
                <Pozycja><Nazwa>Produkt C</Nazwa><Cena>150.00</Cena></Pozycja>
            </Pozycje>
        </Faktura>'
    );

-- Wyciąganie danych z XML
SELECT
    Klient,
    SzczegolyXML.value('(/Faktura/NrFaktury)[1]', 'NVARCHAR(50)') AS NrFaktury,
    SzczegolyXML.value('(/Faktura/NIP)[1]', 'NVARCHAR(20)') AS NIP,
    SzczegolyXML.value('(/Faktura/DataFaktury)[1]', 'DATE') AS DataFaktury,
    Pozycja.value('(Nazwa)[1]', 'NVARCHAR(100)') AS Nazwa,
    Pozycja.value('(Cena)[1]', 'DECIMAL(10,2)') AS Cena
FROM Faktury
CROSS APPLY SzczegolyXML.nodes('/Faktura/Pozycje/Pozycja') AS Pozycja(Pozycja);

-- Suma faktury
WITH
    PozycjeCTE
    AS
    (
        SELECT
            Klient,
            SzczegolyXML.value('(/Faktura/NrFaktury)[1]', 'NVARCHAR(50)') AS NrFaktury,
            Pozycja.value('(Cena)[1]', 'DECIMAL(10,2)') AS Cena
        FROM Faktury
    CROSS APPLY SzczegolyXML.nodes('/Faktura/Pozycje/Pozycja') AS Pozycja(Pozycja)
    )
SELECT
    Klient,
    NrFaktury,
    SUM(Cena) AS SumaFaktury
FROM PozycjeCTE
GROUP BY Klient, NrFaktury;

-- Dodanie nowej pozycji do XML 
UPDATE Faktury
SET SzczegolyXML.modify('
    insert <Pozycja>
        <Nazwa>Produkt G</Nazwa>
        <Cena>2500.00</Cena>
    </Pozycja>
    into (/Faktura/Pozycje)[1]
')
WHERE Id = 1;

-- Tworzenie pliku XML z danymi dla danego Id faktury (np. Id = 1)
SELECT
    SzczegolyXML
FROM Faktury
WHERE Id = 1
FOR XML PATH(''), TYPE;

    -- Wyciąganie danych z excel
    SELECT
        Klient,
        SzczegolyXML.value('(/Faktura/NrFaktury)[1]', 'NVARCHAR(50)') AS NrFaktury,
        SzczegolyXML.value('(/Faktura/NIP)[1]', 'NVARCHAR(20)') AS NIP,
        SzczegolyXML.value('(/Faktura/DataFaktury)[1]', 'DATE') AS DataFaktury,
        Pozycja.value('(Nazwa)[1]', 'NVARCHAR(100)') AS Nazwa,
        Pozycja.value('(Cena)[1]', 'DECIMAL(10,2)') AS Cena
    FROM Faktury
CROSS APPLY SzczegolyXML.nodes('/Faktura/Pozycje/Pozycja') AS Pozycja(Pozycja)
    where id = 1;