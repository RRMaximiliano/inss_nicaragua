
# Load packages -----------------------------------------------------------

library(tidyverse)
library(readxl)

# Read data ---------------------------------------------------------------
project <- file.path("D:/Documents/GitHub/inss_nicaragua")
data    <- file.path(project, "data")
figs    <- file.path(project, "figs")

inss_raw <- read_excel(file.path(data, "raw", "raw_inss.xlsx")) %>% 
  janitor::clean_names()

inss <- inss_raw %>% 
  pivot_longer(
    4:15, 
    names_to = "mes",
    values_to = "asegurados"
  )
  
inss_reg_raw <- read_excel(file.path(data, "raw", "raw_inss_regimen.xlsx")) %>% 
  janitor::clean_names()

inss_reg <- inss_reg_raw %>% 
  pivot_longer(
    3:6,
    names_to = "regimen",
    values_to = "asegurados"
  )

inss_reg <- inss_reg %>% 
  mutate(
    regimen = case_when(regimen == "fac_integral" ~  "Facultativo Integral",
                        regimen == "fac_ivm"      ~  "Facultativo IVM",
                        regimen == "obl_integral" ~  "Obligatorio Integral",
                        regimen == "obl_ivm"      ~  "Obligatorio IVM")
  )

# Save data ---------------------------------------------------------------

inss %>% 
  write_csv(file.path(data, "inss_gender.csv"))
  
inss %>% 
  write_rds(file.path(data, "inss_gender.rds"))


inss_reg %>% 
  write_csv(file.path(data, "inss_regimen.csv"))

inss_reg %>% 
  write_rds(file.path(data, "inss_regimen.rds"))
