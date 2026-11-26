
# Packages ----------------------------------------------------------------

library(tidyverse)

# Paths -------------------------------------------------------------------

project  <- "."
raw      <- file.path(project, "data", "raw")
anuarios <- file.path(raw, "anuarios")
dir.create(anuarios, showWarnings = FALSE, recursive = TRUE)

# Sources -----------------------------------------------------------------
# inss.gob.ni sits behind a Cloudflare challenge, so the yearbooks come from
# Wayback Machine captures. The 2012 capture is truncated and is left out.

wayback <- "https://web.archive.org/web/%sid_/%s"
sources <- tribble(
  ~year, ~timestamp,       ~url,
  2006,  "20220711151140", "https://inss-princ.inss.gob.ni/attachments/article/22/022_Anuario%202006%20INSS.pdf",
  2007,  "20081008223254", "http://www.inss.gob.ni:80/files/docanuario/1222441698_Anuarios%202007-18-08-2008.pdf",
  2008,  "20220711151103", "https://inss-princ.inss.gob.ni/attachments/article/81/081_Anuario%20%20estadistisco%202008.pdf",
  2009,  "20220711151017", "https://inss-princ.inss.gob.ni/attachments/article/120/anuario_estadistico_2009.pdf",
  2010,  "20220711150939", "https://inss-princ.inss.gob.ni/attachments/article/149/149_anuario_2010.pdf",
  2011,  "20220711150901", "https://inss-princ.inss.gob.ni/attachments/article/182/182_Anuario%20Estadistico%202011.pdf",
  2013,  "20140513130517", "http://www.inss.gob.ni:80/anuario/2013/anuario_2013.pdf",
  2014,  "20220711150613", "https://inss-princ.inss.gob.ni/images/anuario_estdistico_2014.pdf",
  2015,  "20220711150535", "https://inss-princ.inss.gob.ni/images/anuario_estadistico_2015.pdf",
  2016,  "20220711150456", "https://inss-princ.inss.gob.ni/images/anuario_estadistico_2016.pdf",
  2017,  "20220707011017", "https://inss-princ.inss.gob.ni/images/anuario_estadistico_2017.pdf",
  2018,  "20220707010942", "https://inss-princ.inss.gob.ni/images/anuario_estadistico_2018.pdf",
  2019,  "20210721142446", "https://inss-princ.inss.gob.ni/images/anuario_estadistico_2019.pdf",
  2020,  "20220402110304", "https://inss-princ.inss.gob.ni/images/anuarios/Anuario_Estadstico_2020.pdf",
  2021,  "20240911022429", "https://inss-princ.inss.gob.ni/images/anuarios/Anuario_Estadistico_2021.pdf",
  2022,  "20240418113759", "https://inss-princ.inss.gob.ni/images/anuarios/Anuario_Estadistico_2022.pdf",
  2023,  "20250517114341", "https://inss-princ.inss.gob.ni/images/anuarios/Anuario_Estadistico_2023.pdf",
  2024,  "20260926063612", "https://inss-princ.inss.gob.ni/images/anuarios/Anuario_Estadistico_2024.pdf?utm_source=chatgpt.com"
) %>%
  mutate(pdf = file.path(anuarios, paste0("anuario_", year, ".pdf")))

download_pdf <- function(timestamp, url, pdf, tries = 3) {
  if (file.exists(pdf)) return(invisible(pdf))
  for (i in seq_len(tries)) {
    ok <- tryCatch(
      download.file(sprintf(wayback, timestamp, url), pdf, mode = "wb", quiet = TRUE) == 0,
      error = function(e) FALSE
    )
    if (ok && readChar(pdf, 4, useBytes = TRUE) == "%PDF") return(invisible(pdf))
    unlink(pdf)
  }
  stop("Could not download ", url)
}

options(timeout = 600)
pwalk(select(sources, timestamp, url, pdf), download_pdf)

# Parsing -----------------------------------------------------------------

meses_abr <- c("ene", "feb", "mar", "abr", "may", "jun",
               "jul", "ago", "sep", "oct", "nov", "dic")
meses     <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio",
               "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")

