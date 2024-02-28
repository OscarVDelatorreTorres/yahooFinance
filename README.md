# Funciones para extraer datos de Yahoo Finance

Este repositorio está diseñado para compartir algunas funciones que hice para descargar datos de Yahoo Finance. De todas estas funciones, la de mayor interés puede ser historico_multiples_precios()

Con esta, se utiliza, como argumentos de entrada, un vector de texto con los ticker de las acciones fondos, futuros o índices que deseas descargar (Te sugiero consultar [Yahoo financer](https://finance.yahoo.com)), así como la fecha inicial, la final y la periodicidad. Esta última puede ser diaria ("D"), semanal ("W") o mensual ("M").

Para cargar en R esta función debes correr el siguiente comando
```{r}
source("")
```

historico_multiples_precios=function(tickers,de,hasta,periodicidad="D")
