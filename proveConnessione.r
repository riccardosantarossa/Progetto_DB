
#Connessione al database

library(DBI)

db <- "Esame310122"  
host_db <- "localhost" 
db_port <- "5432" 
db_user <- "postgres"  
db_password <- "1234"
con <- dbConnect(RPostgres::Postgres(), dbname = db, host=host_db, port=db_port, user=db_user, password=db_password)  


#----------------------------------------------------------------------------------------#

query1 <- 'SELECT nome, cognome, COUNT(atleta) as NumeroVittorie
           FROM maratoneta, vincitore
           WHERE codicemaratoneta = atleta
           GROUP BY atleta, nome, cognome'

req <- dbSendQuery(con, query1)
res <- dbFetch(req)

#Plot vittorie

lbls <- c("atleta 1", "atleta 2", "atleta 3")
#data <- c(res["numerovittorie"])
data <- c(2, 1, 2)

#print(data)
barplot(data, names.arg = lbls)


