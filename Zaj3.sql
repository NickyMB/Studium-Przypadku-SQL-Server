CREATE DATABASE Zaj3;
use Zaj3;
CREATE TABLE Produkty
(
    Id INT PRIMARY KEY,
    Nazwa NVARCHAR(100),
    Szczegoly XML
);

INSERT INTO Produkty
    (Id, Nazwa, Szczegoly)
VALUES
    (
        1,
        'Laptop',
        '<Produkt><Producent>Dell</Producent><Cena>4500</Cena></Produkt>'
);

SELECT
    Szczegoly.value('(/Produkt/Producent)[1]', 'NVARCHAR(100)') AS Producent,
    Szczegoly.value('(/Produkt/Cena)[1]', 'DECIMAL(10,2)') AS Cena
FROM Produkty;