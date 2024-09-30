# Carga de las librerías necesarias: tidyverse para la manipulación de datos y openxlsx para trabajar con archivos Excel
library(tidyverse, quietly = T)
library(openxlsx)

# Definir la carpeta donde se encuentran los archivos de datos
# Recuerde reemplazar "datos/" por el nombre de la carpeta correspondiente
carpeta <- "datos/"

# Crear un diccionario de meses para usarse en ordenamiento o en procesos que requieren identificación cronológica
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
  orden = c(1:9, 9, 10:12) # "setiembre" y "septiembre" tienen el mismo orden
)

## Procesamiento de las bases COMCURE

# Listar todos los archivos en la carpeta que contienen "COMCURE" en su nombre
bases_comcure <- list.files(carpeta, "COMCURE")

# Definir las columnas relevantes de los archivos COMCURE
cols_comcure <- c(
  "Entidad.CP", "Ejercicio", "Centro.Gestor", "Posicion.presupuestaria", "Fondos",
  "Clasif.Economica", "Clasif.Funcional", "Descripcion", "Descripcion1", "Ley.de.Presupuesto",
  "Presupuesto.Actual", "Cuota.Liberacion", "Solicitado", "Comprometido", "Recep.Mercancias",
  "Devengado", "Pagado", "Pagado.Mensual", "Gasto.Efectivo", "Gasto.Total", "Disp..Liberacion",
  "Disp..Presupuesto", "Disp..Provisional", "Disp..Bloqueo", "Bloqueo", "Rebajas.Preliminares",
  "Aumentos.Preliminares", "Rebajas.Contabilizadas", "Aumentos.Contabilizadas"
)

# Variable para contar las filas procesadas
filas <- 0

# Bucle para procesar cada archivo COMCURE
for (base in bases_comcure) {
  # Leer el archivo y convertir las primeras 9 columnas a carácter
  temp <- read.xlsx(paste0("datos/", base)) %>%
    mutate(across(1:9, as.character)) %>%
    filter(!is.na(.[, 1])) %>%  # Filtrar filas con valores nulos en la primera columna
    select(all_of(cols_comcure)) %>%  # Seleccionar solo las columnas relevantes
    mutate(Período = str_match(base, "\\d-(\\d+)")[2])  # Extraer el período del nombre del archivo
  
  # Si el objeto comcure no existe, crearlo; si existe, combinar con los nuevos datos
  if (!exists("comcure")) {
    comcure <- temp
  } else {
    comcure <- rbind(comcure, temp)
  }
  
  # Sumar el número de filas procesadas
  filas <- filas + nrow(temp)
}

# Eliminar el objeto temporal para liberar memoria
rm(temp)

# Guardar la base consolidada de COMCURE en un archivo Excel
write.xlsx(comcure, "base_comcure.xlsx")


## Procesamiento de las bases SINAC Acumulada

# Listar todos los archivos con "SINAC" en el nombre
bases_sinac <- list.files(carpeta, "SINAC")

# Leer la primera hoja del primer archivo SINAC y seleccionar solo la hoja 7
sinac_acum <- read.xlsx(paste0(carpeta, bases_sinac[1]), sheet = 7, check.names = T)

# Definir las columnas relevantes de SINAC Acumulada
cols_sinac_acum <- c("Base", "Fuente.Financiamiento", "Elemento.PEP", "Centro.Gestor", 
                     "Posición.presupuestaria", "Devendado", "Pagado")

# Seleccionar solo las columnas relevantes
sinac_acum <- sinac_acum %>% select(all_of(cols_sinac_acum))

## Agrupar y resumir los datos de SINAC General

# Agrupar por "Posición.presupuestaria" y sumar las columnas "Devendado" y "Pagado"
sinac_general <- sinac_acum %>%
  group_by(Posición.presupuestaria) %>%
  summarise(
    "Suma de Devendado" = sum(Devendado, na.rm = T),
    "Suma de Pagado" = sum(Pagado, na.rm = T)
  )

# Guardar los resultados de SINAC (general y acumulada) en un archivo Excel
write.xlsx(list("general" = sinac_general, "acumulada" = sinac_acum), "base_sinac.xlsx")


