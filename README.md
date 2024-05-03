# Funciones para extraer datos de Yahoo Finance

Este repositorio está diseñado para compartir algunas funciones que hice para descargar datos de Yahoo Finance. De todas estas funciones, la de mayor interés puede ser historico_multiples_precios()

Con esta, se utiliza, como argumentos de entrada, un vector de texto con los ticker de las acciones fondos, futuros o índices que deseas descargar (Te sugiero consultar [Yahoo financer](https://finance.yahoo.com)), así como la fecha inicial, la final y la periodicidad. Esta última puede ser diaria ("D"), semanal ("W") o mensual ("M").

Para cargar en R esta función debes correr el siguiente comando en tu chunk de R en Rstudio o en la consola:

```{r}
source("https://raw.githubusercontent.com/OscarVDelatorreTorres/yahooFinance/main/datosMultiplesYahooFinance.R")
```
Con esto, cargarás la función en tu ambiente de trabajo, junto con las funcones de apoyo para manipulación de fechas, así como la extracción individual de un solo RIC o identificador de Yahoo.

# Ejemplos

Para ver como funciona, puedes corres estos ejemplos:

## Extracción de múltiples RIC o identificadores de Yahoo Finance

En este ejemplo se extrae la información histórica de 2 o más RIC (Refinitiv Identifier Object) o identificador de Yahoo Finance (Refinitiv es de los principales proveedores de informaci{on para Yahoo Finance).

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

# Extracción de un RIC o identificador individual

En este ejemplo se extrae la información histórica de 2 o más RIC (Refinitiv Identifier Object) o identificador de Yahoo Finance (Refinitiv es de los principales proveedores de informaci{on para Yahoo Finance).

```{r}
# Ejemplo para descargar los históricos diarios de grupo Alfa, Microsoft en EEUU, Micrososft en México y el índice S&P/BMV IPC, desde el 1 de enrdo de 2023 a la fecha actual:
tickerV="ALFAA.MX"
deD="2023-01-01"
hastaD=Sys.Date()
per="D"

Datos=historico_precio_mkts(tickers=tickerV,de=deD,hasta=hastaD,periodicidad2=per)
```
En este ejemplo, el objeto Datos es un objeto tipo lista con una tabla con los precios de cierre del ticker ALFAA.MX en Yahoo Finance.

## Extracción de múltiples RIC o identificadores de Yahoo Finance convirtiendo la tabla o matriz de precios y la de rendimientos a la divisa o paridad cambiaria de preferencia (V 2.0 3-may-2024)

En este ejemplo se extrae la información histórica de 2 o más RIC (Refinitiv Identifier Object) o identificador de Yahoo Finance (Refinitiv es de los principales proveedores de informaci{on para Yahoo Finance). La diferencia con la función historico_multiples_precios radica en que le proporcionamos el RIC o ticker de Yahoo Finance de la paridad cambiaria a la que deseamos convertir **toda** la tabla de precios y la tabla de rendimientos. Por ejemplo, si deseamos extraer una matriz de precios de acciones de los Estados Unidos para convertirla a pesos mexicanos, deberemos utilizar el RIC o ticker de Yahoo 'USDMNX=X' para descargar el histórico del tipo de cambio. Posteriormente, la función multiplica la paridad cambiaria de cada fecha por el precio descargado para cada RIC o ticker para convertir los valores a pesos mexicanos. Con esos precios expresados en pesos mexicanos se calcula la matriz o tabla de rendimientos del objeto de salida 'Datos'.

**Notas importantes:** Solamente la tabla de precios y rendimientos en el objeto de salida 'Datos' es la que se convertirá a la paridad cambiaria. Si deseamos convertir el precio de acciones mexicanas a dólares de los Estados Unidos o a otra divisa, deberemos utilizar el RIC o identificador inverso o recíproco de la paridad cambiaroa. Por ejemplo, 'MXNUSD=X' para convertir los precios de pesos mexicanos a dólares de los Estados Unidos.

```{r}
# Ejemplo para descargar los históricos diarios de grupo Alfa, Microsoft en EEUU, Micrososft en México y el índice S&P/BMV IPC, desde el 1 de enrdo de 2023 a la fecha actual:
tickerV=c("ALFAA.MX","MSFT","MSFT.MX","^MXX")
deD="2023-01-01"
hastaD=Sys.Date()
per="D"

Datos=historico_multiples_preciosFX(tickers=tickerV,FXrate="USDMXN=X",de=deD,hasta=hastaD,periodicidad=per)
```
En este ejemplo, el objeto Datos es un objeto tipo lista con 5 de estos:

1. Una tabla con los precios de cierre y fechas homogeneizadas a las del primer ticker (ALFAA.MX).
2. Una tabla similar pero cn las variaciones porcentuales en tiempo contínuo.
3. Los objetos de los precios extraidos desde Yahoo Finance para cada ticker.
4. La tabla histórica de los tipos de cambio extraída, en forma "cruda" de Yahoo Finance.
5. La tabla de tipos de cambio anterior pero con las fechas homogeneizadas a la tabla de precios y rendimeintos de los RIC o identificadores de interés.

**Nota de extracci{on de datos de Yahoo Finance**: Se puede descargar, con estas funciones, toda la información histórica que pueda proveer Yahoo Finance como son índices, precios de acciones, fondos de inversión, ETFs, FIBRAS (REITs) o paridades cambiarias. La conversión cambiaria con la función historico_multiples_preciosFX se hará multiplicando las unidades de medida por la paridad cambiaria utilizada en el insumo 'FXrate'.

# Control de versiones

- V 1.0. 29-feb-2024: Funciones historico_multiples_precios y historico_precio_mkts con readme en GitHub.
- V 2.0 03-may-2024: Se agrega función historico_multiples_preciosFX para convertir a la divisa deseada en Yahoo.

