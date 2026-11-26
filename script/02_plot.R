
# packages ----------------------------------------------------------------
Sys.setlocale("LC_TIME", "Spanish_Spain.1252")

library(lubridate)
library(zoo)
library(hrbrthemes)
library(scales)
library(ggtext)

# Read data ---------------------------------------------------------------

inss     <- read_rds(file.path(data, "inss_gender.rds"))
inss_reg <- read_rds(file.path(data, "inss_regimen.rds"))
inss_reg_dic      <- read_rds(file.path(data, "inss_regimen_diciembre.rds"))
inss_salarios     <- read_rds(file.path(data, "inss_salarios.rds"))
inss_empleadores  <- read_rds(file.path(data, "inss_empleadores.rds"))
inss_departamento <- read_rds(file.path(data, "inss_departamento.rds"))

meses <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio",
           "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")

monthly_dates <- function(df) {
  df %>%
    complete(year = full_seq(year, 1), month = meses, regimen) %>%
    mutate(date = make_date(year, match(month, meses)))
}

nota_2012 <- "Datos: INSS | Plot: @rrmaximiliano\nNota: El anuario de 2012 no está disponible"

periodo  <- paste(min(inss$year), max(inss$year), sep = "-")

# Gender ------------------------------------------------------------------

inss %>% 
  mutate(
    month = match(mes, c("ene", "feb", "mar", "abr", "may", "jun",
                         "jul", "ago", "sep", "oct", "nov", "dic"))
  ) %>% 
  group_by(year, month, gender) %>% 
  summarise(sum = sum(asegurados)) %>%
  ungroup() %>%
  mutate(
    year_month = paste(year, month, sep = "-"),
    date = ym(year_month)
  ) %>%
  select(date, gender, sum) %>% 
  ggplot(aes(x = date, y = sum, color = gender, group = gender)) +
  geom_line(size = 1.2) +
  scale_x_date(breaks = date_breaks("2 year"), labels = date_format("%Y")) + 
  scale_y_continuous(label = comma) +
  scale_color_manual(values = c("#0072B2", "#D55E00")) + 
  labs(
    x = "Fecha",
    y = "Total de asegurados",
    title = "Total de <span style = 'color:#0072B2;'>hombres</span>
y <span style = 'color:#D55E00;'>mujeres</span> aseguradas en Nicaragua",
    subtitle = periodo,
    caption = "Datos: INSS | Plot: @rrmaximiliano"
  ) +
  theme_ipsum_rc() +
  theme(
    legend.position = "none",
    plot.title.position = "plot",
    plot.title = element_markdown()
  )

ggsave(file.path(figs, "asegurados.png"),
       dpi = 320, height = 8, width = 12, scale = 0.8)
  
# Regimen -----------------------------------------------------------------
inss_reg %>% 
  mutate(
    month_num = match(month, meses)
  ) %>%
  mutate(
    year_month = paste(year, month_num, sep = "-"),
    date = ym(year_month)
  ) %>% 
  select(date, regimen, asegurados) %>% 
  ggplot(aes(x = date, y = asegurados, group = regimen, color = regimen)) +
  geom_line(size = 1.2) + 
  facet_wrap(~regimen, scales = "free_y") + 
  scale_x_date(breaks = date_breaks("2 year"), labels = date_format("%Y")) + 
  scale_y_continuous(label = comma) +
  scale_color_manual(values = c("#0072B2", "#0072B2", "#D55E00", "#D55E00")) +
  labs(
    x = "Fecha",
    y = "Total de asegurados",
    title = "Total de personas aseguradas por regimen <span style = 'color:#0072B2;'>facultativo</span>
y <span style = 'color:#D55E00;'>obligatorio</span> en Nicaragua",
    subtitle = paste("Periodo:", periodo),
    caption = "Datos: INSS | Plot: @rrmaximiliano"
  ) +
  theme_ipsum_rc() +
  theme(
    legend.position = "none",
    panel.background = element_rect(color = "grey70", fill = "white"),
    plot.title.position = "plot",
    plot.title = element_markdown()
  )

ggsave(file.path(figs, "asegurados_regimen.png"),
       dpi = 320, height = 8, width = 12, scale = 0.8)

# December series ---------------------------------------------------------

