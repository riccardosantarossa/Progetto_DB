--1
SELECT d.nome, d.cf 
FROM dipendente d, reparto r
WHERE d.cf = r.caporeparto AND r.nome IN (SELECT r1.nome, COUNT(*) AS numdipendenti
										   FROM reparto r1
										   GROUP BY r1.nome, numdipendenti
										   HAVING numdipendenti >= 30 AND numdipendenti <= 50));

--2
CREATE VIEW fornisceAcquisti(prodotto, fornitore, quantita, numeroordine, cliente)
AS 	SELECT f.prodotto, f.fornitore, cc.quantita, cc.numeroordine, cc.cliente
	FROM fornisce f, checosa cc
	WHERE f.prodotto = cc.prodotto;

SELECT f1.prodotto, AVG(f1.quantita)
FROM fornisceAcquisti f1 f2 f3
WHERE f1.prodotto = f2.prodotto AND f2.prodotto = f3.prodotto AND f1.fornitore <> f2.fornitore AND f1.fornitore <> f3.fornitore AND f2.fornitore <> f3.fornitore
	  AND NOT EXISTS (	SELECT * 
	  					FROM fornisceAcquisti f4
					  	WHERE f4.prodotto = f1.prodotto AND f1.fornitore <> f4.fornitore AND f2.fornitore <> f4.fornitore AND f3.fornitore <> f4.fornitore)
GROUP BY f1.prodotto;

--3
SELECT r.numero
FROM reparto r
WHERE NOT EXISTS (	SELECT *
					FROM fornisce f, prodotto p 
					WHERE f.prodotto = p.codice AND p.numeroreparto = r.numero AND f.fornitore <> 'fornitore x')
	  OR NOT EXISTS (	SELECT *
						FROM fornisce f, prodotto p 
						WHERE f.prodotto = p.codice AND p.numeroreparto = r.numero AND f.fornitore <> 'fornitore y');

-- 1 inserimento
INSERT INTO OrdineReparto 
VALUES ( 00, 3, 2025-01-14, 5, FornitoreX, 5 );

-- 2 aggiornamento
UPDATE CheCosa
SET Quantità = 12
WHERE NumeroOrdine = 3 AND Cliente = ClienteX AND Prodotto = 6;

-- 3 cancellazione
DELETE FROM Dipendente
WHERE CF = XXXYYY98B43L483X;

-- Q1) quantità media di prodotti ordinati dal reparto gestito dal dipendente XXXYYY98B43L483Y

CREATE VIEW RepX (num)
AS SELECT Numero
   FROM Reparto
   WHERE Caporeparto = "XXXYYY98B43L483Y"

SELECT AVG(Quantita)
FROM OrdineReparto O, RepX R
GROUP BY O.NumReparto
HAVING O.NumReparto = R.num

-- Q2) prodotti che vengono ordinati da esattamente 2 clienti 

SELECT P1.Codice
FROM CheCosa P1 P2
WHERE P1.Codice = P2.Codice AND P1.Cliente < P2.Cliente AND 
      NOT EXISTS ( SELECT *
                   FROM CheCosa P3
		   WHERE P3.Codice = P1.Codice AND P1.Cliente <> P3.Cliente AND P2.Cliente <> P3.Cliente)

-- Q3) i manager dei reparti col massimo numero di dipendenti

CREATE VIEW dipCount (numRep, numDip)
AS SELECT NumeroReparto, COUNT(CF)
   FROM Dipendente
   GROUP BY NumeroReparto

SELECT R.Caporeparto
FROM Reparto R, dipCount D
WHERE R.Numero = D.numRep AND NOT EXISTS ( SELECT *
                                           FROM dipCount D2
					   WHERE D2.numDip > D.numDip)


