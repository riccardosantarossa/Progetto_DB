
setwd("C:/Users/brudo/Desktop/Progetto_DB")

#########################################
# Codice per il popolamento del database#
#########################################

# Connessione con RPostgres
library(RPostgres)
library(stringr)
library(ggplot2)

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

    df <- dbGetQuery(connect, "SELECT 1 
                               FROM reparto r, dipendente d 
                               WHERE d.cf = r.caporeparto AND d.cf = $1 AND d.numeroreparto = r.numero AND r.numero = $2;", vl)

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
forniture <- expand.grid(fornitore = fornitori$nome, prodotto = prodotti$codice)
forniture <- forniture[sample(nrow(forniture), 500, replace = FALSE), ]
forniture$prezzofornitura <- round(runif(n = 500, min = 1, max = 100), 2)

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
   #Estraggo casualmente 3 prodotti differenti da assegnare al cliente
   prodottiEstratti <- c(sample(qryProdotti$codice, 3, replace = FALSE))
   
   #Aggiungo riga per riga i prodotti contenuti nell'ordine contraddistinto dalla coppia ordineCliente-Cliente 
   #perchè ogni cliente effettua 3 ordini, che differiscono soltanto per il prodotto
   cheCosa<- rbind(cheCosa, list(qryOrdineCliente[i,]$numeroordine, qryOrdineCliente[i,]$cliente, prodottiEstratti[1], sample(1:50, 1)))
   
   cheCosa<- rbind(cheCosa, list(qryOrdineCliente[i,]$numeroordine, qryOrdineCliente[i,]$cliente, prodottiEstratti[2], sample(1:50, 1)))
   
   cheCosa<- rbind(cheCosa, list(qryOrdineCliente[i,]$numeroordine, qryOrdineCliente[i,]$cliente, prodottiEstratti[3], sample(1:50, 1)))
}

#Elimino la riga di intestazione del dataframe
cheCosa <- cheCosa[-1, ]
#dbWriteTable(connect, name = "checosa", value = cheCosa, append = TRUE, row.names = FALSE)


################################################
# Codice per statistiche e generazione dei plot#
################################################

#Palette di colori
colors <- terrain.colors(10)

#Plot 1. numero di dipendenti per ogni reparto
qryDipendentiReparti <- dbGetQuery(connect, "SELECT numeroreparto, count(cf)
                                             FROM dipendente
                                             GROUP BY numeroreparto
                                             ORDER BY numeroreparto asc")

v <- c(as.integer(qryDipendentiReparti$count))
datiPlot1 <- matrix(v, nrow = length(qryDipendentiReparti$numeroreparto))
rownames(datiPlot1) <- qryDipendentiReparti$numeroreparto
plt <- barplot(t(datiPlot1), main = "Numero di dipendenti per ogni reparto",
                xlab = "Numero del reparto", ylab = "Numero di dipendenti", ylim = c(20,40), las = 1, col = colors[1], xpd = FALSE)
text(x = plt, y = v + 0.5, labels = v)
dev.print(png, width = 800, height = 500, 'plot1.png')


#Plot 2. numero di prodotti di cui ogni reparto è responsabile, in percentuale
qryRepartiProdotti <- dbGetQuery(connect, "SELECT numeroreparto, COUNT(codice), r.nome 
                                           FROM prodotto p, reparto r
                                           WHERE numeroreparto = numero
                                           GROUP BY numeroreparto, r.nome                                           
                                           ORDER BY COUNT(codice) desc")
v <- c(as.integer(qryRepartiProdotti$count))
percentage <- paste((round(100*v/sum(v), 2)), "%")
legenda <-  as.character(qryRepartiProdotti$nome)
plot <- ggplot(qryRepartiProdotti, aes(x = "", y = count, fill = nome)) +
        geom_bar(stat = "identity", width = 1) +  
        coord_polar(theta = "y") +  
        theme_void() +  
        labs(title = "Suddivisione percentuale dei prodotti per reparto") +
        theme(legend.title = element_blank()) +
        scale_fill_manual(values = colors) +
        geom_text(aes(label = percentage), position = position_stack(vjust = 0.5), color = "black")
print(plot)
ggsave("plot2.png", plot = plot, width = 8, height = 5, dpi = 100)


#Plot 3. quantità di prodotti venduti dal reparto 9 nel corso del 2023
mesi <- c('2022-12-31', '2023-01-31', '2023-02-28', '2023-03-31', '2023-04-30', '2023-05-31',
          '2023-06-30', '2023-07-31', '2023-08-31', '2023-09-30', '2023-10-31', '2023-11-30', '2023-12-31')
mesi_str <- c("Gennaio ", "Febbraio ", "Marzo ", "Aprile ", "Maggio ", "Giugno ", "Luglio ", "Agosto ", "Settembre ",
              "Ottobre ", "Novembre ", "Dicembre ")
totali <- data.frame(tot = 0)
for(i in 1:12)
{
  prm <- list(mesi[i+1], mesi[i])
  qryOrdini <- dbGetQuery(connect, "SELECT oc.dataordine, SUM(cc.quantita)
                                    FROM prodotto p, checosa cc, ordinecliente oc 
                                    WHERE p.codice = cc.prodotto AND cc.numeroordine = oc.numeroordine 
                                          AND oc.cliente = cc.cliente AND p.numeroreparto = 9
                                    GROUP BY oc.dataordine
                                    HAVING oc.dataordine <= $1 AND oc.dataordine > $2
                                    ORDER BY oc.dataordine ASC", prm)
  totali <- rbind(totali, sum(c(as.integer(qryOrdini$sum))))
}

totali <- totali[-1,]
plot(1:12, totali, col = colors[1], lwd = 3,  type = "b", xlab = "Mesi dell'anno", ylab = "Quantità venduta", las = 1,
     ylim = c(3000, 4500), main = "Andamento delle vendite del reparto nr. 9 nel corso del 2023", xaxt = "n")
text(seq(1,12), srt = 90, adj = 1, xpd = TRUE, labels = mesi_str, cex = 1, par("usr")[3]-0.25)
dev.print(png, width = 800, height = 500, 'plot3.png')




