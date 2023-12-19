library(stringr)

get_file_directory <- function(filepath) {
  dir_parts <- str_split(filepath, "/")[[1]]
  return(paste0(paste(dir_parts[-length(dir_parts)], collapse="/"), "/"))
}

get_file_name <- function(filepath) {
  split_path <- str_split(filepath, "/")[[1]]
  return(tail(split_path, 1))
}

get_color_space <- function(out_path) {
  split_path <- str_split(out_path, "/")[[1]]
  file_name <- tail(split_path, 1)
  split_name <- str_split(file_name, "[.]")[[1]]
  return(head(split_name, 1))
}


color_outpath <- function(inpath, transform) {
  out_dir <- get_file_directory(inpath)
  out_name <- str_split(transform, "to", simplify=TRUE)[1, 2] |> tolower() |> paste0(".tif")
  return(paste0(out_dir, out_name))
}

get_layer_name <- function(im_path) {
  layer <-  str_split(im_path, '.tif')[[1]] 
  return(layer[1])
}

texture_outpath <- function(inpath, window, statistic, layer) {
  out_file_dir <- get_file_directory(inpath)
  
  file_name_split <- str_split(get_file_name(inpath), "\\.", simplify = TRUE)
  out_file_name <- paste0(file_name_split[1, 1], "_", statistic, "_L", layer, "_W", window, ".tif")
  
  return(paste0(out_file_dir, out_file_name))
}

segmentation_outpath <- function(inpath, spatial_radius, spectral_radius, min_density) {
  file_name_split <- str_split(get_file_name(inpath), "\\.")
  base_name <- file_name_split[[1]][1]
  
  return(paste0(base_name, "_seg_", spatial_radius, "_", spectral_radius, "_", min_density, ".tif"))
}