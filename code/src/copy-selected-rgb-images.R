# Copy selected 1 of 3 RGB images from raw_data to clean_data for feature engineering

library(tidyverse)
library(glue)
library(terra)

in_directory <- 'raw_data/quadrats'
out_directory <- 'clean_data/quadrats'
csv_path <-  "clean_data/selected_image_key.csv"


selected_images <- read_csv(csv_path) |>
  mutate(quadrat_number = row_number() + 33) |>
  mutate(selected_image_path = glue('{in_directory}/quadrat{quadrat_number}/image_selection/{content}')) |>
  mutate(out_directory = glue('{out_directory}/quadrat{quadrat_number}'))


in_paths <- selected_images |>
  pluck('selected_image_path')

out_directories <- selected_images |> 
  pluck('out_directory')


result <-  map2(in_paths, out_directories, \(x,y){ 
  dir.create(y, showWarnings = FALSE, recursive = TRUE)
  file.copy(from = x, to = glue('{y}/rgb.tif'), overwrite = FALSE)
  })

result
