
# Load packages -----------------------------------------------------------

library(tidyverse)
library(readxl)

# Read data ---------------------------------------------------------------
project <- "."
data    <- file.path(project, "data")
figs    <- file.path(project, "figs")

inss_raw <- read_excel(file.path(data, "raw", "raw_inss.xlsx")) %>% 
  janitor::clean_names()

inss <- inss_raw %>% 
  pivot_longer(
    4:15, 
    names_to = "mes",
    values_to = "asegurados"
  ) %>% 
  filter(!is.na(asegurados))

anuarios_gender <- read_csv(file.path(data, "raw", "anuarios_gender.csv"))

inss <- inss %>% 
  bind_rows(anti_join(anuarios_gender, inss, by = c("year", "gender", "edad", "mes"))) %>% 
  arrange(year, gender, edad, match(mes, unique(inss$mes)))
  
inss_reg_raw <- read_excel(file.path(data, "raw", "raw_inss_regimen.xlsx")) %>% 
  janitor::clean_names()

inss_reg <- inss_reg_raw %>% 
  pivot_longer(
    3:6,
    names_to = "regimen",
    values_to = "asegurados"
  ) %>% 
  filter(!is.na(asegurados))

anuarios_regimen <- read_csv(file.path(data, "raw", "anuarios_regimen.csv"))

inss_reg <- inss_reg %>% 
  bind_rows(anti_join(anuarios_regimen, inss_reg, by = c("year", "month", "regimen"))) %>% 
  arrange(year, match(month, unique(inss_reg$month)), match(regimen, unique(inss_reg$regimen)))

regimen_labels <- c(obl_integral = "Obligatorio Integral",
                    obl_ivm      = "Obligatorio IVM",
                    fac_integral = "Facultativo Integral",
                    fac_ivm      = "Facultativo IVM")

inss_reg <- inss_reg %>% 
  mutate(regimen = unname(regimen_labels[regimen]))

inss_reg_dic <- read_csv(file.path(data, "raw", "anuarios_regimen_historico.csv")) %>% 
  filter(year < min(inss_reg$year)) %>% 
  mutate(regimen = unname(regimen_labels[regimen])) %>% 
  bind_rows(inss_reg %>% filter(month == "Diciembre") %>% select(year, regimen, asegurados)) %>% 
  arrange(year, match(regimen, regimen_labels))

inss_salarios <- read_csv(file.path(data, "raw", "anuarios_salarios.csv")) %>% 
  mutate(regimen = unname(regimen_labels[regimen]))

inss_empleadores <- read_csv(file.path(data, "raw", "anuarios_empleadores.csv")) %>% 
  mutate(regimen = unname(regimen_labels[regimen]))

inss_departamento <- read_csv(file.path(data, "raw", "anuarios_departamento.csv")) %>% 
  select(year, departamento, departamento_anuario, gender, asegurados) %>% 
  arrange(year, departamento, departamento_anuario, gender)

# Save data ---------------------------------------------------------------

save_data <- function(df, name) {
  write_csv(df, file.path(data, paste0(name, ".csv")))
  write_rds(df, file.path(data, paste0(name, ".rds")))
}

save_data(inss,              "inss_gender")
save_data(inss_reg,          "inss_regimen")
save_data(inss_reg_dic,      "inss_regimen_diciembre")
save_data(inss_salarios,     "inss_salarios")
save_data(inss_empleadores,  "inss_empleadores")
save_data(inss_departamento, "inss_departamento")
