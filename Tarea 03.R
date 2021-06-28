# Carga de Paquetes 

library(dplyr)
library(sf)
library(DT)
library(plotly)
library(leaflet)
library(rgdal)
library(raster)

# Carga de los datos de primates 
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

# Suma de las especies para creación del gráfico de pastel más adelante
suma_especies <- primates %>% count(species)

# Tabla de registros de presencia de primates

primates %>%
  st_drop_geometry() %>%
  select(family, species, stateProvince, canton.y, eventDate) %>%
  datatable(
    colnames = c("Familia", "Especie", "Provincia", "Cantón", "Fecha"),
    options = list(searchHighlight = TRUE,
    language = list(url =
                      '//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json'),
    pageLength = 10))


# Grafico de pastel para datos de primates en Costa Rica 

# Se crea la data con el total de especies
data <- suma_especies[, c('species', 'n')]

# Creación del gráfico


fig <- plot_ly(data,
               labels = ~ species,
               values = ~ n,
               type = 'pie')
fig <-
  fig %>% config(locale = "es")%>%
  layout(
    title = 'Cantidad de registros de especies de primates en Costa Rica',
    xaxis = list(
      showgrid = FALSE,
      zeroline = FALSE,
      showticklabels = FALSE
    ),
    yaxis = list(
      showgrid = FALSE,
      zeroline = FALSE,
      showticklabels = FALSE
    )
  )
# Se utiliza el fig para la ejecución del gráfico

fig 


# Obtener datos del world clim para hacer el mapa con leaflet

alt <- getData(
  "worldclim",
  var = "alt",
  res = .5,
  lon = -84,
  lat = 10
)
altitud <- crop(alt, extent(-86, -82.3, 8, 11.3))
altitud <-
  alt %>%
  crop(provincias) %>%
  mask(provincias)
# Mapa con leaflet


# Mapa de registros de presencia
primates %>%
  select(
    family,
    species,
    stateProvince,
    canton.y,
    eventDate,
    decimalLongitude,
    decimalLatitude
  ) %>%
  leaflet() %>%
  addRasterImage(
    altitud,
    opacity = 0.8,
    col = brewer.pal(11, "RdBu"),
    group = "Altitud"
  ) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Stamen Toner Lite") %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Imágenes de ESRI") %>%
  addCircleMarkers(
    stroke = F,
    radius = 3,
    fillColor = '#154360',
    fillOpacity = 1,
    popup = paste(
      primates$stateProvince,
      primates$canton.y,
      primates$eventDate,
      primates$decimalLongitude,
      primates$decimalLatitude,
      sep = '<br/>'
    ),
    group = "primates"
  ) %>%
      addLayersControl(
        baseGroups = c("OpenStreetMap", "Stamen Toner Lite", "Imágenes de ESRI"),
        overlayGroups = c("primates", "Altitud")
      ) %>%
      addMiniMap(
        tiles = providers$Stamen.OpenStreetMap.Mapnik,
        position = "bottomleft",
        toggleDisplay = TRUE
      )
  


  
