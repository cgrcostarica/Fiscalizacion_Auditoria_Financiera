library(tidyverse, quietly = T)
library(openxlsx)

# recuerde reemplazar "datos/" por el nombre de la carpeta que contiene las bases

carpeta <- "datos/"

dic_meses <- data.frame(
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
    "septiembre",
    "octubre",
    "noviembre",
    "diciembre"
  ),
  orden = c(1:9, 9, 10:12)
)

## BASES COMCURE

bases_comcure <- list.files(carpeta, "COMCURE")
cols_comcure <-
  c(
    "Entidad.CP",
    "Ejercicio",
    "Centro.Gestor",
    "Posicion.presupuestaria",
    "Fondos",
    "Clasif.Economica",
    "Clasif.Funcional",
    "Descripcion",
    "Descripcion1",
    "Ley.de.Presupuesto",
    "Presupuesto.Actual",
    "Cuota.Liberacion",
    "Solicitado",
    "Comprometido",
    "Recep.Mercancias",
    "Devengado",
    "Pagado",
    "Pagado.Mensual",
    "Gasto.Efectivo",
    "Gasto.Total",
    "Disp..Liberacion",
    "Disp..Presupuesto",
    "Disp..Provisional",
    "Disp..Bloqueo",
    "Bloqueo",
    "Rebajas.Preliminares",
    "Aumentos.Preliminares",
    "Rebajas.Contabilizadas",
    "Aumentos.Contabilizadas"
  )

filas <- 0
for (base in bases_comcure) {
  temp <- read.xlsx(paste0("datos/", base)) %>%
    mutate(across(1:9, as.character)) %>%
    filter(!is.na(.[, 1])) %>%
    select(all_of(cols_comcure)) %>%
    mutate(Período = str_match(base, "\\d-(\\d+)")[2])
  if (!exists("comcure")) {
    comcure <- temp
  } else {
    comcure <- rbind(comcure, temp)
  }
  filas <- filas + nrow(temp)
}
rm(temp)
write.xlsx(comcure, "base_comcure.xlsx")



## BASES SINAC ACUMULADA

bases_sinac <- list.files(carpeta, "SINAC")
sinac_acum <- read.xlsx(paste0(carpeta, bases_sinac[1]),
                        sheet = 7,
                        check.names = T)

cols_sinac_acum <-
  c(
    "Base",
    "Fuente.Financiamiento",
    "Elemento.PEP",
    "Centro.Gestor",
    "Posición.presupuestaria",
    "Devendado",
    "Pagado"
  )

sinac_acum <- sinac_acum %>%
  select(all_of(cols_sinac_acum))

## BASES SINAC GENERAL

sinac_general <- sinac_acum %>%
  group_by(Posición.presupuestaria) %>%
  summarise(
    "Suma de Devendado" = sum(Devendado, na.rm = T),
    "Suma de Pagado" = sum(Pagado, na.rm = T)
  )

write.xlsx(list("general" = sinac_general,
                "acumulada" = sinac_acum),
           "base_sinac.xlsx")

## FONAFIFO

bases_fonafifo <- list.files(carpeta, "FONAFIFO")
fonafifo <-
  read.xlsx(
    paste0(carpeta, bases_fonafifo[1]),
    sheet = 2,
    startRow = 5,
    check.names = T
  )

cols_fonafifo <- c(
  "Responsable.Presupuestario",
  "Unidad.Ejecutora",
  "Financiador",
  "Posición.Presupuestaria",
  "Sub.partida",
  "Descripción.SubPartida",
  "Cuenta.Contable",
  "Descripción.Cuenta.Contable",
  "Acción.PAO",
  "Descripción.Acción.PAO",
  "Descripción.USO.del.presupuesto",
  "Presupuesto.Inicial",
  "Modificación",
  "Extraordinario",
  "Presupuesto.Aprobado",
  "Presupuesto.Ejecutado.siGAFI",
  "Ajustes.a.la.Ejecución",
  "Presupuesto.Ejecutado..Devengado.",
  "Presupuesto.Pagado",
  "Presupuesto.por.pagar.2024",
  "Presupuesto.sin.ejecutar"
)

fonafifo <- fonafifo %>%
  select(all_of(cols_fonafifo))

## INFORMACIÓN SIGAF

info_sigaf <- read.xlsx(
  paste0(carpeta, bases_fonafifo[1]),
  sheet = 3,
  startRow = 5,
  check.names = T
)

cols_info_sigaf <-
  c(
    "Posición.Presupuestaria",
    "Descripción.SubPartida",
    "Suma.de.Presupuesto.Aprobado",
    "Suma.Presupuesto.Ejecutado..Devengado.",
    "Presupuesto.Ejecutado.Pagado"
  )

info_sigaf <- info_sigaf %>%
  select(all_of(cols_info_sigaf))

write.xlsx(list("base" = fonafifo,
                "informacion_sigaf" = info_sigaf),
           "base_fonafifo.xlsx")

## MINAE

bases_minae <- list.files(carpeta, "MINAE")
minae <-
  read.xlsx(paste0("datos/", bases_minae[1]), check.names = T)

cols_minae <- c(
  "Número.de.documento.precedente",
  "Número.de.documento.del.documento.de.ref",
  "Ejercicio.para.el.número.de.documento.FI",
  "Período",
  "Texto.tipo.de.valor",
  "Clase.de.importe",
  "Fecha.de.actualización.del.control.presu",
  "Contra.presupuesto.p.importe.verific.en.Colones",
  "Contra.presupuesto.p.importe.verific.en.dolares",
  "Diferencia.H...I.Dolares",
  "Moneda.transacción",
  "Sociedad",
  "Posición.presupuestaria",
  "Denominación.de.posición.presupuestaria",
  "Centro.gestor",
  "Fondo",
  "Nº.doc.finanzas",
  "Nº.documento.de.pago",
  "Fe.contabilización",
  "Clase.de.importe",
  "Texto",
  "Acreedor",
  "Cuenta.de.mayor",
  "Responsable.de.centro.gestor.en.modelo.d",
  "Ejercicio",
  "Entidad.CP",
  "Texto.clase.de.fondo",
  "Denominación.del.fondo",
  "Clase.de.fondos",
  "Denominación.del.centro.gestor",
  "Área.funcional",
  "Denominación.del.área.funcional",
  "Moneda.entidad.CP"
)

minae <- minae %>%
  select(all_of(cols_minae))

write.xlsx(minae, "base_minae.xlsx")
