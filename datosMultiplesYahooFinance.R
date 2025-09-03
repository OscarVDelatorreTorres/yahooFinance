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
#                      así como yfinance de Python, por medio de reticulate para descargar información
#                      de fundamentald e Yahoo Finance.
# V 3.1  21-oct-2024: Se corrige un error para el "=" en los futuros de Yahoo Finance para que el nombre 
# no incluya tal caracter y genere errores al exportar los datos.

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


historico_multiples_precios=function(tickers,de,hasta,periodicidad="D",fxRate="USDMXN=X",whichToFX="none"){

  nombres=tickers
  convertFXOk=FALSE
  # Crea los nombres de la tabla de salida sin caracteres especiales de los tickers de ?ndices:
  for (cuenta in 1:length(tickers)){
    if (substr(nombres[cuenta],1,1)=="^"){
      nombres[cuenta]=substr(tickers[cuenta],2,nchar(tickers[cuenta]))
    }

    nombres[cuenta]=str_replace(nombres[cuenta],"=","")

  }

  if (is.logical(whichToFX)) {

    if (length(whichToFX)==length(tickers)){
      convertFXOk=TRUE

    } else {
      stop("El vector de conversión a moneda  whichToFX no tiene la misma longitud que el vector de tickers.")
    }

  } else {

    if (is.character(whichToFX)) {
      switch(whichToFX,
             "All"={ whichToFX=rep(TRUE,length(tickers))
             convertFXOk=TRUE},
             "all"={ whichToFX=rep(TRUE,length(tickers))
             convertFXOk=TRUE},
             "ALL"={ whichToFX=rep(TRUE,length(tickers))
             convertFXOk=TRUE},
             "NONE"={ whichToFX=rep(FALSE,length(tickers)) },
             "none"={ whichToFX=rep(FALSE,length(tickers)) },
             "None"={ whichToFX=rep(FALSE,length(tickers)) },
             "NoNe"={ whichToFX=rep(FALSE,length(tickers)) }
             )
    }


  }


  #length(nombres)
  for (cuenta in 1:length(nombres)){
    # Extrae 1 a 1 los hist?ricos de cada ticker y forma la tabal de salida

    if (isTRUE(whichToFX[cuenta])){

      queryString=paste0("datosYahoo=historico_precio_mkts('",tickers[cuenta],
                         "',de=de,hasta=hasta,periodicidad=periodicidad,fxRate='",
                         fxRate,"')")

    } else {

      queryString=paste0("datosYahoo=historico_precio_mkts('",tickers[cuenta],
                         "',de=de,hasta=hasta,periodicidad=periodicidad,fxRate='none')")

    }

    cat("\f")
    print(paste0("Extrayendo RIC ",cuenta," de ",length(tickers)," (",
                 tickers[cuenta],"), periodicidad ",periodicidad))

    eval(parse(text=queryString))



    # Anexa las columnas de datos a la tabla total de salida:

    if (cuenta<2){

      # Guarda lo extraído de precios al objeto tipo "lista" de salida:

      eval(parse(text=paste0("conjuntoSalida=list(",nombres[cuenta],"=as.data.frame(datosYahoo$",nombres[cuenta],"))")))


      # Inserta valores de la primera serie de tiempo en la tabla de precios de salida:

      eval(parse(text=paste0("tablaDatos=conjuntoSalida$",nombres[cuenta])))

      tablaString=paste0("tabla.precios=data.frame(Date=tablaDatos$date,",
                         nombres[cuenta],
                         "=tablaDatos$adjusted)")

      eval(parse(text=tablaString))

      tablaString=paste0("tabla.precios$",nombres[cuenta],"=na_locf(tabla.precios$",nombres[cuenta],",option='locf')")

      eval(parse(text=tablaString))

      # Inserta valores de la primera serie de tiempo en la tabla de P/L de salida:
      tablaString2=paste0("tabla.PL=data.frame(Date=tablaDatos$date,",
                          nombres[cuenta],
                          "=tablaDatos$PL)")

      eval(parse(text=tablaString2))
      tabla.PL=tabla.PL[-1,]

      tablaString2=paste0("tabla.PL$",nombres[cuenta],
                         "=na_replace(tabla.PL$",nombres[cuenta],",fill=0)")

      eval(parse(text=tablaString2))


      # Inserta valores de la primera serie de tiempo en la tabla de rendimientos aritméticos de salida:
      tablaString3=paste0("tabla.rendimientosArit=data.frame(Date=tablaDatos$date,",
                          nombres[cuenta],
                          "=tablaDatos$rArit)")

      eval(parse(text=tablaString3))

      tabla.rendimientosArit=tabla.rendimientosArit[-1,]

      tablaString3=paste0("tabla.rendimientosArit$",nombres[cuenta],
                         "=na_replace(tabla.rendimientosArit$",nombres[cuenta],",fill=0)")

      eval(parse(text=tablaString3))

      # Inserta valores de la primera serie de tiempo en la tabla de rendimientos aritméticos de salida:
      tablaString4=paste0("tabla.rendimientosCont=data.frame(Date=tablaDatos$date,",
                          nombres[cuenta],
                          "=tablaDatos$rCont)")

      eval(parse(text=tablaString4))

      tabla.rendimientosCont=tabla.rendimientosCont[-1,]

      tablaString4=paste0("tabla.rendimientosCont$",nombres[cuenta],
                          "=na_replace(tabla.rendimientosCont$",nombres[cuenta],",fill=0)")

      eval(parse(text=tablaString4))

  # Else de cuenta cuando else>=2:----------------------------------
    } else {

      # Guarda lo extraído de precios al objeto tipo "lista" de salida:

      eval(parse(text=paste0("conjuntoSalida$",nombres[cuenta],"=datosYahoo$",nombres[cuenta])))


      #eval(parse(text=paste0("conjuntoSalida[['",nombres[cuenta],"']]=",nombres[cuenta])))

      # Inserta valores de la primera serie de tiempo en la tabla de precios de salida:

      eval(parse(text=paste0("tablaDatos=conjuntoSalida$",nombres[cuenta])))

      tablaString=paste0("tabla.preciosb=data.frame(Date=tablaDatos$date,",
                         nombres[cuenta],
                         "=tablaDatos$adjusted)")

      eval(parse(text=tablaString))

      tablaString=paste0("tabla.preciosb$",nombres[cuenta],
                         "=na_locf(tabla.preciosb$",nombres[cuenta],",option='locf')")

      eval(parse(text=tablaString))

      tabla.precios=merge(tabla.precios,tabla.preciosb,by="Date",all=F)

      # Inserta valores de la primera serie de tiempo en la tabla de P/L de salida:
      tablaString2=paste0("tabla.PLb=data.frame(Date=tablaDatos$date,",
                          nombres[cuenta],
                          "=tablaDatos$PL)")

      eval(parse(text=tablaString2))
      tabla.PLb=tabla.PLb[-1,]

      tablaString2=paste0("tabla.PLb$",nombres[cuenta],
                          "=na_replace(tabla.PLb$",nombres[cuenta],",fill=0)")

      eval(parse(text=tablaString2))

      tabla.PL=merge(tabla.PL,tabla.PLb,by="Date",all=F)

      # Inserta valores de la primera serie de tiempo en la tabla de rendimientos aritméticos de salida:
      tablaString3=paste0("tabla.rendimientosAritb=data.frame(Date=tablaDatos$date,",
                          nombres[cuenta],
                          "=tablaDatos$rArit)")

      eval(parse(text=tablaString3))

      tabla.rendimientosAritb=tabla.rendimientosAritb[-1,]

      tablaString3=paste0("tabla.rendimientosAritb$",nombres[cuenta],
                          "=na_replace(tabla.rendimientosAritb$",nombres[cuenta],",fill=0)")

      eval(parse(text=tablaString3))

      tabla.rendimientosArit=merge(tabla.rendimientosArit,tabla.rendimientosAritb,by="Date",all=F)

      # Inserta valores de la primera serie de tiempo en la tabla de rendimientos aritméticos de salida:
      tablaString4=paste0("tabla.rendimientosContb=data.frame(Date=tablaDatos$date,",
                          nombres[cuenta],
                          "=tablaDatos$rCont)")

      eval(parse(text=tablaString4))

      tabla.rendimientosContb=tabla.rendimientosContb[-1,]

      tablaString4=paste0("tabla.rendimientosContb$",nombres[cuenta],
                          "=na_replace(tabla.rendimientosContb$",nombres[cuenta],",fill=0)")

      eval(parse(text=tablaString4))

      tabla.rendimientosCont=merge(tabla.rendimientosCont,tabla.rendimientosContb,by="Date",all=F)

  # Else cuenta >=2 termina aquí:
    }

    # cuenta loop ends here:
  }
  

  tablaPreciosFigura=pivot_longer(tabla.precios,
                                        cols=-Date,
                                        names_to="RIC",
                                        values_to="Precio")
  tablaPLFigura=pivot_longer(tabla.PL,
                                  cols=-Date,
                                  names_to="RIC",
                                  values_to="PL") 
  tablaRendAritFigura=pivot_longer(tabla.rendimientosArit,
                             cols=-Date,
                             names_to="RIC",
                             values_to="rendimientoAritmetico") 
  tablaRendContFigura=pivot_longer(tabla.rendimientosCont,
                                   cols=-Date,
                                   names_to="RIC",
                                   values_to="rendimientoContinuo")   
  
  
  colnames(tabla.precios)=c("Date",nombres)
  colnames(tabla.PL)=c("Date",nombres)
  colnames(tabla.rendimientosArit)=c("Date",nombres)
  colnames(tabla.rendimientosCont)=c("Date",nombres)

  conjuntoSalida[["tablaPrecios"]]=tabla.precios
  conjuntoSalida[["tablaPL"]]=tabla.PL
  conjuntoSalida[["tablaRendimientosArit"]]=tabla.rendimientosArit
  conjuntoSalida[["tablaRendimientosCont"]]=tabla.rendimientosCont
  conjuntoSalida[["tablaPreciosFigura"]]=tablaPreciosFigura
  conjuntoSalida[["tablaPLFigura"]]=tablaPLFigura
  conjuntoSalida[["tablaRendAritFigura"]]=tablaRendAritFigura
  conjuntoSalida[["tablaRendContFigura"]]=tablaRendContFigura

  cat("\f")
  print(paste0("Se terminó de extraer y procesar un total de ",length(tickers),
               " tickers desde las BD de Yahoo Finance..."))
  print(paste0("Tickers procesados: ",paste0(tickers,collapse=", ")))
  return(conjuntoSalida)
  # function ends here:
}


