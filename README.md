# Funciones para extraer datos de Yahoo Finance

Este repositorio está diseñado para compartir algunas funciones que hice para descargar datos de Yahoo Finance. De todas estas funciones, la de mayor interés puede ser historico_multiples_precios()

Con esta, se utiliza, como argumentos de entrada, un vector de texto con los ticker de las acciones fondos, futuros o índices que deseas descargar (Te sugiero consultar [Yahoo financer](https://finance.yahoo.com)), así como la fecha inicial, la final y la periodicidad. Esta última puede ser diaria ("D"), semanal ("W") o mensual ("M").

Para cargar en R esta función debes correr el siguiente comando en tu chunk de R en Rstudio o en la consola:
```{r}
source("https://raw.githubusercontent.com/OscarVDelatorreTorres/yahooFinance/main/datosMultiplesYahooFinance.R")
```
Con esto, cargarás la función en tu ambiente de trabajo.

Para ver como funciona, puedes corres este ejemplo:


```{r}
# Ejemplo para descargar los históricos diarios de grupo Alfa, Microsoft en EEUU, Micrososft en México y el índice S&P/BMV IPC, desde el 1 de enrdo de 2023 a la fecha actual:
tickerV=c("ALFAA.MX","MSFT","MSFT.MX","^MXX")
deD="2023-01-01"
hastaD=Sys.Date()
per="D"

Datos=historico_multiples_precios(tickers=tickerV,de=deD,hasta=hastaD,periodicidad=per)
```
En este ejemplo, el objeto Datos es un objeto tipo lista con 3 de estos:

1. Una tabla con los precios de cierre y fechas homogeneizadas a las del primer ticker (ALFAA.MX).
2. Una tabla similar pero cn las variaciones porcentuales en tiempo contínuo.
3. Los objetos de los precios extraidos desde Yahoo Finance para cada ticker.
