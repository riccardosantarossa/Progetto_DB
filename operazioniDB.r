
#Connessione al database

library("RPostgreSQL")
driver <- dbDriver("PostgreSQL")
connect <- dbConnect(diver, dbname = "progettoDB")

dbGetQuery(connect, "SET search_path TO public;")

dbListTables(connect)