pdf_lines <- function(pdf) {
  system2("pdftotext", c("-layout", shQuote(pdf), "-"), stdout = TRUE, stderr = FALSE)
}

number <- "[0-9][0-9.,]*"

parse_numbers <- function(x) {
  as.numeric(str_remove_all(str_extract_all(x, number)[[1]], "[.,]"))
}

parse_amounts <- function(x) {
  tokens   <- str_extract_all(x, number)[[1]]
  decimals <- coalesce(str_length(str_match(tokens, "[.,](\\d{1,2})$")[, 2]), 0L)
  as.numeric(str_remove_all(tokens, "[.,]")) / 10^decimals
}

first_table <- function(lines, title, parse_block, ok, year) {
  starts <- which(str_detect(lines, regex(title, ignore_case = TRUE)))
  for (start in starts) {
    block <- lines[start:min(length(lines), start + 120)]
    out   <- parse_block(block, year)
    if (ok(out)) return(out)
  }
  message("Sin cuadro '", title, "' en ", year)
  NULL
}

parse_gender <- function(block, year) {
  stops <- which(str_detect(block, regex("^\\s*(fuente|total|ambos)", ignore_case = TRUE)))
  women <- which(str_detect(block, "^\\s*Mujeres\\s+\\d"))[1]
  end   <- coalesce(stops[stops > women][1], length(block))
  row   <- str_match(block[seq_len(end)],
                     sprintf("^\\s*(Hombres|Mujeres|De - 14|0 - 14|\\d{2} - \\d{2}|65 y [Mm][aá]s)\\b.*?\\s((?:%s\\s+){11,12}%s)\\s*$",
                             number, number))
  row   <- row[!is.na(row[, 1]), , drop = FALSE]

  out <- list(); sex <- NA_character_
  for (i in seq_len(nrow(row))) {
    label  <- row[i, 2]
    values <- parse_numbers(row[i, 3])[1:12]
    if (label %in% c("Hombres", "Mujeres")) {
      sex <- label
      out[[length(out) + 1]] <- tibble(year, gender = sex, edad = "subtotal", mes = meses_abr, asegurados = values)
      next
    }
    edad <- case_when(label %in% c("De - 14", "0 - 14") ~ "0-14",
                      str_detect(label, "^65") ~ "65 y Más",
                      TRUE ~ str_remove_all(label, " "))
    out[[length(out) + 1]] <- tibble(year, gender = sex, edad, mes = meses_abr, asegurados = values)
  }
  bind_rows(out)
}

# Month-by-regime tables: each row is a month, then one column per regime,
# sometimes a subtotal, and a total in the last column.
parse_months <- function(regimenes, parse = parse_numbers) {
  function(block, year) {
    row <- str_match(block[1:60], sprintf("^\\s*(%s)\\s+((?:%s\\s+){%d,}%s)\\s*$",
                                          paste(meses, collapse = "|"), number,
                                          length(regimenes), number))
    row <- head(row[!is.na(row[, 1]), , drop = FALSE], 12)
    map2_dfr(row[, 2], row[, 3], function(month, values) {
      v <- parse(values)
      tibble(year, month, regimen = c(regimenes, "total"),
             value = c(v[seq_along(regimenes)], v[length(v)]))
    })
  }
}

parse_historico <- function(block, year) {
  end <- coalesce(which(str_detect(block, regex("^\\s*fuente", ignore_case = TRUE)))[1], 60L)
  row <- str_match(block[seq_len(end)], sprintf("^\\s*(\\d{4})\\s+((?:%s\\s+){4}%s)\\s*$", number, number))
  row <- row[!is.na(row[, 1]), , drop = FALSE]
  map2_dfr(as.numeric(row[, 2]), row[, 3], function(anio, values) {
    tibble(edicion = year, year = anio, regimen = c(regimenes_asegurados, "total"),
           asegurados = parse_numbers(values))
  })
}

