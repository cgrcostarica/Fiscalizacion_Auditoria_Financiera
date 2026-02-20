library(tidyverse)
library(readxl)

folder <-
  "G:/.shortcut-targets-by-id/17mivKoTnXEncz-Rp75Nrkvsqp2KFLF8M/Planillas_CNC/"
files <- list.files(folder, recursive = T)

trans <- function(x) {
  mes <- tolower(str_match(x, "Mensual (\\w+)")[, 2])
  data <- read_xlsx(paste0(folder, x), skip = 1)
  colnames(data)[1:2] <- c("cedula", "nombre")
  data <- data %>%
    filter(grepl("^\\d", cedula)) %>%
    pivot_longer(-c(1:2), names_to = "item", values_to = "monto") %>%
    mutate(mes = mes)
  return(data)
}

dic_meses <- data.frame(
  orden = 1:12,
  mes = c("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "setiembre", "octubre", "noviembre", "diciembre")
)

planillas_mensuales <- lapply(files[-13], trans)
planillas_mensuales <- bind_rows(planillas_mensuales) %>%
  left_join(dic_meses) %>%
  arrange(orden, item) %>%
  select(-orden)

openxlsx::write.xlsx(planillas_mensuales, "planillas_cnc.xlsx")

sal_escolar <- read_xlsx(paste0(folder, files[13]), skip = 1)
colnames(sal_escolar) <- c("cedula", "nombre", "salario_escolar")

openxlsx::write.xlsx(sal_escolar, "salario_escolar_cnc.xlsx")
