
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

# Gender ------------------------------------------------------------------

inss %>% 
  mutate(
    month = rep(1:12, times = 312, each = 1)
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
    subtitle = "2006-2018",
    caption = "Datos: INSS | Plot: @rrmaximiliano\nNota: No se encuentran datos para el ano 2007"
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
  arrange(year, regimen) %>% 
  mutate(
    month_num = rep(1:12, times = 52, each = 1) 
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
    subtitle = "Periodo: 2006-2018",
    caption = "Datos: INSS | Plot: @rrmaximiliano\nNota: No se encuentran datos para el ano 2007"
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