inss_reg_dic %>% 
  group_by(year) %>% 
  summarise(asegurados = sum(asegurados)) %>% 
  ggplot(aes(x = year, y = asegurados)) +
  geom_line(color = "#0072B2", linewidth = 1.2) +
  geom_point(color = "#0072B2", size = 2.5) +
  scale_x_continuous(breaks = seq(1994, 2024, 3)) +
  scale_y_continuous(label = comma, limits = c(0, NA)) +
  labs(
    x = "Año",
    y = "Total de asegurados",
    title = "Total de personas aseguradas en Nicaragua, a diciembre",
    subtitle = paste("Periodo:", paste(range(inss_reg_dic$year), collapse = "-")),
    caption = "Datos: INSS | Plot: @rrmaximiliano"
  ) +
  theme_ipsum_rc() +
  theme(plot.title.position = "plot")

ggsave(file.path(figs, "asegurados_diciembre.png"),
       dpi = 320, height = 8, width = 12, scale = 0.8)

# Average wage ------------------------------------------------------------

inss_salarios %>% 
  monthly_dates() %>% 
  ggplot(aes(x = date, y = salario_promedio, color = regimen)) +
  geom_line(linewidth = 1.2) + 
  facet_wrap(~regimen) + 
  scale_x_date(breaks = date_breaks("3 year"), labels = date_format("%Y")) + 
  scale_y_continuous(label = comma) +
  scale_color_manual(values = c("#0072B2", "#0072B2", "#D55E00", "#D55E00")) +
  labs(
    x = "Fecha",
    y = "Córdobas corrientes",
    title = "Salario promedio mensual por regimen <span style = 'color:#0072B2;'>facultativo</span>
y <span style = 'color:#D55E00;'>obligatorio</span> en Nicaragua",
    subtitle = paste("Periodo:", periodo, "| Córdobas corrientes, sin ajustar por inflación"),
    caption = nota_2012
  ) +
  theme_ipsum_rc() +
  theme(
    legend.position = "none",
    panel.background = element_rect(color = "grey70", fill = "white"),
    plot.title.position = "plot",
    plot.title = element_markdown()
  )

ggsave(file.path(figs, "salario_promedio.png"),
       dpi = 320, height = 8, width = 12, scale = 0.8)

# Employers ---------------------------------------------------------------

inss_empleadores %>% 
  monthly_dates() %>% 
  ggplot(aes(x = date, y = empleadores)) +
  geom_line(color = "#D55E00", linewidth = 1.2) + 
  facet_wrap(~regimen, scales = "free_y") + 
  scale_x_date(breaks = date_breaks("3 year"), labels = date_format("%Y")) + 
  scale_y_continuous(label = comma) +
  labs(
    x = "Fecha",
    y = "Total de empleadores",
    title = "Total de empleadores activos del régimen obligatorio en Nicaragua",
    subtitle = paste("Periodo:", periodo, "| Cada panel tiene su propia escala"),
    caption = nota_2012
  ) +
  theme_ipsum_rc() +
  theme(
    panel.background = element_rect(color = "grey70", fill = "white"),
    plot.title.position = "plot"
  )

ggsave(file.path(figs, "empleadores.png"),
       dpi = 320, height = 6, width = 12, scale = 0.8)

# Department --------------------------------------------------------------

ultimo <- max(inss_departamento$year)

inss_departamento %>% 
  filter(year == ultimo) %>% 
  mutate(departamento = fct_reorder(departamento, asegurados, sum)) %>% 
  ggplot(aes(x = asegurados, y = departamento, fill = gender)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_x_continuous(label = comma, expand = expansion(mult = c(0, 0.05))) +
  scale_fill_manual(values = c("#0072B2", "#D55E00")) + 
  labs(
    x = "Total de asegurados",
    y = NULL,
    title = sprintf("<span style = 'color:#0072B2;'>Hombres</span> y <span style = 'color:#D55E00;'>mujeres</span> asegurados por departamento, diciembre %d", ultimo),
    caption = "Datos: INSS | Plot: @rrmaximiliano"
  ) +
  theme_ipsum_rc() +
  theme(
    legend.position = "none",
    panel.grid.major.y = element_blank(),
    plot.title.position = "plot",
    plot.title = element_markdown()
  )

ggsave(file.path(figs, "asegurados_departamento.png"),
       dpi = 320, height = 8, width = 12, scale = 0.8)
