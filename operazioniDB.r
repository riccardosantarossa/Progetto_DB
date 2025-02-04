
setwd("C:/Users/Utente/Desktop/Progetto_DB")

# Connessione con RPostgres
library(RPostgres)
library(stringr)

connect <- dbConnect(RPostgres::Postgres(), dbname = "progettoDB", host = "localhost", 
                     port = 5432, user = "postgres", password = "1234")

#Seed per operazioni casuali
set.seed(11)

#Funzione di inserimento dei record nelle tabelle
inserimento <- function(file)
{
  fileName <- file
  fopen <- file(fileName,open="r")
  linn <-readLines(fopen)
  for (i in 1:length(linn))
  {
    dbExecute(connect, linn[i])
  }
  close(fopen)
}

#Funzione di esecuzione delle transazioni
insertTransactionsManagerReparto <- function(file)
{
  fileName <- file
  fopen <- file(fileName, open="r")
  linn <-readLines(fopen)
  for (i in 1:length(linn))
  {
    dbBegin(connect)
    instructions <- strsplit(linn[i], '; ')[[1]]
    values1 <- as.list(strsplit(instructions[1], ',')[[1]])
    values2 <- as.list(strsplit(instructions[2], ',')[[1]])
    
    dbExecute(connect, "INSERT INTO dipendente values($1, $2, $3, $4, $5)", values1)
    dbExecute(connect, "INSERT INTO reparto values($1, $2, $3)", values2)
    
    cf <- values1[1]
    nrep <- values2[2]
    vl <- as.list(c(cf,nrep))

    df <- dbGetQuery(connect, "SELECT 1 FROM reparto r, dipendente d WHERE d.cf = r.caporeparto AND d.cf = $1 AND d.numeroreparto = r.numero AND r.numero = $2;", vl)

    if(is.null(df[1,1]))
    {
      dbRollback(connect)
    }
    else
    {
      dbCommit(connect)
    }
  }
  close(fopen)
}

#Funzione che genera gli ordini per ogni reparto
ordiniPerReparto <- function(numReparto)
{
  datePossibili <- read.csv('date.csv')
  
  prodottiReparto <- dbGetQuery(connect, "SELECT codice FROM prodotto WHERE numeroreparto = $1", numReparto)
  ordineReparto <- data.frame(numeroordine = seq(from = numReparto, to = 100*num), numreparto = rep(numReparto:numReparto, each = 100),
                              dataordine = sample(datePossibili, 100, replace = FALSE, ))
}


#Popolamento dei clienti
#inserimento("cliente.sql")

#Popolamento delle aziende
#inserimento("fornitore.sql")

#Popolamento dei numeri di telefono 
numerotel <- readLines("numeriTelefono.csv")
nomiAziende <- dbGetQuery(connect, "SELECT nome FROM fornitore")

aziendeRip1 <- data.frame(azienda = sample(nomiAziende$nome, 50, replace = FALSE))
aziendeRip2 <- data.frame(azienda = sample(nomiAziende$nome, 50, replace = TRUE))

aziendeFin <- rbind(aziendeRip1, aziendeRip2)
numeriTelefono <- cbind(numerotel, aziendeFin)
#dbWriteTable(connect, name = "numerotelefono", value = numeriTelefono, append = TRUE, row.names = FALSE)

#Popolamento reparto-manager con transazioni
#insertTransactionsManagerReparto("transactions.txt")

#Popolamento dipendenti
#inserimento("dipendente.sql")

#Popolamento prodotti
#inserimento("prodotto.sql")

#Popolamento delle forniture dei prodotti
fornitori <- dbGetQuery(connect, "SELECT nome FROM fornitore")
prodotti <- dbGetQuery(connect, "SELECT codice FROM prodotto")
forniture <- data.frame(fornitore = sample(fornitori$nome, 50, replace = TRUE), prodotto = sample(prodotti$codice, 300, replace = FALSE), 
                        prezzofornitura = round(runif(n = 300, min = 1, max = 100), 2))
#dbWriteTable(connect, name = "fornisce", value = forniture, append = TRUE, row.names = FALSE)

#Popolamento degli ordini dei reparti
dati <- dbGetQuery(connect, "select prodotto, numeroreparto, fornitore from fornisce f, prodotto p where f.prodotto = p.codice")
ordiniReparto <- data.frame(numeroordine = 1:1000, numreparto = )

