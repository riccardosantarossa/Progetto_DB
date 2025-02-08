
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
date <- 1:365 + as.Date("2023/01/01")
for (i in 1:10) 
{
  prodReparto <- dbGetQuery(connect, "SELECT fornitore, codice FROM prodotto, fornisce WHERE codice = prodotto AND numeroreparto = $1", i)
  
  ordini <- data.frame(numeroordine = seq(1, 100), numreparto = rep(i, each = 100), dataordine = sample(date, 100, replace = FALSE), 
                       quantita = round(runif(n=100, min=1, max=50), 0))
  
  temp <- prodReparto[sample(1:nrow(prodReparto), 100, replace = TRUE),]
  ordini$fornitore <- temp$fornitore
  ordini$prodotto <- temp$codice
  
  #dbWriteTable(connect, name = "ordinereparto", value = ordini, append = TRUE, row.names = FALSE)
}

#Popolamento dei clienti
#inserimento("cliente.sql")

#Popolamento degli ordini dei clienti
qryCliente <- dbGetQuery(connect, "SELECT nome FROM cliente")
for (i in 1:nrow(qryCliente))
{
  repCliente <- c(rep(qryCliente[i,], 5, each = 1))
  ordineCliente <- data.frame(numeroordine = seq(1,5), cliente = repCliente, dataordine = sample(date, 5), saldo = 0)
  #dbWriteTable(connect, name = "ordinecliente", value = ordineCliente, append =  TRUE, row.names = FALSE)
}

#Popolamento della tabella "CheCosa"
qryProdotti <- dbGetQuery(connect, "SELECT codice FROM prodotto")
qryOrdineCliente <- dbGetQuery(connect, "SELECT numeroordine, cliente FROM ordinecliente")

#Creazione del dataframe da popolare per riga in modo incrementale
cheCosa <- data.frame(numeroordine = 0, cliente = "", prodotto = 0, quantita = 0)

for(i in 1:nrow(qryOrdineCliente))
{
   #Aggiungo riga per riga i prodotti contenuti nell'ordine contraddistinto dalla coppia ordineCliente-Cliente
   cheCosa<- rbind(cheCosa, list(qryOrdineCliente[i,]$numeroordine, qryOrdineCliente[i,]$cliente,
                                 sample(qryProdotti$codice, 1), sample(1:50, 1)))
   cheCosa<- rbind(cheCosa, list(qryOrdineCliente[i,]$numeroordine, qryOrdineCliente[i,]$cliente,
                                 sample(qryProdotti$codice, 1), sample(1:50, 1)))
   cheCosa<- rbind(cheCosa, list(qryOrdineCliente[i,]$numeroordine, qryOrdineCliente[i,]$cliente,
                                 sample(qryProdotti$codice, 1), sample(1:50, 1)))
}

cheCosa <- cheCosa[-1, ]
#dbWriteTable(connect, name = "checosa", value = cheCosa, append = TRUE, row.names = FALSE)




