# Fiscalizacion_Auditoria_Financiera

En esta carpeta guardamos los workflow de KNIME desarrollados en el proceso de Fiscalización Basada en Datos tanto etapa 1 como etapa 2.

Adicional, se desarrolló una App en R Shiny para la obtención y la evaluación de una muestra financiera. En este, se posee un archivo .zio con todos los archivos (scripts, datos de pruebas, etc). 

App de muestreo en Auditoria
Se desarrolló una App para la selección de una muestra financiera, así como la evaluación de la misma. 

Se utilizó el framework de R Shiny, y los archivos o scrips para lo anterior son: AppAuditSample.R, body.R, header.R, Librerias.R, Parametros.R, server.R, sider.R y el ui.R 

Cada utiliza una estructura manual de un proyecto en R, y todos los archivos anteriores son consumidos por el archivo AppAuditSample.R
La carpeta Scripts_dashboard posee los otros scripts mencionados anteriormente. 
Todos los demás son los componentes requeridos para poder desplegar una aplicación de Shiny. 

Las librerías y sus versiones utilizadas en este proyecto son 
jfa_0.6.7                d3r_1.0.1                htmltools_0.5.6          sunburstR_2.1.8          RcppRoll_0.3.0          
reactable_0.4.4          ggplot2_3.4.3            gt_0.9.0                 scales_1.2.1             png_0.1-8               
shinyWidgets_0.7.6       kableExtra_1.3.4         forecast_8.21            tidyr_1.3.0              data.table_1.14.8       
stringi_1.7.12           viridisLite_0.4.2        formattable_0.2.1        highcharter_0.9.4        shinydashboardPlus_2.0.3
janitor_2.2.0            readr_2.1.4              plyr_1.8.8               DT_0.28                  dplyr_1.1.2             
readxl_1.4.3             shinydashboard_0.7.2     shiny_1.7.5             

También, en el script Libreria.R, se muestre mediante el session() todo lo referente al sistema y librerías utilizadas en la construcción de la App. 
Finalmente, la carpeta de “data” posee dos archivos .csv para probar la funcionalidad de la App. 
