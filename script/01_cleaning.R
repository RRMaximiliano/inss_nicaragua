
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
  
# Save data ---------------------------------------------------------------

inss %>% 
  write_csv(file.path(data, "inss_gender.csv"))
  
inss %>% 
  write_rds(file.path(data, "inss_gender.rds"))

