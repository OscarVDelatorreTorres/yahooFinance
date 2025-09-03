# Funciones para extraer datos de Yahoo Finance

Para cargar en R estas funciones en R debes correr el siguiente comando en tu chunk de R en Rstudio o en la consola, tu archivo de quarto o Rscript:

```{r}
source("https://raw.githubusercontent.com/OscarVDelatorreTorres/yahooFinance/main/datosMultiplesYahooFinance.R")
```
Con esto, cargarás las funciones en tu ambiente de trabajo, junto con las funciones de apoyo para manipulación de fechas, así como la extracción individual de un solo RIC o identificador de Yahoo.

## Introducción a la función historico_multiples_precios()

Este repositorio está diseñado para compartir algunas funciones que hice para descargar datos de Yahoo Finance. De todas estas funciones, la de mayor interés puede ser historico_multiples_precios() que es la creada para extraccion de 1 o varios RICs o identificadores en una misma tabla y de manera secuencial.

Con esta, se utiliza, como argumentos de entrada, un vector de texto con los ticker de las acciones fondos, futuros o índices que deseas descargar (Te sugiero consultar [Yahoo finance](https://finance.yahoo.com)), así como la fecha inicial, la final y la periodicidad. Esta última puede ser diaria ("D"), semanal ("W") o mensual ("M").

### Sintaxis de la función historico_multiples_precios()

Esta función nos permite extraer una o varias series de tiempo de 1 o varios RIC o identificadores de Yahoo Finance. El objeto tipo lista de salida nos entregará los históricos de interés en lo individual, asi como una tabla de los precios, incrementos $P/L_{i,t}$, y variaciones porcentuales $r_{i,t}$ tanto aritméticas como en tiempo contínuo.

La función historico_multiples_preciosFX tiene los siguientes argumentos:

1. tickers: es un objeto o vector tipo character en donde se especifica el idendificador o identificadores de Yahoo Finance a descargar.
2. de: es un objeto tipo character en donde se especifica la fecha inicial. Ejemplo de uso: "2024-09-11" debe ser la entrada para la fecha del 11 de septiembre de 2024. **NOTA: no se admite otro formato de fecha**.
3. hasta: es un objeto similar al anterior pero para especificar la fecha final de los históricos a consultar **NOTA: hasta>de para que el código funcione**.
4. periodicidad: es un objeto tipo character en donde se especifica la periodicidad de las series de tiempo. Los valores permitidos son (en este formato obligatorio) "D" para diaria (opción por defecto, "W" para semanal, "M" para mensual, "Q" para trimestral y "Y" para anual.
6. fxRate: es la cadena de texto (objeto tipo character) que especifica la paridad cambiaria a extraer de Yahoo Finance. Por ejemplo "USDMXN=X" extrae el tipo de cambio pesos mexicanos por cada dólar de EEUU, "MXNUSD=X" extrae la paridad dólares de EEUU por cada peso mexicano, "EURUSD=X" la paridad dólares de EEUU por cada Euro, "CHFUSD=X" dólares de EEUU por cada franco suizo. **NOTA: es importante agregar =X para especificar que es un tipo de cambio**.
7. whichToFX: es un objeto tipo character que puede tener 3 formas u opciones:
  - un objeto character que diga "none" (opción por defecto) **Nota: debemos respetar la palabra con sus mayúsculas y minúsculas) para indicar que ninguno de los RIC o identificadores en el argumento tickers será convertido a la paridad cambiara en fxRate**.
  - un objeto character que diga "all" para señalar que todos los RIC o identificadores serán convertidos a la moneda especificada con la paridad den fxRate.
  - un vector lógico (TRUE/FALSE) que indique que RIC o identificador se convierte a la divisa deseada (TRUE) y cuál no (FALSE). **Nota: este vector debe tener la misma longitud o número de elementos que los del objeto tickers. De lo contrario la función marcará un error. De manera análoga, el TRUE o FALSE se indica en el orden de los identificadores especificados en tickers**.

La función de interés regresa un objeto tipo lista con los siguientes 9 objetos:

1. Un objeto llamado **tabla.precios** con la tabla con los precios de cierre y fechas homogeneizadas a las del primer ticker (ALFAA.MX). Los precios se expresan en base al tipo de cambio especificado con el identificador de Yahoo Finance ("USDMXN=X" para el tipo de cambio dólar de EEUU-peso mexicano). Esto se hace para los identificadores que se desea convertir, según el orden del objeto convertirFX (tablaPrecios).
2. Una tabla, llamada **tabla.PL**, que es similar a la anterior pero con el histórico de incremento de precios $\Delta P_{t}=P_t- P_{t-1}$ o $P/L_{t}$ (tablaPL).
3. Una tabla similar a la anterior (**tabla.preciosArit**) pero con la variación porcentual aritmética de los precios $r_{i,t}=\left( \frac{P_t}{P_{t-1}} \right)-1$ (tablaRendimientosArit).
4. Una tabla similar a la anterior (**tabla.preciosCont**) pero con la variación porcentual contínua de los precios $r_{i,t}=ln(P_t)-ln(P_{t-1})$ (tablaRendimientosCont).
5. La tabla de los precios extraídos desde Yahoo Finance para cada ticker, en la conversión cambiaria solicitada con el argumento FXrate. El objeto individual hereda el nombre que le corresponde en el argumento de entrada ticker y presenta las columnas de fecha (date), precio de apertura (open), precio máximo (high), precio mínimo (low), precio de cierre (close), precio ajustado a splits (adjusted), volumen de operaciones (volume), incremento de precio (PL), variación porcentual aritmética (rArit), y variación porcentual en tiempo continuo (varCont).
6. La tabla **tabla.precios** en formato de base de datos para su mejor exposición para graficarla con ggplot2 o plotly (tablaPreciosFigura).
7. La tabla **tabla.PL** en formato de base de datos para su mejor exposición para graficarla con ggplot2 o plotly (tablaPLFigura).
8. La tabla **tabla.preciosArit** en formato de base de datos para su mejor exposición para graficarla con ggplot2 o plotly (tablaRendAritFigura).
9. La tabla **tabla.preciosCont** en formato de base de datos para su mejor exposición para graficarla con ggplot2 o plotly (tablaRendContFigura).

**Nota de extracción de datos de Yahoo Finance**: Se puede descargar, con estas funciones, toda la información histórica que pueda proveer Yahoo Finance como son índices, precios de acciones, fondos de inversión, ETFs, FIBRAS (REITs) o paridades cambiarias. La conversión cambiaria con la función historico_multiples_preciosFX se hará multiplicando las unidades de medida por la paridad cambiaria utilizada en el insumo 'FXrate'.

### Ejemplo de la extracción de uno o múltiples RIC o identificadores de Yahoo Finance

En este ejemplo se extrae la información histórica de 2 o más RIC (Refinitiv Identifier Object) o identificador de Yahoo Finance (Refinitiv es de los principales proveedores de información para Yahoo Finance). La diferencia con la función historico_multiples_precios radica en que le proporcionamos el RIC o ticker de Yahoo Finance de la paridad cambiaria a la que deseamos convertir **toda** la tabla de precios y la tabla de rendimientos. Por ejemplo, si deseamos extraer una matriz de precios de acciones de los Estados Unidos para convertirla a pesos mexicanos, deberemos utilizar el RIC o ticker de Yahoo 'USDMNX=X' para descargar el histórico del tipo de cambio. Posteriormente, la función multiplica la paridad cambiaria de cada fecha por el precio descargado para cada RIC o ticker para convertir los valores a pesos mexicanos. Con esos precios expresados en pesos mexicanos se calcula la matriz o tabla de rendimientos del objeto de salida 'Datos'.

**Notas importantes:** Solamente la tabla de precios y rendimientos en el objeto de salida 'Datos' es la que se convertirá a la paridad cambiaria. Si deseamos convertir el precio de acciones mexicanas a dólares de los Estados Unidos o a otra divisa, deberemos utilizar el RIC o identificador inverso o recíproco de la paridad cambiaria. Por ejemplo, 'MXNUSD=X' para convertir los precios de pesos mexicanos a dólares de los Estados Unidos.

```{r}
# Ejemplo para descargar los históricos diarios de grupo Alfa (en moneda local), Microsoft en EEUU (convertido a MXN), Mercado Libre en EEUU (convertido a MXN) y el índice S&P/BMV IPC (en moneda local), desde el 1 de enero de 2023 a la fecha actual:
tickerV=c("ALFAA.MX","MSFT","MELI","^MXX")
deD="2023-01-01"
hastaD=Sys.Date()
per="D"
paridadFX="USDMXN=X"
convertirFX=c(FALSE,TRUE,TRUE,FALSE)

Datos=historico_multiples_precios(tickers=tickerV,de=deD,hasta=hastaD,periodicidad=per,fxRate=paridadFX,whichToFX=convertirFX)
```


# Control de versiones

- V 1.0. 29-feb-2024: Funciones historico_multiples_precios y historico_precio_mkts con readme en GitHub.
- V 2.0 03-may-2024: Se agrega función historico_multiples_preciosFX para convertir a la divisa deseada en Yahoo.
- V 3.0 11-sept-2024: Se corrigió cambio de URL en Yahoo Finance y se utilizó en su lugar tidyquant. Se simplificó la extracción de series de tiempo de precios y variaciones porcentuales en una misma función: historico_multiples_preciosFX().
- V 3.1 21-oct-2024: Se corrige un error para el "=" en los futuros de Yahoo Finance para que el nombre no incluya tal caracter y genere errores al exportar los datos.
