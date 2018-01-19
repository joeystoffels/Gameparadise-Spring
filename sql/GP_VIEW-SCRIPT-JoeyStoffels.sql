USE GAMEPARADISE
GO

-- A: De omzet van de maand januari in het jaar 2015.
CREATE VIEW OPDRACHT_7A AS
SELECT 
			(A1.[VERHUUR] +
			B2.[VERKOOP] +
			C3.[REPARATIE]) AS 'OMZET_JANUARI_2015'
FROM
			(SELECT COALESCE((SELECT SUM(CONVERT(INT, HO.[EINDDATUM] - HO.[STARTDATUM]) * A.[PRIJS_PER_D])
			FROM ARTIKEL A
			INNER JOIN ARTIKELENVERHUUR AV ON A.[BARCODE] = AV.[BARCODE]
			INNER JOIN HUUROVEREENKOMST HO ON AV.[EMAILADRES] = HO.EMAILADRES AND AV.[STARTDATUM] = HO.[STARTDATUM]
			WHERE MONTH(AV.[STARTDATUM]) = 1 AND YEAR(AV.[STARTDATUM]) = 2015),	0) AS 'VERHUUR') AS A1,

			(SELECT COALESCE((SELECT SUM(A.[PRIJS])
			FROM ARTIKEL A
			INNER JOIN ARTIKELENVERKOOP AK ON A.[BARCODE] = AK.[BARCODE]
			INNER JOIN VERKOOPOVEREENKOMST VO ON AK.[EMAILADRES] = VO.[EMAILADRES] AND AK.[DATUM] = VO.[DATUM]
			WHERE MONTH(AK.[DATUM]) = 1 AND YEAR(AK.[DATUM]) = 2015), 0) AS 'VERKOOP') AS B2,

			(SELECT COALESCE((SELECT SUM(R.[KOSTEN])
			FROM REPARATIE R
			WHERE MONTH(R.[STARTDATUM]) = 1 AND YEAR(R.[STARTDATUM]) = 2015), 0) AS 'REPARATIE') AS C3;
GO


-- B: Het meest gehuurde Spel. TODO ARTIKEL != SPEL
CREATE VIEW OPDRACHT_7B AS
SELECT TOP 1 WITH TIES
			A.[BARCODE],
			A.[JAAR_UITGAVE],
			A.[MERK],
			A.[PRIJS],
			A.[PRIJS_PER_D],
			A.[SPEL_OF_CONSOLE],
			A.[TITEL],
			A.[TYPE],
			A.[UITGEVER],
			COUNT(AV.[BARCODE]) AS 'AANTAL_KEER_VERHUURD'
FROM 
			ARTIKEL A
			INNER JOIN ARTIKELENVERHUUR AV ON A.[BARCODE] = AV.[BARCODE]
			WHERE A.[SPEL_OF_CONSOLE] = 'SPEL'
			GROUP BY
				A.[BARCODE],
				A.[JAAR_UITGAVE],
				A.[MERK],
				A.[PRIJS],
				A.[PRIJS_PER_D],
				A.[SPEL_OF_CONSOLE],
				A.[TITEL],
				A.[TYPE],
				A.[UITGEVER]
			ORDER BY 'AANTAL_KEER_VERHUURD' DESC;
GO

-- C: De huurovereenkomst met de hoogste omzet.
CREATE VIEW OPDRACHT_7C AS
SELECT TOP 1 WITH TIES
			HO.[EINDDATUM],
			HO.[EMAILADRES],
			HO.[HUURSTATUS],
			HO.[REPARABEL],
			HO.[SCHADE],
			HO.[STARTDATUM],
			(CONVERT(INT, HO.[EINDDATUM] - HO.[STARTDATUM]) * A.[PRIJS_PER_D]) AS 'BEDRAG'
FROM
			ARTIKELENVERHUUR AV
			INNER JOIN ARTIKEL A ON A.[BARCODE] = AV.[BARCODE]
			INNER JOIN HUUROVEREENKOMST HO ON AV.[EMAILADRES] = HO.[EMAILADRES] AND AV.[STARTDATUM] = HO.[STARTDATUM]
			ORDER BY 'BEDRAG' DESC;
GO

-- D: De totale schade in het jaar 2016.
CREATE VIEW OPDRACHT_7D AS
SELECT 		SUM(R.[KOSTEN]) AS 'TOTALE_SCHADE_2016' 
FROM		REPARATIE R 
WHERE		YEAR(R.[STARTDATUM]) = 2016;
GO

-- E: De consoles met de meeste schade.
CREATE VIEW OPDRACHT_7E AS
SELECT TOP 1 WITH TIES
			A.[BARCODE],
			A.[JAAR_UITGAVE],
			A.[MERK],
			A.[PRIJS],
			A.[PRIJS_PER_D],
			A.[SPEL_OF_CONSOLE],
			A.[TITEL],
			A.[TYPE],
			A.[UITGEVER],
			SUM(R.[KOSTEN]) AS 'SCHADEBEDRAG'
FROM 
			REPARATIE R
			INNER JOIN ARTIKEL A ON A.[BARCODE] = R.[BARCODE]
GROUP BY	
			A.[BARCODE],
			A.[JAAR_UITGAVE],
			A.[MERK],
			A.[PRIJS],
			A.[PRIJS_PER_D],
			A.[SPEL_OF_CONSOLE],
			A.[TITEL],
			A.[TYPE],
			A.[UITGEVER]
ORDER BY	
			'SCHADEBEDRAG' DESC;
GO