parse_departamento <- function(block, year) {
  header <- block[str_detect(block, regex("(masculino|hombres).*(femenino|mujeres)|(femenino|mujeres).*(masculino|hombres)", ignore_case = TRUE))][1]
  if (is.na(header)) return(tibble())
  sexes  <- if (str_detect(header, regex("^.*(femenino|mujeres).*(masculino|hombres)", ignore_case = TRUE))) {
    c("Mujeres", "Hombres")
  } else {
    c("Hombres", "Mujeres")
  }
  end <- which(str_detect(block, regex("^\\s*total", ignore_case = TRUE)))[1]
  if (is.na(end)) return(tibble())
  row <- str_match(block[2:end], sprintf("^\\s*([[:alpha:]][[:alpha:]. ]*?)(?:\\s+\\d/)?\\s+(%s)\\s+(%s)\\s+(%s)\\s*$",
                                         number, number, number))
  row <- row[!is.na(row[, 1]), , drop = FALSE]
  tibble(year,
         departamento_anuario = str_squish(row[, 2]),
         !!sexes[1] := as.numeric(str_remove_all(row[, 3], "[.,]")),
         !!sexes[2] := as.numeric(str_remove_all(row[, 4], "[.,]")),
         total      = as.numeric(str_remove_all(row[, 5], "[.,]")))
}

regimenes_asegurados <- c("obl_integral", "obl_ivm", "fac_integral", "fac_ivm")

titles <- list(
  gender       = "asegurados activos por mes, seg[uú]n (sexo y grupos? de edad|grupos de edad y sexo)",
  regimen      = "^(?=.*asegurados activos)(?=.*(r[eé]gimen|reg[ií]menes))(?=.*\\bmes\\b)",
  salarios     = "^(?=.*salarios devengados)(?=.*\\bmes\\b)",
  promedio     = "^(?=.*salarios? promedio)(?=.*\\bmes\\b)",
  empleadores  = "^(?=.*empleadores activos)(?=.*\\bmes\\b)",
  historico    = "diciembre( de los a[nñ]os)?\\s+1994\\s*-\\s*\\d{4}",
  departamento = "^\\s*(n[uú]mero de )?asegurados activos,? por sexo,? seg[uú]n departamentos?"
)

n_rows <- function(n) function(out) nrow(out) == n

lines <- map(sources$pdf, pdf_lines)

extract <- function(title, parse_block, ok, years = sources$year) {
  keep <- sources$year %in% years
  map2_dfr(lines[keep], sources$year[keep], ~ first_table(.x, title, parse_block, ok, .y))
}

# OCR ---------------------------------------------------------------------
# A few tables are printed as rotated images with no text layer. They are read
# with tesseract and must pass the same checks as the text tables.

ocr_tables <- tribble(
  ~year, ~tabla,         ~page, ~rotate,
  2016,  "salarios",     63,    TRUE,
  2016,  "departamento", 33,    FALSE
)

ocr_text <- function(year, page, rotate) {
  pdf    <- sources$pdf[sources$year == year]
  prefix <- tempfile()
  system2("pdftoppm", c("-f", page, "-l", page, "-r", 400, "-gray", "-png", "-singlefile", shQuote(pdf), prefix))
  image  <- png::readPNG(paste0(prefix, ".png"))
  if (length(dim(image)) == 3) image <- image[, , 1]
  if (rotate) image <- t(image[nrow(image):1, ])
  png::writePNG(image, paste0(prefix, "_ocr.png"))
  system2("tesseract", c(paste0(prefix, "_ocr.png"), "-", "--psm", 6, "-c", "preserve_interword_spaces=1"),
          stdout = TRUE, stderr = FALSE)
}

ocr_months <- function(ocr) {
  month  <- str_match(ocr, "^\\s*([[:alpha:]]{3})[[:alpha:]]*\\s+(.*)$")
  month  <- month[!is.na(month[, 1]) & str_to_lower(month[, 2]) %in% str_to_lower(str_sub(meses, 1, 3)), , drop = FALSE]
  values <- month[, 3] %>%
    str_replace_all("(?<=[0-9,.]) (?=[0-9,.])", "") %>%
    str_replace_all("[^0-9,. ]", " ") %>%
    map_chr(~ paste(keep(str_split(.x, "\\s+")[[1]], function(token) str_length(token) >= 5), collapse = "  "))
  paste(meses[match(str_to_lower(month[, 2]), str_to_lower(str_sub(meses, 1, 3)))], values, sep = "  ")
}

