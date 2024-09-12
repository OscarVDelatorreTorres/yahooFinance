# Funciones para extraer datos de Yahoo Finance

Este repositorio está diseñado para compartir algunas funciones que hice para descargar datos de Yahoo Finance. De todas estas funciones, la de mayor interés puede ser historico_multiples_precios() que es la creada para extraccion de 1 o varios RICs o identificadores en una misma tabla y de manera secuencial.

Con esta, se utiliza, como argumentos de entrada, un vector de texto con los ticker de las acciones fondos, futuros o índices que deseas descargar (Te sugiero consultar [Yahoo financer](https://finance.yahoo.com)), así como la fecha inicial, la final y la periodicidad. Esta última puede ser diaria ("D"), semanal ("W") o mensual ("M").

Para cargar en R esta función en R debes correr el siguiente comando en tu chunk de R en Rstudio o en la consola, tu archivo de quarto o Rscript:

```{r}
source("https://raw.githubusercontent.com/OscarVDelatorreTorres/yahooFinance/main/datosMultiplesYahooFinance.R")
```
Con esto, cargarás la función en tu ambiente de trabajo, junto con las funciones de apoyo para manipulación de fechas, así como la extracción individual de un solo RIC o identificador de Yahoo.

# Sintaxis de la función historico_multiples_preciosFX()

Esta función nos permite extraer una o varias series de tiempo de 1 o varios RIC o identificadores de Yahoo Finance. El objeto tipo lista de salida nos entregará los históricos de interés en lo individual, asi como una tabla de los precios, incrementos $P/L_{i,t}$, y variaciones porcentuales $r_{i,t}$ tanto aritméticas como en tiempo contínuo.

La función historico_multiples_preciosFX tiene los siguientes argumentos:

1. tickers: es un objeto o vector tipo character en donde se especifica el idendificador o identificadores de Yahoo Finance a descargar.
2. de: es un objeto tipo character en donde se especifica la fecha inicial. Ejemplo de uso: "2024-09-11" debe ser la entrada para la fecha del 11 de septiembre de 2024. **NOTA: no se admite otro formato de fecha**.
3. hasta: es un objeto similar al anterior pero para especificar la fecha final de los históricos a consultar **NOTA: hasta>de para que el código funcione**.
4. periodicidad: es un objeto tipo character en donde se especifica la periodicidad de las series de tiempo. Los valores permitidos son (en este formato obligatorio) "D" para diaria (opción por defecto, "W" para semanal, "M" para mensual, "Q" para trimestral y "Y" para anual.
6. fxRate: es la cadena de texto (objeto tipo character) que especifica la paridad cambiaria a extraer de Yahoo Finance. Por ejemplo "USDMXN=X" extrae el tipo de cambio pesos mexicanos por cada dólar de EEUU, "MXNUSD=X" extrae la paridad dólares de EEUU por cada peso mexicano, "EURUSD=X" la paridad dólares de EEUU por cada Euro, "CHFUSD=X" dólares de EEUU por cada franco suizo. **NOTA: es importante agregar =X para especificar que es un tipo de cambio**.
7. whichToFX: es un objeto tipo character que puede tener 3 formas u opciones:
  - un objeto character que diga "none" (opción por defecto) **Nota: debemos respetar la palabra con sus mayúsculas y minúsculas) para indicar que ninguno de los RIC o identificadores en el argumento tickers será convertido a la paridad cambiara en fxRate**.
  - un objeto character que disa "all" para señalar que todos los RIC o identificadores serán convertidos a la moneda especificada con la paridad den fxRate.
  - un vector lógico (TRUE/FALSE) que indique que RIC o identificador se convierte a la divisa deseade (TRUE) y cuál no (FALSE). **Nota: este vector debe tener la misma longitud o número de elementos que los del objeto tickers. De lo contrario la función maracará un error. De manera análoga, el TRUE o FALSE se indica en el orden de los identificadores especificados en tickers**.

# Ejemplo

Para ver como funciona, puedes correr este ejemplos:

## Extracción de uno o múltiples RIC o identificadores de Yahoo Finance convirtiendo la tabla o matriz de precios y la de rendimientos a la divisa o paridad cambiaria de preferencia

En este ejemplo se extrae la información histórica de 2 o más RIC (Refinitiv Identifier Object) o identificador de Yahoo Finance (Refinitiv es de los principales proveedores de informaci{on para Yahoo Finance). La diferencia con la función historico_multiples_precios radica en que le proporcionamos el RIC o ticker de Yahoo Finance de la paridad cambiaria a la que deseamos convertir **toda** la tabla de precios y la tabla de rendimientos. Por ejemplo, si deseamos extraer una matriz de precios de acciones de los Estados Unidos para convertirla a pesos mexicanos, deberemos utilizar el RIC o ticker de Yahoo 'USDMNX=X' para descargar el histórico del tipo de cambio. Posteriormente, la función multiplica la paridad cambiaria de cada fecha por el precio descargado para cada RIC o ticker para convertir los valores a pesos mexicanos. Con esos precios expresados en pesos mexicanos se calcula la matriz o tabla de rendimientos del objeto de salida 'Datos'.

**Notas importantes:** Solamente la tabla de precios y rendimientos en el objeto de salida 'Datos' es la que se convertirá a la paridad cambiaria. Si deseamos convertir el precio de acciones mexicanas a dólares de los Estados Unidos o a otra divisa, deberemos utilizar el RIC o identificador inverso o recíproco de la paridad cambiaroa. Por ejemplo, 'MXNUSD=X' para convertir los precios de pesos mexicanos a dólares de los Estados Unidos.

```{r}
# Ejemplo para descargar los históricos diarios de grupo Alfa, Microsoft en EEUU, Micrososft en México y el índice S&P/BMV IPC, desde el 1 de enrdo de 2023 a la fecha actual:
tickerV=c("ALFAA.MX","MSFT","MSFT.MX","^MXX")
deD="2023-01-01"
hastaD=Sys.Date()
per="D"
fxRateD="USDMXN=X"
convertirFX=c(FALSE,TRUE,TRUE,FALSE)

Datos=historico_multiples_preciosFX(tickers=tickerV,FXrate="USDMXN=X",de=deD,hasta=hastaD,periodicidad=per,fxRate=fxRateD,whichToFX=convertirFX)
```
En este ejemplo, el objeto Datos de salida es un objeto tipo lista con 5 de estos:

1. Una tabla con los precios de cierre y fechas homogeneizadas a las del primer ticker (ALFAA.MX). Los precios se expresan en base al tipo de cambio especificado con el identificador de Yahoo Finance ("USDMXN=X" para el tipo de cambio dólar de EEUU-peso mexicano). Esto se hace para los identificadores que se desea convertir, según el orden del objeto convertirFX. (tabla.precios)
2. Una tabla similar a la anterior pero con el histórico de incremento de precios $\Delta P_{t}=P_t- P_{t-1}$ o $P/L_{t}$ (tabla.PL)
3. Una tabla similar a la anterior pero con la variación porcentual aritmética de los precios $r_{i,t}=\left( \frac{P_t}{P_{t-1}} \right)-1$ (tabla.preciosArit)
4. Una tabla similar a la anterior pero con la variación porcentual contínua de los precios $r_{i,t}=ln(P_t)-ln(P_{t-1})$ (tabla.preciosCont)
5. Los objetos de los precios extraidos desde Yahoo Finance para cada ticker, en la conversión cambiaria solicitada con el argumento FXrate.
6. La tabla histórica de los tipos de cambio extraída, en forma "cruda" de Yahoo Finance.

**Nota de extracción de datos de Yahoo Finance**: Se puede descargar, con estas funciones, toda la información histórica que pueda proveer Yahoo Finance como son índices, precios de acciones, fondos de inversión, ETFs, FIBRAS (REITs) o paridades cambiarias. La conversión cambiaria con la función historico_multiples_preciosFX se hará multiplicando las unidades de medida por la paridad cambiaria utilizada en el insumo 'FXrate'.

# Control de versiones

- V 1.0. 29-feb-2024: Funciones historico_multiples_precios y historico_precio_mkts con readme en GitHub.
- V 2.0 03-may-2024: Se agrega función historico_multiples_preciosFX para convertir a la divisa deseada en Yahoo.
- V 3.0 11-sept-2024: Se corrigió cambio de URL en Yahoo Finance y se utilizó en su lugar tidyquant. Se simplificó la extracción de series de tiempo de precios y variaciones porcentuales en una misma función: historico_multiples_preciosFX().
