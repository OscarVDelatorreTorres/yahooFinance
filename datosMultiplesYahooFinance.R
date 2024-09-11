# Arcivo de respaldo para ejecutar los compandos para la extracción de datos 
# de Yahoo Finance:

# Autor: Dr. Oscsr V. De la Torre-Torres
# website: https://oscardelatorretorres.com

# Versiones: ====

# V 1.0. 29-feb-2024: Funciones historico_multiples_precios y historico_precio_mkts con readme en GitHub.
# V 2.0 03-may-2024: Se agrega función historico_multiples_preciosFX para convertir a la divisa deseada en Yahoo.
# V 2.1c 15-ago-2024: Se corrige un error de conversión a moneda de preferencia con la función merge de la librería zoo.
# V 2.1c 27-ago-2024: Se corrige un error en la converciòn cambiaria de las acciones.
# V 3.0  11-sept-2024: Dejó de funcionar la URL y se solventó al utilizar la librería de tydiquant,
#                      así como yfinance de Python, por medio de reticulates para descargar información
#                      de fundamentald e Yahoo Finance.

# Verificación y/o instalación de las librerías necesarias:
if (!require(tidyverse)) {install.packages('tidyverse')
  library(tidyverse)} else {library(tidyverse)}
if (!require(zoo)) {install.packages('zoo')
  library(zoo)} else {library(zoo)}
if (!require(reticulate)) {install.packages('reticulate')
  library(reticulate)} else {library(reticulate)}
if (!require(tidyquant)) {install.packages('tidyquant')
  library(tidyquant)} else {library(tidyquant)}
if (!require(imputeTS)) {install.packages('imputeTS')
  library(imputeTS)} else {library(imputeTS)}

