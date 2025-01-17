
# Connessione con RPostgres
library(RPostgres)
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

#Popolamento dei reparti


#print(numeriTelefono)








