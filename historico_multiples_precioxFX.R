historico_multiples_preciosFX=function(tickers,FX,de,hasta,periodicidad="D"){
  
  nombres=tickers
  
  # Crea los nombres de la tabla de salida sin caracteres especiales de los tickers de ?ndices:
  for (cuenta in 1:length(tickers)){
    if (substr(nombres[cuenta],1,1)=="^"){
      nombres[cuenta]=substr(tickers[cuenta],2,nchar(tickers[cuenta]))
    }
    
    nombres[cuenta]=str_replace(nombres[cuenta],"=","")
    
  }

# Extrae la divisa a convertir en algunos casos  
FXs=unique(FX)  
localId=which(FXs=="Local")  
FXs=FXs[-localId]


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
      
      eval(parse(text=paste0("conjuntoSalida=list(",nombres[cuenta],"=",nombres[cuenta],")")))
      
      tablaString=paste0("tabla.salida=",
                         "data.frame(Date=",
                         nombres[cuenta],
                         "$Date,",nombres[cuenta],"=",
                         nombres[cuenta],"$Adj.Close",
                         ")")
      
      eval(parse(text=tablaString))
      
      
      
    } else {
      
      eval(parse(text=paste0("conjuntoSalida$",nombres[cuenta],"=",nombres[cuenta])))
      
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
    
    # convierte a moneda local según se indica en el objeto FX:
    
    moneda=FX[cuenta]
    
    if (!moneda=="Local"){
     
    # Extrae los tipos de cambio históricos:
    
    queryStringFX=paste0("FX[cuenta]","=historico_precio_mkts('",FX[cuenta],
                       "',de=de,hasta=hasta,periodicidad=periodicidad)")
    
    # Homogeneiza la serie de tiempok
    
    eval(parse(text=queryStringFX))  
    
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
