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