gender       <- extract(titles$gender, parse_gender, n_rows(2 * 13 * 12))
regimen      <- extract(titles$regimen, parse_months(regimenes_asegurados), n_rows(12 * 5)) %>%
  rename(asegurados = value)
salarios     <- extract(titles$salarios, parse_months(regimenes_asegurados, parse_amounts), n_rows(12 * 5)) %>%
  bind_rows(pmap_dfr(filter(ocr_tables, tabla == "salarios"),
                     function(year, tabla, page, rotate) parse_months(regimenes_asegurados, parse_amounts)(ocr_months(ocr_text(year, page, rotate)), year))) %>%
  rename(salarios = value)
promedio     <- extract(titles$promedio, parse_months(regimenes_asegurados, parse_amounts), n_rows(12 * 5)) %>%
  rename(salario_promedio = value)
empleadores  <- extract(titles$empleadores, parse_months(c("obl_integral", "obl_ivm")), n_rows(12 * 3)) %>%
  rename(empleadores = value)
departamento <- extract(titles$departamento, parse_departamento,
                        function(out) nrow(out) >= 16 && str_detect(tail(out$departamento_anuario, 1), regex("^total", ignore_case = TRUE))) %>%
  bind_rows(pmap_dfr(filter(ocr_tables, tabla == "departamento"),
                     function(year, tabla, page, rotate) parse_departamento(ocr_text(year, page, rotate), year) %>%
                       mutate(ocr = TRUE))) %>%
  mutate(departamento = case_when(
    str_detect(departamento_anuario, regex("^total", ignore_case = TRUE)) ~ "Total",
    str_detect(departamento_anuario, regex("^mga|managua", ignore_case = TRUE)) ~ "Managua",
    str_detect(departamento_anuario, regex("raan|raccn", ignore_case = TRUE)) ~ "RACCN",
    str_detect(departamento_anuario, regex("raas|raccs", ignore_case = TRUE)) ~ "RACCS",
    str_detect(departamento_anuario, regex("segovia", ignore_case = TRUE)) ~ "Nueva Segovia",
    str_detect(departamento_anuario, regex("san juan", ignore_case = TRUE)) ~ "Río San Juan",
    str_detect(departamento_anuario, regex("^le.n$", ignore_case = TRUE)) ~ "León",
    str_detect(departamento_anuario, regex("^estel", ignore_case = TRUE)) ~ "Estelí",
    TRUE ~ departamento_anuario
  ),
  departamento_anuario = if_else(coalesce(ocr, FALSE), departamento, departamento_anuario)) %>%
  select(-ocr)
historico    <- map2_dfr(lines[sources$year <= 2013], sources$year[sources$year <= 2013],
                         ~ first_table(.x, titles$historico, parse_historico, n_rows((.y - 1993) * 5), .y))

# Some yearbooks print the wage bill in córdobas and others in thousands, and
# the column headers do not always say which. The published average wage is
# the wage bill divided by insured workers, so that ratio gives the unit.

escala_salarios <- salarios %>%
  filter(regimen != "total") %>%
  inner_join(promedio, by = c("year", "month", "regimen")) %>%
  inner_join(regimen,  by = c("year", "month", "regimen")) %>%
  group_by(year) %>%
  summarise(escala = 10^round(log10(median(salario_promedio * asegurados / salarios))))

salarios <- salarios %>%
  inner_join(escala_salarios, by = "year") %>%
  mutate(salarios = salarios * escala) %>%
  select(-escala)

cat("Años con salarios en miles de córdobas:", filter(escala_salarios, escala != 1)$year, "\n")

# Checks ------------------------------------------------------------------
# Each table carries its own totals, and several tables report the same
# quantity. Any disagreement is a typo in the yearbook or a parsing error, so
# every check prints the rows that fail.

checks <- list()

checks$gender_subtotal <- gender %>%
  group_by(year, gender, mes) %>%
  summarise(subtotal = asegurados[edad == "subtotal"],
            suma     = sum(asegurados[edad != "subtotal"]),
            n_edad   = sum(edad != "subtotal"),
            .groups  = "drop") %>%
  filter(subtotal != suma | n_edad != 12)

