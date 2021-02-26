
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Estadísticas del Instituto de Seguridad Social de Nicaragua

Este repositorio contiene datos extraídos de los reportes de los
anuarios estadísticos del Instituto de Seguridad Social de Nicaragua.
Los datos se encuentran en la subcarpeta `data` en formato `csv` y
`rds`.

Las variables en esta base son:

-   `year`: año
-   `gender`: género
-   `edad`: grupo de edad
-   `mes`: mes
-   `asegurados`: cantidad de asegurados activos

``` r
inss
#> # A tibble: 3,744 x 5
#>     year gender  edad  mes   asegurados
#>    <dbl> <chr>   <chr> <chr>      <dbl>
#>  1  2018 Hombres 0-14  ene           72
#>  2  2018 Hombres 0-14  feb           82
#>  3  2018 Hombres 0-14  mar           60
#>  4  2018 Hombres 0-14  abr           51
#>  5  2018 Hombres 0-14  may           42
#>  6  2018 Hombres 0-14  jun           39
#>  7  2018 Hombres 0-14  jul           33
#>  8  2018 Hombres 0-14  ago            5
#>  9  2018 Hombres 0-14  sep            3
#> 10  2018 Hombres 0-14  oct            4
#> # ... with 3,734 more rows
```

## Caveats

Actualmente este repositorio no contiene información de los anuarios del
año 2013 y 2007.

## Comentarios y sugerencias

Para realizar comentarios o sugerencias sobre la base de datos puedes
abrir un issue en este repositorio:
<https://github.com/RRMaximiliano/inss_nicaragua/issues>