# Comandos a ejecutar para extraer información de Yahoo para múltiples RICS:====
 

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
      
      # Guarda lo extraído de precios al objeto tipo "lista" de salida:
      
      eval(parse(text=paste0("conjuntoSalida=list(",nombres[cuenta],"=",nombres[cuenta],")")))       
      
      # Guarda lo extraído de precios al objeto tipo "lista" de salida:
      
      eval(parse(text=paste0("conjuntoSalida=list(",nombres[cuenta],"=",nombres[cuenta],")")))      
    
      # Inserta valores de la primera serie de tiempo en la tabla de precios de salida:
      tablaString=paste0("tabla.precios=",
                         "data.frame(Date=",
                         nombres[cuenta],
                         "$date,",nombres[cuenta],"=",
                         nombres[cuenta],"$adjusted",
                         ")")
      eval(parse(text=tablaString))
      
      tabla.precios[,2]=na_locf(tabla.precios[,2],option="locf")
      
      
      
      # Inserta valores de la primera serie de tiempo en la tabla de rendimientos aritméticos de salida:
      tablaString2=paste0("tabla.PL=",
                          "data.frame(Date=",
                          nombres[cuenta],
                          "$date,",nombres[cuenta],"=",
                          nombres[cuenta],"$PL",
                          ")")
      
      eval(parse(text=tablaString2))  
      tabla.PL=tabla.PL[-1,]
      
      tabla.PL[,2]=na_replace(tabla.PL[,2],fill=0)
      
      # Inserta valores de la primera serie de tiempo en la tabla de rendimientos aritméticos de salida:
      tablaString3=paste0("tabla.rendimientosArit=",
                         "data.frame(Date=",
                         nombres[cuenta],
                         "$date,",nombres[cuenta],"=",
                         nombres[cuenta],"$rArit",
                         ")")
      
      eval(parse(text=tablaString3))    
      
      tabla.rendimientosArit=tabla.rendimientosArit[-1,]
      
      tabla.rendimientosArit[,2]=na_replace(tabla.rendimientosArit[,2],fill=0)
      
      # Inserta valores de la primera serie de tiempo en la tabla de rendimientos aritméticos de salida:
      tablaString4=paste0("tabla.rendimientosCont=",
                          "data.frame(Date=",
                          nombres[cuenta],
                          "$date,",nombres[cuenta],"=",
                          nombres[cuenta],"$rCont",
                          ")")
      
      eval(parse(text=tablaString4))          
    
      tabla.rendimientosCont=tabla.rendimientosCont[-1,]
      
      tabla.rendimientosCont[,2]=na_replace(tabla.rendimientosCont[,2],fill=0)
      
  # Else de cuenta cuando else>=2:----------------------------------
      

      
    } else {
      
      # Guarda lo extraído de precios al objeto tipo "lista" de salida:
      
      eval(parse(text=paste0("conjuntoSalida[['",nombres[cuenta],"']]=",nombres[cuenta])))       
      
      # Inserta valores de la primera serie de tiempo en la tabla de precios de salida:
      tablaString=paste0("tabla.preciosb=",
                         "data.frame(Date=",
                         nombres[cuenta],
                         "$date,",nombres[cuenta],"=",
                         nombres[cuenta],"$adjusted",
                         ")")
      eval(parse(text=tablaString))
      
      tabla.preciosb[,2]=na_locf(tabla.preciosb[,2],option="locf")
      
      tabla.precios=merge(tabla.precios,tabla.preciosb,by="Date",all=F)
      
      # Inserta valores de la primera serie de tiempo en la tabla de rendimientos aritméticos de salida:
      tablaString2=paste0("tabla.PLb=",
                          "data.frame(Date=",
                          nombres[cuenta],
                          "$date,",nombres[cuenta],"=",
                          nombres[cuenta],"$PL",
                          ")")
      
      eval(parse(text=tablaString2))  
      tabla.PLb=tabla.PLb[-1,]
      
      tabla.PLb[,2]=na_replace(tabla.PLb[,2],fill=0)
      
      tabla.PL=merge(tabla.PL,tabla.PLb,by="Date",all=F)
      
      # Inserta valores de la primera serie de tiempo en la tabla de rendimientos aritméticos de salida:
      tablaString3=paste0("tabla.rendimientosAritb=",
                          "data.frame(Date=",
                          nombres[cuenta],
                          "$date,",nombres[cuenta],"=",
                          nombres[cuenta],"$rArit",
                          ")")
      
      eval(parse(text=tablaString3))    
      
      tabla.rendimientosAritb=tabla.rendimientosAritb[-1,]
      
      tabla.rendimientosAritb[,2]=na_replace(tabla.rendimientosAritb[,2],fill=0)
      
      tabla.rendimientosArit=merge(tabla.rendimientosArit,tabla.rendimientosAritb,by="Date",all=F)
      
      # Inserta valores de la primera serie de tiempo en la tabla de rendimientos aritméticos de salida:
      tablaString4=paste0("tabla.rendimientosContb=",
                          "data.frame(Date=",
                          nombres[cuenta],
                          "$date,",nombres[cuenta],"=",
                          nombres[cuenta],"$rCont",
                          ")")
      
      eval(parse(text=tablaString4))          
      
      tabla.rendimientosContb=tabla.rendimientosContb[-1,]
      
      tabla.rendimientosContb[,2]=na_replace(tabla.rendimientosContb[,2],fill=0)
      
      tabla.rendimientosCont=merge(tabla.rendimientosCont,tabla.rendimientosContb,by="Date",all=F)
      
  # Else cuenta >=2 termina aquí:    
    }


    
    # cuenta loop ends here:  
  }  

  colnames(tabla.precios)=c("Date",nombres)
  colnames(tabla.PL)=c("Date",nombres)
  colnames(tabla.rendimientosArit)=c("Date",nombres)
  colnames(tabla.rendimientosCont)=c("Date",nombres)
  
  conjuntoSalida[["tablaPrecios"]]=tabla.precios
  conjuntoSalida[["tablaPL"]]=tabla.PL
  conjuntoSalida[["tablaRendimientosArit"]]=tabla.rendimientosArit
  conjuntoSalida[["tablaRendimientosCont"]]=tabla.rendimientosCont
  
  return(conjuntoSalida)
  # function ends here:
}


# Comando de extracción de precios de ticker individual ====
historico_precio_mkts <- function(ticker,de,hasta,periodicidad2)
{
  stringTicker=substr(ticker,1,1)
  
  if (stringTicker=="^"){
    ticker2=paste0("%5E",substr(ticker,2,nchar(ticker)))  
  } else {
    ticker2=ticker
  }
  
  
  
# deUnix=dateToUNIX(de)
#  hastaUnix=dateToUNIX(hasta)
  
  switch(periodicidad2,
         "D"={per="1d"},
         "W"={per="1wk"},
         "M"={per="1mo"}
         )
  
# Extrae datos históricos de cotizaciones con tidyquant:
  
tablaDatos = tq_get(ticker, from = de, to  = hasta)

# Agrega P/L, rendimientos y rendimientos contínuos:

tablaDatos=tablaDatos%>%mutate(PL=adjusted / lag(adjusted), 
                               rArit=(adjusted/lag(adjusted)-1)*100,
                               rCont=(log(adjusted) - lag(log(adjusted)))*100)
return(tablaDatos)
}


# Funciones de apoyo para fechas y manejo de otros inputs:====
dateToUNIX <- function(Date) {
  posixct <- as.POSIXct(as.Date(Date))
  trunc(as.numeric(posixct))
}

#convert UNIX timestamp to date 
# as.Date(as.POSIXct(x, origin="1970-01-01"))


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
