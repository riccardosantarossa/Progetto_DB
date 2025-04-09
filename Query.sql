--1 Codice fiscale dei capi reparto dei reparti con un numero di dipendenti compreso tra 30 e 50
CREATE OR REPLACE VIEW dipCountFiltered(numreparto, numdip)
AS SELECT numeroreparto, COUNT(cf)
   FROM dipendente
   GROUP BY numeroreparto
   HAVING COUNT(cf) >= 30 AND COUNT(cf) <= 50;

SELECT r.Caporeparto
FROM reparto r
WHERE r.numero IN (SELECT rd.numreparto
				   FROM dipCountFiltered rd);

--2 Quantità media di vendita dei prodotti forniti da esattamente tre fornitori.
CREATE OR REPLACE VIEW fornisceAcquisti(prodotto, fornitore, quantita, numeroordine, cliente)
AS 	SELECT f.prodotto, f.fornitore, cc.quantita, cc.numeroordine, cc.cliente
	FROM fornisce f, checosa cc
	WHERE f.prodotto = cc.prodotto;

SELECT f1.prodotto, AVG(f1.quantita)
FROM fornisceAcquisti f1, fornisceAcquisti f2, fornisceAcquisti f3
WHERE f1.prodotto = f2.prodotto AND f2.prodotto = f3.prodotto AND f1.fornitore <> f2.fornitore AND f1.fornitore <> f3.fornitore AND f2.fornitore <> f3.fornitore
	  AND NOT EXISTS (	SELECT * 
	  					FROM fornisceAcquisti f4
					  	WHERE f4.prodotto = f1.prodotto AND f1.fornitore <> f4.fornitore AND f2.fornitore <> f4.fornitore AND f3.fornitore <> f4.fornitore)
GROUP BY f1.prodotto;

--3 Il numero dei reparti responsabili di almeno un prodotto fornito o solo dal fornitore "Barrows-Wuckert" o dal fornitore "Nicolas, Bayer and Schaden"
SELECT r.numero
FROM reparto r
WHERE EXISTS (SELECT *
			  FROM prodotto p, fornisce f
			  WHERE p.numeroreparto = r.numero AND f.prodotto = p.codice AND f.fornitore = 'Barrows-Wuckert' AND
			  NOT EXISTS (SELECT *
					 	  FROM fornisce f2
						  WHERE f2.prodotto = p.codice AND f2.fornitore <> 'Barrows-Wuckert'))
   OR EXISTS (SELECT *
			  FROM prodotto p, fornisce f
			  WHERE p.numeroreparto = r.numero AND f.prodotto = p.codice AND f.fornitore = 'Nicolas, Bayer and Schaden' AND
			  NOT EXISTS (SELECT *
					 	  FROM fornisce f2
						  WHERE f2.prodotto = p.codice AND f2.fornitore <> 'Nicolas, Bayer and Schaden'))

-- 1 inserimento
INSERT INTO OrdineReparto 
VALUES ( 101, 1, 2025-01-14, 5, 'Renner Group', 5 );

-- 2 aggiornamento
UPDATE CheCosa
SET Quantità = 12
WHERE NumeroOrdine = 1 AND Cliente = 'Kincaid Lidgley' AND Prodotto = 152;

-- 3 cancellazione
DELETE FROM Dipendente
WHERE CF = '236553m5qn9glw04';

-- Q1) quantità media di prodotti ordinati dal reparto gestito dal dipendente PPENNA02B42L483D

CREATE OR REPLACE VIEW RepX (num)
AS SELECT Numero
   FROM Reparto
   WHERE Caporeparto = "PPENNA02B42L483D"

SELECT AVG(Quantita)
FROM OrdineReparto O, RepX R
GROUP BY O.NumReparto
HAVING O.NumReparto = R.num

-- Q2) prodotti che vengono ordinati da esattamente 33 clienti distinti 
CREATE OR REPLACE VIEW ProdCliDist (Prodotto, Cliente)
AS SELECT DISTINCT Prodotto, Cliente
   FROM CheCosa;
   
SELECT Prodotto
FROM ProdCliDist
GROUP BY Prodotto
HAVING COUNT(Cliente) = 33;

-- Q3) Il saldo totale del cliente "Kincaid Lidgley" e il totale medio di ciascun ordine

SELECT Cliente, SUM(Saldo) as Totale, AVG(Saldo) as ImportoMedio
FROM OrdineCliente
WHERE Cliente = 'Kincaid Lidgley'
GROUP BY Cliente;

