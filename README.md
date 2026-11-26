
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Estadísticas del Instituto de Seguridad Social de Nicaragua

Este repositorio contiene datos extraídos de los reportes de los
anuarios estadísticos del Instituto de Seguridad Social de Nicaragua.
Los datos se encuentran en la subcarpeta `data` en formato `csv` y
`rds`.

| Base | Contenido | Frecuencia | Periodo |
|----|----|----|----|
| `inss_gender` | Asegurados activos por sexo y grupo de edad | mensual | 2006-2024 |
| `inss_regimen` | Asegurados activos por régimen | mensual | 2006-2024 |
| `inss_regimen_diciembre` | Asegurados activos por régimen, a diciembre | anual | 1994-2024 |
| `inss_salarios` | Salarios devengados y salario promedio por régimen | mensual | 2006-2024, sin 2012 |
| `inss_empleadores` | Empleadores activos del Régimen Obligatorio | mensual | 2006-2024, sin 2012 |
| `inss_departamento` | Asegurados activos por departamento y sexo, a diciembre | anual | 2006-2024, sin 2012 |

## Por género

Las variables en esta base son:

- `year`: año
- `gender`: género
- `edad`: grupo de edad
- `mes`: mes
- `asegurados`: cantidad de asegurados activos

``` r
inss
#> # A tibble: 5,472 × 5
#>     year gender  edad  mes   asegurados
#>    <dbl> <chr>   <chr> <chr>      <dbl>
#>  1  2006 Hombres 0-14  ene           18
#>  2  2006 Hombres 0-14  feb           23
#>  3  2006 Hombres 0-14  mar           29
#>  4  2006 Hombres 0-14  abr           20
#>  5  2006 Hombres 0-14  may           22
#>  6  2006 Hombres 0-14  jun           21
#>  7  2006 Hombres 0-14  jul           27
#>  8  2006 Hombres 0-14  ago           29
#>  9  2006 Hombres 0-14  sep           31
#> 10  2006 Hombres 0-14  oct           41
#> # ℹ 5,462 more rows
```

<img src="figs/asegurados.png" alt="Total mensual de hombres y mujeres asegurados en Nicaragua, 2006-2024" width="100%" />

## Por régimen

Las variables en esta base son:

- `year`: año
- `month`: mes
- `regimen`: tipo de régimen (i.e., facultativo y obligatorio)
- `asegurados`: cantidad de asegurados activos

``` r
inss_reg
#> # A tibble: 912 × 4
#>     year month   regimen              asegurados
#>    <dbl> <chr>   <chr>                     <dbl>
#>  1  2006 Enero   Obligatorio Integral     340891
#>  2  2006 Enero   Obligatorio IVM           56440
#>  3  2006 Enero   Facultativo Integral       1678
#>  4  2006 Enero   Facultativo IVM            1400
#>  5  2006 Febrero Obligatorio Integral     344008
#>  6  2006 Febrero Obligatorio IVM           56327
#>  7  2006 Febrero Facultativo Integral       1694
#>  8  2006 Febrero Facultativo IVM            1436
#>  9  2006 Marzo   Obligatorio Integral     351033
#> 10  2006 Marzo   Obligatorio IVM           53626
#> # ℹ 902 more rows
```

<img src="figs/asegurados_regimen.png" alt="Asegurados mensuales por régimen facultativo y obligatorio, 2006-2024" width="100%" />

## Por régimen, a diciembre (1994-2024)

Las variables en esta base son:

- `year`: año
- `regimen`: tipo de régimen
- `asegurados`: cantidad de asegurados activos en diciembre

Los años 1994-2005 provienen del cuadro histórico “Asegurados activos
por régimen de afiliación, Diciembre 1994 - 20XX”, que aparece en los
anuarios de 2006 a 2013 con las mismas cifras en todas las ediciones.
Los años 2006-2024 son el mes de diciembre de `inss_regimen`.

``` r
inss_reg_dic
#> # A tibble: 124 × 3
#>     year regimen              asegurados
#>    <dbl> <chr>                     <dbl>
#>  1  1994 Obligatorio Integral     134319
#>  2  1994 Obligatorio IVM           70014
#>  3  1994 Facultativo Integral        116
#>  4  1994 Facultativo IVM              60
#>  5  1995 Obligatorio Integral     141665
#>  6  1995 Obligatorio IVM           68701
#>  7  1995 Facultativo Integral        185
#>  8  1995 Facultativo IVM              59
#>  9  1996 Obligatorio Integral     154612
#> 10  1996 Obligatorio IVM           72077
#> # ℹ 114 more rows
```

<img src="figs/asegurados_diciembre.png" alt="Total de asegurados en diciembre de cada año, 1994-2024" width="100%" />

## Salarios

Las variables en esta base son:

- `year`: año
- `month`: mes
- `regimen`: tipo de régimen
- `salarios`: salarios devengados en el mes, en córdobas corrientes
- `salario_promedio`: salario promedio devengado publicado por el INSS,
  en córdobas corrientes

El salario promedio publicado es igual a `salarios` entre los asegurados
del mismo régimen y mes en `inss_regimen`, con diferencias de redondeo
menores a 0.06 córdobas. El anuario de 2014 publica los salarios en
miles de córdobas; aquí están convertidos a córdobas.

