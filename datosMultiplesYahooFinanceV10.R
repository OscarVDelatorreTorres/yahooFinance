# Arcivo de respaldo para ejecutar los compandos para la extracción de datos 
# de Yahoo Finance:



# Se define el Token de consulta en Banxico:
banxico.token="b6b5b54077d88fce3eb64e2b92b0fc188923abe20cefc65a9f569b70f483128a"
setToken(banxico.token)
# Comando para descargas m?ltiples:

# --------------
#---- Comandos a ejecutar para extraer información de Yahoo:

historico_multiples_precios=function(tickers,de,hasta,periodicidad="D"){
  
  nombres=tickers
  
  # Crea los nombres de la tabla de salida sin caracteres especiales de los tickers de ?ndices:
  for (cuenta in 1:length(tickers)){
    if (substr(nombres[cuenta],1,1)=="^"){
      nombres[cuenta]=substr(tickers[cuenta],2,nchar(tickers[cuenta]))
    }
    
    nombres[cuenta]=str_replace(nombres[cuenta],"=","")
    
  }
  
  
  #length(nombres)
  for (cuenta in 1:length(nombres)){
    # Extrae 1 a 1 los hist?ricos de cada ticker y forma la tabal de salida
    
    queryString=paste0(nombres[cuenta],"=historico_precio_mkts('",tickers[cuenta],
                       "',de=de,hasta=hasta,periodicidad=periodicidad)")
    
    cat("\f")
    print(paste0("Extrayendo RIC ",cuenta," de ",length(tickers)," (",
                 tickers[cuenta],"), periodicidad ",periodicidad))
    
    eval(parse(text=queryString))
    
    # Anexa las columnas de datos a la tabla total de salida:
    
    if (cuenta<2){
      
      # Guarda lo extra?do de precios al objeto tipo "lista" de salida:
      
      eval(parse(text=paste0("conjuntoSalida=list(",nombres[cuenta],"=as.data.frame(",nombres[cuenta],"))")))
      
      tablaString=paste0("tabla.salida=data.frame(Date=",nombres[cuenta],
                         "$Date,",nombres[cuenta],"=as.numeric(",nombres[cuenta],"$Adj.Close))")
      eval(parse(text=tablaString))
      
      
      
    } else {
      
      eval(parse(text=paste0("conjuntoSalida$",nombres[cuenta],"=as.data.frame(",nombres[cuenta],")")))
      
      # Es la segunda o mayor serie a integrar en la tabla:
      
      tablaString2=paste0("tabla.salida=cbind(tabla.salida,data.frame(Val",cuenta,"=as.numeric(matrix(NA,nrow(tabla.salida),1))))")
      
      eval(parse(text=tablaString2))
      
      # Determina la fecha inicial a evaluar en la serie de tiempo:  
      
      minSerie=eval(parse(text=paste0("min(",nombres[cuenta],"$Date)")))
      minTabla=min(tabla.salida$Date)
      
      if (minTabla<minSerie){
        inicioFechas=max(which(tabla.salida$Date<=minSerie))
      } else { 
        inicioFechas=1L
      }
      # Cuenta de cada fecha a homonegenizar: 
      
      for (cuenta2 in inicioFechas:nrow(tabla.salida)){
        
        cat("\f")
        print(paste0("Procesando RIC ",cuenta," de ",length(tickers)," (",
                     tickers[cuenta],") fecha ",cuenta2," de ",nrow(tabla.salida)," periodicidad ",periodicidad))
        
        idFecha=eval(parse(text=paste0("max(which(",nombres[cuenta],"$Date<=tabla.salida$Date[cuenta2]))")))
        eval(parse(text=paste0("tabla.salida$Val",cuenta,"[cuenta2]=",nombres[cuenta],"$Adj.Close[idFecha]")))
      }
      
    }
    # Loop cuenta2 (fechas homogeneizadas) ends here:  
    
    # Corrige los textos "null" propios de Yahoo Finance y los convierte 
    # a valor NA para ser corregidos posteriormente:
    
    naRowId=which(tabla.salida[,cuenta+1]=="null")        
    
    if (length(naRowId)>0){
      tabla.salida[naRowId,cuenta+1]=NA
    }
    # Corrige los NA de la primera fila si y solo si hay valores en la segunda
    
    if (!is.na(tabla.salida[2,cuenta+1])){
      
      if (is.na(tabla.salida[1,cuenta+1])){
        tabla.salida[1,cuenta+1]=tabla.salida[2,cuenta+1]
      }
    }
    
    # Corrige los valores de todas las primeras filas si la primera fila no ha sido corregida:
    
    if (is.na(tabla.salida[1,cuenta+1])) {
      naRowId=which(is.na(tabla.salida[,cuenta+1]))
      tabla.salida[naRowId,cuenta+1]=0
    } 
    
    # Hace una revision final de que no queden valores NA en filas intermedias
    # que no sean la primera o primeras:
    
    naRowId=which(is.na(tabla.salida[,cuenta+1]))    
    
    if (length(naRowId)>0){
      tabla.salida[naRowId,cuenta+1]=tabla.salida[naRowId+1,cuenta+1]
    }
    
    # cuenta loop ends here:  
  }  
  
  
  
  # Genera ajustes finos de la tabla de salida y la anexa al objeto
  colnames(tabla.salida)=c("Date",nombres)
  
  tabla.salida=as.data.frame(tabla.salida)
  
  conjuntoSalida[["tablaPrecios"]]=tabla.salida
  
  # calcular rendimientos cont?nuos y los anexa al objeto:
  
  tablaRendimientosC=tabla.salida
  
  tablaRendimientosC[2:nrow(tabla.salida),2:ncol(tabla.salida)]=log(as.numeric(as.matrix(tabla.salida[2:nrow(tabla.salida),2:ncol(tabla.salida)])))-
    log(as.numeric(as.matrix(tabla.salida[1:(nrow(tabla.salida)-1),2:ncol(tabla.salida)])))
  
  tablaRendimientosC=tablaRendimientosC[-1,]
  
  # Corrige valores inf en los valores estimados e iguala a cero:
  
  for (a in 2:ncol(tablaRendimientosC)){
    naRowId=which(is.infinite(tablaRendimientosC[,a]))
    if (length(naRowId)>0){
      tablaRendimientosC[naRowId,a]=0
    }
  }  
  
  # Guegra la tabla de rendimientos en el objeto de salida:    
  conjuntoSalida[["tablaRendimientosC"]]=tablaRendimientosC
  conjuntoSalida[["nombres"]]=nombres
  
  return(conjuntoSalida)
  # function ends here:
}

