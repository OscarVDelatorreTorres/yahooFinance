
# Función de yahoo finance original:
# Comando de extracción de precios de ticker individual ====
historico_precio_mkts <- function(ticker,de,hasta,periodicidad2)
{
  stringTicker=substr(ticker,1,1)
  
  if (stringTicker=="^"){
    ticker2=paste0("%5E",substr(ticker,2,nchar(ticker)))  
  } else {
    ticker2=ticker
  }
  
  
  
  deUnix=dateToUNIX(de)
  hastaUnix=dateToUNIX(hasta)
  
  switch(periodicidad2,
         "D"={per="1d"},
         "W"={per="1wk"},
         "M"={per="1mo"}
  )
  
  #print(paste0("Extrayendo ",ticker2, " de ",deUnix," hasta ",hastaUnix))  
  #"https://query1.finance.yahoo.com/v7/finance/download/%5EMXX?period1=1642530890&period2=1674066890&interval=1d&events=history&includeAdjustedClose=true"
  
  URLYahoo=paste0("https://query1.finance.yahoo.com/v7/finance/download/",
                  ticker2,
                  "?period1=",
                  deUnix,
                  "&period2=",
                  hastaUnix,
                  "&interval=",
                  per,
                  "&events=history&includeAdjustedClose=true"
  )  
  #cat("\f")
  
  #print(URLYahoo)
  
  tablaDatos=read.csv(URLYahoo)
  return(tablaDatos)
}