# Comando de extracción de precios de ticker individual ====
historico_precio_mkts <- function(ticker,de,hasta,periodicidad,fxRate)
{

   stringTicker=substr(ticker,1,1)

  if (stringTicker=="^"){
    ticker2=paste0("%5E",substr(ticker,2,nchar(ticker)))
    nombre=substr(ticker,2,nchar(ticker))
  } else {
    ticker2=ticker
    nombre=ticker
  }
   
   charId=str_locate(ticker, "=")[1]
   
   if (!is.na(charId)){
     nombre=paste0(substr(ticker,1,charId-1),substr(ticker,charId+1,str_count(ticker)))
   } 



# Extrae datos históricos de cotizaciones con tidyquant:

print(paste0("Extrayendo ",ticker,"..."))

tablaDatos = tq_get(ticker, from = de, to  = hasta)

# Convierte los datos originales al tipo de cambio deseado:

if (!(fxRate=="none")){

print(paste0("Convirtiendo ",ticker," con paridad cambiaria ",fxRate,"..."))

  tablaDatosFX = tq_get(fxRate, from = de, to  = hasta)
  tablaDatosFX=data.frame(date=tablaDatosFX$date,
                          FX=tablaDatosFX$adjusted)
  tablaDatosFX=tablaDatos%>%merge(tablaDatosFX,by="date",all.x=T)

  tablaDatosFX=data.frame(date=tablaDatosFX$date,
                          FX=tablaDatosFX$FX)
  tablaDatosFX$FX=na_locf(tablaDatosFX$FX,option="locf")

  tablaDatos$open=tablaDatos$open*tablaDatosFX$FX
  tablaDatos$high=tablaDatos$high*tablaDatosFX$FX
  tablaDatos$low=tablaDatos$low*tablaDatosFX$FX
  tablaDatos$close=tablaDatos$close*tablaDatosFX$FX
  tablaDatos$adjusted=tablaDatos$adjusted*tablaDatosFX$FX

  }


# Convierte la periodicidad solicitada:

switch(periodicidad,
       "W"={
         print(paste0("Convirtiendo ",ticker," a frecuencia",periodicidad,"..."))
         tablaDatos=tablaDatos%>%tq_transmute(mutate_fun = to.weekly)

       },
       "M"={
         print(paste0("Convirtiendo ",ticker," a frecuencia",periodicidad,"..."))
         tablaDatos=tablaDatos%>%tq_transmute(mutate_fun = to.monthly)
       },
       "Q"={
         print(paste0("Convirtiendo ",ticker," a frecuencia",periodicidad,"..."))
         tablaDatos=tablaDatos%>%tq_transmute(mutate_fun = to.quarterly)
       },
       "Y"={
         print(paste0("Convirtiendo ",ticker," a frecuencia",periodicidad,"..."))
         tablaDatos=tablaDatos%>%tq_transmute(mutate_fun = to.yearly)
       }
)


# Agrega P/L, rendimientos y rendimientos contínuos:

tablaDatos=tablaDatos%>%mutate(PL=adjusted / lag(adjusted),
                               rArit=(adjusted/lag(adjusted)-1)*100,
                               rCont=(log(adjusted) - lag(log(adjusted)))*100)

if (!(fxRate=="none")){
stringSalida=paste0("objetoSalida=list(",nombre,"=tablaDatos,tablaFXYahoo=tablaDatosFX)")

} else {
  stringSalida=paste0("objetoSalida=list(",nombre,"=tablaDatos)")

}

print(paste0(nombre," extraído de Yahoo Finance..."))
eval(parse(text=stringSalida))
return(objetoSalida)
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
  textoMesYearText=paste0(mesTexto," del ",yearId)
  textoMesYearDash=paste0(mesTexto,"-",yearId)
  textoFechaGuion=paste0(diaId,"-",mesTexto,"-",yearId)
  textoFechaDash=paste0(diaId,"/",mesTexto,"/",yearId)
  
  textosFechas=list(textoFecha=textoFecha,
                    textoMesYearText=textoMesYearText,
                    textoMesYearDash=textoMesYearDash,
                    textoFechaGuion=textoFechaGuion,
                    textoFechaDash=textoFechaDash,
                    mesTexto=mesTexto)
  return(textosFechas)
}

