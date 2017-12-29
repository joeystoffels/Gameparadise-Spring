-- Opdracht 7: Maak een View voor deze informatiebehoefte (INDIVIDUEEL!)

USE GAMEPARADISE

Drop view if exists dbo.Opdr7A_Omzet2015;
Drop view if exists dbo.Opdr7B_MeestGehuurdeSpel;
Drop view if exists dbo.Opdr7C_HuurovereenkomtHoogsteOmzet;
Drop view if exists dbo.Opdr7D_TotaleSchade2016;
Drop view if exists dbo.Opdr7E_ConsolesMetMeesteSchade;
GO

-- A. De omzet van de maand januari in het de jaar 2015.
-- Hierbij is de aanname gedaan dat er op de startdatum van huurovereenkomst betaald word.
CREATE VIEW Opdr7A_Omzet2015 AS
SELECT 
    -- Verkoop: Tel alle prijzen bij elkaar op, wanneer er een datum van verkoopovereenkomst is.
    SUM(CASE WHEN VO.DATUM IS NOT NULL THEN A.PRIJS ELSE 0 END)
    +
    -- Vehuur: Tel alle dagen x verhuurprijs voor wanneer de status op verhuur staat.
    SUM(CASE WHEN HO.HUURSTATUS = 'VERHUURD' THEN DATEDIFF(d, HO.STARTDATUM, HO.EINDDATUM) * A.PRIJS_PER_D ELSE 0 END) 
    +
    -- Reparatie: Alle omzet gemaakt bij reparatie
    SUM(CASE WHEN R.KOSTEN IS NOT NULL THEN R.KOSTEN ELSE 0 END)
    AS 'omzet'
FROM ARTIKEL AS A
LEFT JOIN REPARATIE AS R ON A.BARCODE = R.BARCODE
LEFT JOIN ARTIKELENVERKOOP AS AV ON A.BARCODE = AV.BARCODE
LEFT JOIN ARTIKELENVERHUUR AS AVR ON A.BARCODE = AVR.BARCODE
LEFT JOIN HUUROVEREENKOMST AS HO ON AVR.EMAILADRES = HO.EMAILADRES AND AVR.STARTDATUM = HO.STARTDATUM
LEFT JOIN VERKOOPOVEREENKOMST AS VO ON AV.EMAILADRES = VO.EMAILADRES AND AV.DATUM = VO.DATUM
WHERE (YEAR(AV.DATUM) = 2015 AND MONTH(AV.DATUM) = 1) 
OR 
(HO.HUURSTATUS = 'VERHUURD' AND YEAR(AVR.STARTDATUM) = 2015 AND MONTH(AVR.STARTDATUM) = 1)
OR 
(R.KOSTEN IS NOT NULL AND YEAR(R.STARTDATUM) = 2015 AND MONTH(R.STARTDATUM) = 1);
GO


-- B. Het meest gehuurde Spel.
CREATE VIEW Opdr7B_MeestGehuurdeSpel AS
SELECT A.BARCODE
    , A.TITEL
    , A.JAAR_UITGAVE
FROM ARTIKEL AS A
WHERE A.BARCODE = (
    SELECT AV.BARCODE
    FROM ARTIKELENVERHUUR AS AV
    INNER JOIN ARTIKEL AS A ON AV.BARCODE = A.BARCODE
    WHERE A.SPEL_OF_CONSOLE = 'SPEL'
    GROUP BY AV.BARCODE
    HAVING COUNT(AV.BARCODE) >= All (
        SELECT COUNT(AV.BARCODE)
        FROM ARTIKELENVERHUUR AS AV
        INNER JOIN ARTIKEL AS A ON AV.BARCODE = A.BARCODE
        WHERE A.SPEL_OF_CONSOLE = 'SPEL'
        GROUP BY AV.BARCODE)
);
GO

-- C. De huurovereenkomst met de hoogste omzet.
CREATE VIEW Opdr7C_HuurovereenkomtHoogsteOmzet AS
SELECT HO.STARTDATUM
    , HO.EMAILADRES
    , SUM(DATEDIFF(d, HO.STARTDATUM, HO.EINDDATUM) * A.PRIJS_PER_D) AS 'totaal'
FROM ARTIKELENVERHUUR AS AV
    INNER JOIN HUUROVEREENKOMST AS HO ON AV.EMAILADRES = HO.EMAILADRES AND AV.STARTDATUM = HO.STARTDATUM
    INNER JOIN ARTIKEL AS A ON AV.BARCODE = A.BARCODE
    GROUP BY HO.EMAILADRES, HO.STARTDATUM
    HAVING SUM(DATEDIFF(d, HO.STARTDATUM, HO.EINDDATUM) * A.PRIJS_PER_D) >= All (
        SELECT SUM(DATEDIFF(d, HO.STARTDATUM, HO.EINDDATUM) * A.PRIJS_PER_D) AS 'totaal'
        FROM ARTIKELENVERHUUR AS AV
        INNER JOIN HUUROVEREENKOMST AS HO ON AV.EMAILADRES = HO.EMAILADRES AND AV.STARTDATUM = HO.STARTDATUM
        INNER JOIN ARTIKEL AS A ON AV.BARCODE = A.BARCODE
        GROUP BY HO.EMAILADRES, HO.STARTDATUM
    );
GO

-- D. De totale schade in het jaar 2016.
CREATE VIEW Opdr7D_TotaleSchade2016 AS 
SELECT SUM(R.KOSTEN) AS 'totale schade'
FROM REPARATIE AS R
WHERE YEAR(R.STARTDATUM) = 2016;
GO

-- E. De consoles met de meeste schade.
-- Hierbij is de aanname gedaan, dat het hoogste bedrag bedoeld word, niet de hoeveelheid keren dat de console schade heeft gehad.
CREATE VIEW Opdr7E_ConsolesMetMeesteSchade AS
SELECT R.BARCODE
    , A.MERK
    , A.[TYPE]
    , SUM(R.KOSTEN) as 'kosten'
FROM REPARATIE AS R
INNER JOIN ARTIKEL AS A ON R.BARCODE = A.BARCODE
GROUP BY R.BARCODE, A.MERK, A.[TYPE]
HAVING SUM(R.KOSTEN) >= All (
    SELECT SUM(R.KOSTEN) as 'kosten'
    FROM REPARATIE AS R
    INNER JOIN ARTIKEL AS A ON R.BARCODE = A.BARCODE
    WHERE A.SPEL_OF_CONSOLE = 'CONSOLE'
    GROUP BY R.BARCODE
);
GO