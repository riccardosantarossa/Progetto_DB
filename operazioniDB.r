
# Connessione con RPostgres
library(RPostgres)
connect <- dbConnect(RPostgres::Postgres(), dbname = "progettoDB", host = "localhost", 
                     port = 5432, user = "postgres", password = "1234")


#Popolamento dei clienti
nomi <- readLines("nomi.txt")
cognomi <- readLines("cognomi.txt")
indirizzi <- readLines("indirizzi.txt")

clienti <- data.frame(nome = paste(sample(nomi, 1000, replace = FALSE), sample(cognomi, 1000, replace = FALSE), sep = " "),
                      indirizzo = sample(indirizzi, 1000, replace = FALSE))

dbWriteTable(connect, name = "cliente", value = clienti, append = TRUE, row.names = F)

#Popolamento delle aziende con relativi numeri di telefono 
numeriTelefonoPossibili <- readLines("numeriTelefono.txt")
nomiAziende <- readLines("nomiAziende.txt")

fornitore <- data.frame(nome = sample(nomiAziende, 50, replace = FALSE),
                        indirizzo = sample(indirizzi, 50, replace = FALSE))

aziendeRip1 <- data.frame(azienda = sample(fornitore$nome, 50, replace = FALSE))
aziendeRip2 <- data.frame(azienda = sample(fornitore$nome, 50, replace = TRUE))

aziendeFin <- rbind(aziendeRip1, aziendeRip2)

numeriTelefonoTot <- data.frame(numerotel = sample(numeriTelefonoPossibili, 100, replace = FALSE))
numeriTelefono <- cbind(numeriTelefonoTot, aziendeFin)

dbWriteTable(connect, name = "fornitore", value = fornitore, append = TRUE, row.names = F)
dbWriteTable(connect, name = "numerotelefono", value = numeriTelefono, append = TRUE, row.names = F)

