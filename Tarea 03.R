# Carga de Paquetes 

library(sf)
library(raster)
library(dplyr)
library(spData)
library(leaflet)
library(plotly)
library(DT)


# Carga de la capa de primates 
primates <-
  st_read(
    "https://raw.githubusercontent.com/gf0604-procesamientodatosgeograficos/2021i-datos/main/gbif/primates-cr-registros.csv",
    options = c(
      "X_POSSIBLE_NAMES=decimalLongitude",
      "Y_POSSIBLE_NAMES=decimalLatitude"
    )
  )

#Carga de la capa de cantones

cantones <-
  st_read(
    "https://raw.githubusercontent.com/gf0604-procesamientodatosgeograficos/2021i-datos/main/ign/delimitacion-territorial-administrativa/cr_cantones_simp_wgs84.geojson",
    quiet = TRUE
  )

# Carga de la capa de provincias 
provincias <-
  st_read(
    "https://raw.githubusercontent.com/gf0604-procesamientodatosgeograficos/2021i-datos/main/ign/delimitacion-territorial-administrativa/cr_provincias_simp_wgs84.geojson",
  )

# Le damos el sisteam de coordenadas
st_crs(cantones) = 4326
st_crs(primates) = 4326

# Cruce espacial con la tabla de cantones, para obtener el nombre del cantón
primates <- 
  primates %>%
  st_join(cantones["canton"])

# Tabla de registros de presencia
primates %>%
  st_drop_geometry() %>%
  select(family, species, ) %>%
  datatable(
    colnames = c("Provincia", "Cantón", "Localidad", "Fecha"),
    options = list(searchHighlight = TRUE)
  )