# This function is a wrape and alterative of the merge function in the base R library.
# The purpose of this function is to merge two data frames by a common column: the first one.
# Because this function is part of an R quantitative library, the first columns of both data.frames
# must be a date vector. 

#I created the first version of the mergeTSDataFrames function to merge two multivariate 
# data.frames with different or equal periodicities

mergeTSDataFrame=function(df1,df2,timeUnits){
  # Check if the first column of both data frames is a date vector
  if (!inherits(df1[[1]], "Date") || !inherits(df2[[1]], "Date")) {
    stop("Atention! The first column of both data frames must be a date vector.")
  }
  
  # Convert the first column of both data frames to the same format
  df1[[1]] <- as.Date(df1[[1]])
  df2[[1]] <- as.Date(df2[[1]])
  getOption("lubridate.week.start", 7)
  
  nDates=nrow(df1)
  df1[[1]]=floor_date(df1[[1]],unit=timeUnits,week_start=7) 
  merged_df=cbind(df1,data.frame(matrix(NA,nrow=nDates,ncol=ncol(df2)-1)))
  colnames(merged_df)=c(names(df1),colnames(df2)[-1])
  mergedDfStartCol=ncol(df1)+1

  
  # Checks if the min date is in df2:
  
  if (min(df1[[1]])<min(df2[[1]])) {
    startDateRow=which(df2[,1]<=min(df1[,1]))
    if (length(startDateRow)>0){
      mergedDfStartRow=max(startDateRow)
    } else {
      mergedDfStartRow=1
    }
    
  } else {
    mergedDfStartRow=1
  }
  

  
   
  # Fill the merged data frame with the values from df1
  for (a in mergedDfStartRow:nDates){
    merged_df[a,mergedDfStartCol:(ncol(merged_df))]=
      as.numeric(tail(df2[max(which(df2[,1]<=df1[a,1])),2:ncol(df2)],1))
  }
  
  # If there are remaining NA values in the merged data frame, 
  # fill them with the last non-NA value:
  for (a in 2:ncol(merged_df)){
    merged_df[,a]=na_locf(merged_df[,a])
  }
  
  # Return the merged data frame
  return(merged_df)
}


print("All the quantitative finance functions loaded...")