## Procesamiento de las bases FONAFIFO

# Listar todos los archivos con "FONAFIFO" en el nombre
bases_fonafifo <- list.files(carpeta, "FONAFIFO")

# Leer la hoja 2 del primer archivo FONAFIFO, comenzando desde la fila 5
fonafifo <- read.xlsx(paste0(carpeta, bases_fonafifo[1]), sheet = 2, startRow = 5, check.names = T)

# Definir las columnas relevantes de FONAFIFO
cols_fonafifo <- c(
  "Responsable.Presupuestario", "Unidad.Ejecutora", "Financiador", "Posición.Presupuestaria", 
  "Sub.partida", "Descripción.SubPartida", "Cuenta.Contable", "Descripción.Cuenta.Contable", 
  "Acción.PAO", "Descripción.Acción.PAO", "Descripción.USO.del.presupuesto", 
  "Presupuesto.Inicial", "Modificación", "Extraordinario", "Presupuesto.Aprobado", 
  "Presupuesto.Ejecutado.siGAFI", "Ajustes.a.la.Ejecución", "Presupuesto.Ejecutado..Devengado.", 
  "Presupuesto.Pagado", "Presupuesto.por.pagar.2024", "Presupuesto.sin.ejecutar"
)

# Seleccionar solo las columnas relevantes
fonafifo <- fonafifo %>% select(all_of(cols_fonafifo))

## Información SIGAF

# Leer la hoja 3 del mismo archivo FONAFIFO, comenzando desde la fila 5
info_sigaf <- read.xlsx(paste0(carpeta, bases_fonafifo[1]), sheet = 3, startRow = 5, check.names = T)

# Definir las columnas relevantes de SIGAF
cols_info_sigaf <- c(
  "Posición.Presupuestaria", "Descripción.SubPartida", "Suma.de.Presupuesto.Aprobado", 
  "Suma.Presupuesto.Ejecutado..Devengado.", "Presupuesto.Ejecutado.Pagado"
)

# Seleccionar solo las columnas relevantes de SIGAF
info_sigaf <- info_sigaf %>% select(all_of(cols_info_sigaf))

# Guardar la base de FONAFIFO y la información SIGAF en un archivo Excel
write.xlsx(list("base" = fonafifo, "informacion_sigaf" = info_sigaf), "base_fonafifo.xlsx")


## Procesamiento de las bases MINAE

# Listar todos los archivos con "MINAE" en el nombre
bases_minae <- list.files(carpeta, "MINAE")

# Leer el primer archivo MINAE
minae <- read.xlsx(paste0("datos/", bases_minae[1]), check.names = T)

# Definir las columnas relevantes de MINAE
cols_minae <- c(
  "Número.de.documento.precedente", "Número.de.documento.del.documento.de.ref", 
  "Ejercicio.para.el.número.de.documento.FI", "Período", "Texto.tipo.de.valor", 
  "Clase.de.importe", "Fecha.de.actualización.del.control.presu", 
  "Contra.presupuesto.p.importe.verific.en.Colones", "Contra.presupuesto.p.importe.verific.en.dolares", 
  "Diferencia.H...I.Dolares", "Moneda.transacción", "Sociedad", "Posición.presupuestaria", 
  "Denominación.de.posición.presupuestaria", "Centro.gestor", "Fondo", "Nº.doc.finanzas", 
  "Nº.documento.de.pago", "Fe.contabilización", "Clase.de.importe", "Texto", "Acreedor", 
  "Cuenta.de.mayor", "Responsable.de.centro.gestor.en.modelo.d", "Ejercicio", "Entidad.CP", 
  "Texto.clase.de.fondo", "Denominación.del.fondo", "Clase.de.fondos", 
  "Denominación.del.centro.gestor", "Área.funcional", "Denominación.del.área.funcional", 
  "Moneda.entidad.CP"
)

# Seleccionar solo las columnas relevantes de MINAE
minae <- minae %>% select(all_of(cols_minae))

# Guardar la base de MINAE en un archivo Excel
write.xlsx(minae, "base_minae.xlsx")