#==================================
# Comando de extraci?n de precios de ticker individual 
historico_precio_mkts <- function(ticker,de,hasta,periodicidad2)
{
  tmp <- tempfile()
  yahoo <- httr::handle('https://finance.yahoo.com/quote/')
  
  deUnix=.dateToUNIX(de)
  hastaUnix=.dateToUNIX(hasta)
  
  switch(periodicidad2,
         "D"={per="1d"},
         "W"={per="1wk"},
         "M"={per="1mo"}
         )
  
  'https://finance.yahoo.com/quote/' %>%
    paste0(ticker)                    %>%
    paste0('/history?p=')              %>%
    paste0(ticker)                    %>%
    httr::GET(handle = yahoo)          %>%
    httr::content("text")               -> raw_html
  
  strsplit(raw_html, "crumb\":\"")   %>%
    unlist                             %>%
    strsplit("\"")                     %>%
    lapply(`[`, 1)                     %>%
    unlist                             %>%
    table                              %>%
    sort                               %>%
    rev                                %>%
    names                              %>%
    `[`(2)                             %>% 
    paste0("https://query1.finance.yahoo.com/v7/finance/download/", ticker, 
           "?period1=",deUnix,"&period2=",hastaUnix,"&interval=",per,"&events=history&crumb=", .) %>%
    httr::GET(handle = yahoo) %>%
    httr::content("text", encoding = "UTF-8") %>%
    writeBin(tmp, useBytes = T)
  
  suppressWarnings(read.csv(tmp) %>% tibble::as_tibble())
}

.dateToUNIX <- function(Date) {
  posixct <- as.POSIXct(as.Date(Date, origin = "1970-01-01"))
  trunc(as.numeric(posixct))
}

fechaTexto=function(fecha){
  textosMes=data.frame(ID=c(1,2,3,4,5,6,7,8,9,10,11,12),
                       Texto=c("enero",
                               "febrero",
                               "marzo",
                               "abril",
                               "mayo",
                               "junio",
                               "julio",
                               "agosto",
                               "septiembre",
                               "octubre",
                               "noviembre",
                               "diciembre"))
  diaId=day(fecha)
  mesId=month(fecha)
  mesTexto=textosMes$Texto[which(textosMes$ID==mesId)]
  yearId=year(fecha)
  textoFecha=paste0(diaId," de ",mesTexto," del ",yearId)
  return(textoFecha)
}

print("Comandos de descarga de datos de burs?tiles instalados...")