``` r
inss_salarios
#> # A tibble: 864 × 5
#>     year month   regimen                 salarios salario_promedio
#>    <dbl> <chr>   <chr>                      <dbl>            <dbl>
#>  1  2006 Enero   Obligatorio Integral 1471723898.            4317.
#>  2  2006 Enero   Obligatorio IVM       160765249.            2848.
#>  3  2006 Enero   Facultativo Integral    4189253.            2497.
#>  4  2006 Enero   Facultativo IVM         6201984.            4430.
#>  5  2006 Febrero Obligatorio Integral 1463047706.            4253.
#>  6  2006 Febrero Obligatorio IVM       161099114.            2860.
#>  7  2006 Febrero Facultativo Integral    4256125.            2512.
#>  8  2006 Febrero Facultativo IVM         6416162.            4468.
#>  9  2006 Marzo   Obligatorio Integral 1526965818.            4350.
#> 10  2006 Marzo   Obligatorio IVM       154678633.            2884.
#> # ℹ 854 more rows
```

<img src="figs/salario_promedio.png" alt="Salario promedio mensual por régimen en córdobas corrientes, 2006-2024 sin 2012" width="100%" />

## Empleadores

Las variables en esta base son:

- `year`: año
- `month`: mes
- `regimen`: Obligatorio Integral u Obligatorio IVM (el Seguro
  Facultativo no tiene empleadores)
- `empleadores`: cantidad de empleadores activos

``` r
inss_empleadores
#> # A tibble: 432 × 4
#>     year month   regimen              empleadores
#>    <dbl> <chr>   <chr>                      <dbl>
#>  1  2006 Enero   Obligatorio Integral       11663
#>  2  2006 Enero   Obligatorio IVM             2380
#>  3  2006 Febrero Obligatorio Integral       11784
#>  4  2006 Febrero Obligatorio IVM             2406
#>  5  2006 Marzo   Obligatorio Integral       12105
#>  6  2006 Marzo   Obligatorio IVM             2298
#>  7  2006 Abril   Obligatorio Integral       12108
#>  8  2006 Abril   Obligatorio IVM             2237
#>  9  2006 Mayo    Obligatorio Integral       12369
#> 10  2006 Mayo    Obligatorio IVM             2280
#> # ℹ 422 more rows
```

<img src="figs/empleadores.png" alt="Empleadores activos mensuales del régimen obligatorio, 2006-2024 sin 2012" width="100%" />

## Por departamento

Las variables en esta base son:

- `year`: año
- `departamento`: departamento, con nombres armonizados (RAAN y RAAS
  aparecen como RACCN y RACCS)
- `departamento_anuario`: nombre como aparece en el anuario. En 2006 y
  2007 Managua aparece dividida en sucursales del INSS; `departamento`
  las agrupa como Managua
- `gender`: género
- `asegurados`: cantidad de asegurados activos en diciembre

``` r
inss_departamento
#> # A tibble: 624 × 5
#>     year departamento departamento_anuario gender  asegurados
#>    <dbl> <chr>        <chr>                <chr>        <dbl>
#>  1  2006 Boaco        Boaco                Hombres       2184
#>  2  2006 Boaco        Boaco                Mujeres       1610
#>  3  2006 Carazo       Carazo               Hombres       5946
#>  4  2006 Carazo       Carazo               Mujeres       6136
#>  5  2006 Chinandega   Chinandega           Hombres      20805
#>  6  2006 Chinandega   Chinandega           Mujeres      11758
#>  7  2006 Chontales    Chontales            Hombres       3857
#>  8  2006 Chontales    Chontales            Mujeres       4195
#>  9  2006 Estelí       Estelí               Hombres       6946
#> 10  2006 Estelí       Estelí               Mujeres       8463
#> # ℹ 614 more rows
```

<img src="figs/asegurados_departamento.png" alt="Hombres y mujeres asegurados por departamento en diciembre de 2024" width="100%" />

## Fuentes y replicación

Las bases por género y por régimen cubren 2006-2024. Los datos de 2006 y
2008-2018 se digitaron a mano en `data/raw/*.xlsx`. Los de 2007 y
2019-2024 se extraen de los anuarios en PDF con `script/00_extract.R`,
que descarga cada anuario de las copias del Wayback Machine (el sitio
del INSS bloquea descargas automáticas) y lee los cuadros “Asegurados
activos por mes, según sexo y grupo de edad” y “Asegurados activos del
Régimen Obligatorio y Seguro Facultativo, por mes”. Para los años en que
ambas fuentes existen, la extracción coincide con los datos digitados en
todas las celdas. El anuario de 2012 archivado está incompleto, así que
ese año proviene solo de los datos digitados, y falta en las bases de
salarios, empleadores y departamentos, que no tienen datos digitados.

Las demás bases se extraen solo de los anuarios. En el anuario de 2016,
los cuadros de salarios por mes y de asegurados por departamento son
imágenes, así que se leen con OCR (tesseract). `script/00_extract.R`
verifica cada cuadro contra sus propios totales y contra los otros
cuadros que reportan la misma cifra, e imprime las filas que no cuadran.
Las únicas diferencias que quedan son errores en los anuarios, y las
cifras se dejan como se publicaron:

- Empleadores, marzo de 2008: 15,222 + 2,458 suman 17,680, pero el
  anuario publica un total de 17,580.
- Departamentos, 2008: los totales de hombres (218,294) y mujeres
  (277,291) están invertidos respecto al cuadro de asegurados por sexo y
  edad (277,291 hombres y 218,294 mujeres en diciembre).
- Departamentos, 2006: los totales por sexo (216,598 hombres y 222,404
  mujeres) no coinciden con el cuadro por sexo y edad (240,241 y
  198,761). El total general, 439,002, sí coincide.

Para reproducir: `script/00_extract.R` (requiere `pdftotext` y
`pdftoppm` de poppler, `tesseract` y el paquete `png` de R), luego
`script/01_cleaning.R` y `script/02_plot.R`.

## Comentarios y sugerencias

Para realizar comentarios o sugerencias sobre la base de datos puedes
abrir un issue en este repositorio:
<https://github.com/RRMaximiliano/inss_nicaragua/issues>
