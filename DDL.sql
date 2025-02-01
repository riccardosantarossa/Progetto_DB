CREATE TABLE Reparto (
Nome VARCHAR(256),
Numero INTEGER PRIMARY KEY,
NOT NULL Caporeparto VARCHAR(16) DEFERRABLE INITIALLY DEFERRED);

CREATE TABLE Dipendente (
CF VARCHAR(16) PRIMARY KEY,
Nome VARCHAR(256),
Stipendio FLOAT,
Indirizzo VARCHAR(256),
NOT NULL NumeroReparto INTEGER DEFERRABLE INITIALLY DEFERRED);

ALTER TABLE Reparto
ADD CONSTRAINT FK_Caporeparto FOREIGN KEY (Caporeparto) REFERENCES
Dipendente(CF);

ALTER TABLE Dipendente
ADD CONSTRAINT FK_NumeroReparto FOREIGN KEY (NumeroReparto) REFERENCES
Reparto(Numero);

CREATE TABLE Prodotto(
Codice INTEGER,
PrezzoVendita FLOAT,
Nome VARCHAR(256),
NumeroReparto INTEGER,
PRIMARY KEY(Codice),
FOREIGN KEY (NumeroReparto) REFERENCES REPARTO(Numero));

CREATE TABLE Fornitore(
Nome VARCHAR(256),
Indirizzo VARCHAR(256),
PRIMARY key (Nome));

CREATE TABLE NumeroTelefono(
NumeroTel VARCHAR(12),
Azienda VARCHAR(256),
PRIMARY KEY(NumeroTel),
FOREIGN key(Azienda) REFERENCES Fornitore(Nome)
);
CREATE TABLE Fornisce(
Fornitore VARCHAR(256),
Prodotto INTEGER,
PrezzoFornitura FLOAT,
FOREIGN key(Fornitore) REFERENCES Fornitore(Nome),
FOREIGN key(Prodotto) REFERENCES Prodotto(Codice),
PRIMARY KEY(Fornitore,Prodotto)
);
CREATE TABLE OrdineReparto(
NumeroOrdine INTEGER,
NumReparto INTEGER,
DataOrdine DATE,
Quantita INTEGER,
Fornitore VARCHAR(256),
Prodotto INTEGER,
FOREIGN KEY(NumReparto) REFERENCES Reparto(Numero),
FOREIGN key(Fornitore) REFERENCES Fornitore(Nome),
FOREIGN key(Prodotto) REFERENCES Prodotto(Codice),
PRIMARY key(NumeroOrdine,NumReparto)
);
CREATE TABLE Cliente (
Nome VARCHAR(256),
Indirizzo VARCHAR(256),
PRIMARY KEY (Nome));

CREATE TABLE OrdineCliente (
NumeroOrdine INTEGER,
Cliente VARCHAR(256),
DataOrdine DATE,
Saldo FLOAT,
FOREIGN KEY (Cliente) REFERENCES Cliente(Nome),
PRIMARY KEY (NumeroOrdine, Cliente));

CREATE TABLE CheCosa (
NumeroOrdine INTEGER,
Cliente VARCHAR(256),
Prodotto INTEGER,
Quantita INTEGER,
FOREIGN KEY (Cliente) REFERENCES Cliente(Nome),
FOREIGN KEY (NumeroOrdine, Cliente) REFERENCES OrdineCliente(NumeroOrdine,
Cliente),
FOREIGN KEY (Prodotto) REFERENCES Prodotto(Codice),
PRIMARY KEY (NumeroOrdine, Cliente, Prodotto)
);
