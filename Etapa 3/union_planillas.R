library(readxl)
library(tidyverse)

files <- list.files(pattern = "\\.xlsx")
sheets <- lapply(files, \(x) excel_sheets(x))
names(sheets) <- files

dic_meses <- data.frame(
  orden = 1:12,
  mes = c(
    "enero",
    "febrero",
    "marzo",
    "abril",
    "mayo",
    "junio",
    "julio",
    "agosto",
    "setiembre",
    "octubre",
    "noviembre",
    "diciembre"
  )
)

conavi <- data.frame()
for (s in sheets$CONAVI_Planilla.xlsx) {
  mes <- str_match(s, "Q (\\w+)")[, 2]
  temp <- read_xlsx(files[1], sheet = s) %>%
    mutate(mes = mes)
  conavi <- bind_rows(conavi, temp)
}
conavi <- conavi %>%
  group_by(cedula, item, mes) %>%
  summarise(total = sum(monto)) %>%
  left_join(dic_meses, join_by(mes)) %>%
  arrange(orden, item) %>%
  select(-orden)

openxlsx::write.xlsx(conavi, "planilla_conavi.xlsx")

cosevi <- data.frame()
for (s in sheets$`COSEVI Planillas.xlsx`[1:24]) {
  mes <- str_match(s, "Quinc. (\\w+)")[, 2] %>%
    tolower()
  message(mes)
  temp <- read_xlsx(files[2], sheet = s, skip = 9) %>%
    filter(grepl("\\d", CEDULA)) %>%
    pivot_longer(`SALARIO BASE`:`TOTAL A PAGAR`,
                 names_to = "item",
                 values_to = "monto") %>%
    mutate(monto = as.numeric(monto), mes = mes) %>%
    filter(item != "TOTAL A PAGAR") %>%
    select(CEDULA, item, monto, mes)
  cosevi <- bind_rows(cosevi, temp)
}
colnames(cosevi) <- tolower(colnames(cosevi))
cosevi <- cosevi %>%
  left_join(dic_meses, join_by(mes)) %>%
  arrange(orden, item) %>%
  select(-orden) %>%
  relocate(mes, .before = monto)

cosevi_aguinaldo <- read_xlsx(files[2], sheet = "Aguinaldo 2023", skip = 9) %>%
  filter(grepl("\\d", CEDULA)) %>%
  select(CEDULA:`AGUINALDO NETO`)
colnames(cosevi_aguinaldo) <- tolower(colnames(cosevi_aguinaldo))
temp <- read_xlsx(files[2], sheet = "Ajuste Aguinaldo", skip = 6) %>%
  select(3:6)
colnames(temp) <- c("cedula", "aguinaldo bruto", "pension", "aguinaldo neto")
temp <- temp %>%
  filter(grepl("\\d", cedula)) %>%
  mutate(across(-cedula, \(x) as.numeric(x)))
cosevi_aguinaldo <- rbind(cosevi_aguinaldo, temp) %>%
  group_by(cedula) %>%
  summarise(across(everything(), sum))

cosevi_sal_escolar <- read_xlsx(files[2], sheet = "Salario Escolar 2023", skip = 9)
colnames(cosevi_sal_escolar) <- tolower(colnames(cosevi_sal_escolar))
cosevi_sal_escolar <- cosevi_sal_escolar %>%
  filter(grepl("\\d", cedula)) %>%
  select(cedula:`salario escolar neto`)

openxlsx::write.xlsx(cosevi, "planilla_cosevi.xlsx")
openxlsx::write.xlsx(cosevi_aguinaldo, "cosevi_aguinaldo.xlsx")
openxlsx::write.xlsx(cosevi_sal_escolar, "cosevi_sal_escolar.xlsx")
