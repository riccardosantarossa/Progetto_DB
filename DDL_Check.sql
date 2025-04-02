--DROP SCHEMA public CASCADE;
--CREATE SCHEMA public;
CREATE TABLE Reparto (
Nome VARCHAR(256) NOT NULL,
Numero INTEGER PRIMARY KEY CHECK (Numero BETWEEN 1 AND 10),
Caporeparto CHAR(16));

CREATE TABLE Dipendente (
CF CHAR(16) PRIMARY KEY,
Nome VARCHAR(256) NOT NULL CHECK (Nome !~ '[0-9*+#]'),
Stipendio FLOAT NOT NULL CHECK ( Stipendio > 0),
Indirizzo VARCHAR(256) NOT NULL CHECK (Indirizzo !~ '[*+#]'),
NumeroReparto INTEGER CHECK (NumeroReparto BETWEEN 1 AND 10)
);

ALTER TABLE Reparto
ADD CONSTRAINT FK_Caporeparto FOREIGN KEY (Caporeparto) REFERENCES
Dipendente(CF) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE Reparto
ALTER COLUMN Caporeparto SET NOT NULL;

ALTER TABLE Dipendente
ADD CONSTRAINT FK_NumeroReparto FOREIGN KEY (NumeroReparto) REFERENCES
Reparto(Numero) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE Dipendente
ALTER COLUMN NumeroReparto SET NOT NULL;

CREATE TABLE Prodotto(
Codice INTEGER,
PrezzoVendita FLOAT NOT NULL CHECK (PrezzoVendita > 0),
Nome VARCHAR(256) NOT NULL,
NumeroReparto INTEGER CHECK (NumeroReparto BETWEEN 1 AND 10),
PRIMARY KEY(Codice),
FOREIGN KEY (NumeroReparto) REFERENCES REPARTO(Numero));

CREATE TABLE Fornitore(
Nome VARCHAR(256) NOT NULL CHECK (Nome !~ '[0-9*+#]'),
Indirizzo VARCHAR(256) NOT NULL CHECK (Indirizzo !~ '[*+#]'),
PRIMARY key (Nome));

CREATE TABLE NumeroTelefono(
NumeroTel CHAR(12)NOT NULL CHECK (NumeroTel ~ '^[0-9]+$'),
Azienda VARCHAR(256),
PRIMARY KEY(NumeroTel),
FOREIGN key(Azienda) REFERENCES Fornitore(Nome)
);

CREATE TABLE Fornisce(
Fornitore VARCHAR(256),
Prodotto INTEGER,
PrezzoFornitura FLOAT NOT NULL CHECK (PrezzoFornitura > 0),
FOREIGN key(Fornitore) REFERENCES Fornitore(Nome),
FOREIGN key(Prodotto) REFERENCES Prodotto(Codice),
PRIMARY KEY(Fornitore,Prodotto)
);

CREATE TABLE OrdineReparto(
NumeroOrdine INTEGER NOT NULL,
NumReparto INTEGER CHECK (NumReparto BETWEEN 1 AND 10),
DataOrdine DATE NOT NULL,
Quantita INTEGER NOT NULL CHECK (Quantita > 0) NOT NULL,
Fornitore VARCHAR(256),
Prodotto INTEGER,
FOREIGN KEY(NumReparto) REFERENCES Reparto(Numero),
FOREIGN key(Fornitore) REFERENCES Fornitore(Nome),
FOREIGN key(Prodotto) REFERENCES Prodotto(Codice),
PRIMARY key(NumeroOrdine,NumReparto)
);

CREATE TABLE Cliente (
Nome VARCHAR(256) CHECK (Nome !~ '[0-9*+#]'),
Indirizzo VARCHAR(256) NOT NULL CHECK (Indirizzo !~ '[*+#]'),
PRIMARY KEY (Nome));

CREATE TABLE OrdineCliente (
NumeroOrdine INTEGER,
Cliente VARCHAR(256),
DataOrdine DATE NOT NULL,
Saldo FLOAT NOT NULL,
FOREIGN KEY (Cliente) REFERENCES Cliente(Nome),
PRIMARY KEY (NumeroOrdine, Cliente));

CREATE TABLE CheCosa (
NumeroOrdine INTEGER,
Cliente VARCHAR(256),
Prodotto INTEGER,
Quantita INTEGER NOT NULL CHECK (Quantita > 0),
FOREIGN KEY (Cliente) REFERENCES Cliente(Nome),
FOREIGN KEY (NumeroOrdine, Cliente) REFERENCES OrdineCliente(NumeroOrdine,
Cliente),
FOREIGN KEY (Prodotto) REFERENCES Prodotto(Codice),
PRIMARY KEY (NumeroOrdine, Cliente, Prodotto)
);