sum_check <- function(data, value, tolerance = 0) {
  data %>%
    group_by(year, month) %>%
    summarise(total = {{ value }}[regimen == "total"],
              suma  = sum({{ value }}[regimen != "total"]),
              .groups = "drop") %>%
    filter(abs(total - suma) > tolerance * total)
}

checks$regimen_total     <- sum_check(regimen, asegurados)
checks$empleadores_total <- sum_check(empleadores, empleadores)
checks$salarios_total    <- sum_check(salarios, salarios, tolerance = 1e-6)

checks$salario_promedio <- promedio %>%
  filter(regimen != "total") %>%
  inner_join(salarios, by = c("year", "month", "regimen")) %>%
  inner_join(regimen,  by = c("year", "month", "regimen")) %>%
  mutate(calculado = salarios / asegurados) %>%
  filter(abs(calculado - salario_promedio) > 0.06)

departamento_total <- departamento %>% filter(departamento == "Total")
departamento       <- departamento %>% filter(departamento != "Total")

checks$departamento_filas <- departamento %>% filter(Hombres + Mujeres != total)

checks$departamento_total <- departamento %>%
  group_by(year) %>%
  summarise(across(c(Hombres, Mujeres, total), sum)) %>%
  inner_join(departamento_total, by = "year", suffix = c("_suma", "_anuario")) %>%
  filter(Hombres_suma != Hombres_anuario | Mujeres_suma != Mujeres_anuario | total_suma != total_anuario)

checks$departamento_vs_edad <- departamento_total %>%
  select(year, Hombres, Mujeres) %>%
  pivot_longer(-year, names_to = "gender", values_to = "departamento") %>%
  inner_join(gender %>% filter(edad == "subtotal", mes == "dic") %>% select(year, gender, edad_sexo = asegurados),
             by = c("year", "gender")) %>%
  filter(departamento != edad_sexo)

checks$historico_total <- historico %>%
  group_by(edicion, year) %>%
  summarise(total = asegurados[regimen == "total"], suma = sum(asegurados[regimen != "total"]), .groups = "drop") %>%
  filter(total != suma)

checks$historico_ediciones <- historico %>%
  group_by(year, regimen) %>%
  filter(n_distinct(asegurados) > 1) %>%
  arrange(year, regimen, edicion)

checks$historico_vs_mensual <- historico %>%
  filter(edicion == max(edicion), regimen != "total") %>%
  inner_join(regimen %>% filter(month == "Diciembre"), by = c("year", "regimen"), suffix = c("_historico", "_mensual")) %>%
  filter(asegurados_historico != asegurados_mensual)

stopifnot(
  setequal(unique(gender$year),       sources$year),
  setequal(unique(regimen$year),      sources$year),
  setequal(unique(salarios$year),     sources$year),
  setequal(unique(promedio$year),     sources$year),
  setequal(unique(empleadores$year),  sources$year),
  setequal(unique(departamento$year), sources$year)
)

iwalk(checks, function(failures, name) cat(sprintf("%-22s %d filas con diferencias\n", name, nrow(failures))))
walk(keep(checks, ~ nrow(.x) > 0), ~ print(.x, n = Inf, width = Inf))

# Save --------------------------------------------------------------------

gender %>%
  filter(edad != "subtotal") %>%
  write_csv(file.path(raw, "anuarios_gender.csv"))

regimen %>%
  filter(regimen != "total") %>%
  write_csv(file.path(raw, "anuarios_regimen.csv"))

salarios %>%
  filter(regimen != "total") %>%
  inner_join(promedio, by = c("year", "month", "regimen")) %>%
  write_csv(file.path(raw, "anuarios_salarios.csv"))

empleadores %>%
  filter(regimen != "total") %>%
  write_csv(file.path(raw, "anuarios_empleadores.csv"))

departamento %>%
  select(-total) %>%
  pivot_longer(c(Hombres, Mujeres), names_to = "gender", values_to = "asegurados") %>%
  write_csv(file.path(raw, "anuarios_departamento.csv"))

historico %>%
  filter(edicion == max(edicion), regimen != "total") %>%
  select(-edicion) %>%
  write_csv(file.path(raw, "anuarios_regimen_historico.csv"))
