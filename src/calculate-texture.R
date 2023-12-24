library(stringr)
library(terra)
library(GLCMTextures)
library(tictoc)
source("src/file-utilities.R")

#' Calculate Texture Function
#'
#' This function computes texture characteristics for a given raster image. It reads the image from the specified path, 
#' applies a texture analysis based on the specified statistical measure (e.g., GLCM contrast), and writes the result to an output path.
#' The function checks if the input file exists before performing computations and allows customization of the analysis window size, 
#' statistic method, and layer.
#'
#' @param inpath A string representing the file path of the raster image to be analyzed.
#' @param window An integer specifying the window size for the texture analysis. Defaults to 5.
#' @param statistic A string specifying the statistical method to be used for texture analysis. 
#'                  Possible values include 'glcm_contrast', 'glcm_dissimilarity', etc. Defaults to 'glcm_contrast'.
#' @param layer An integer indicating the layer of the raster to be analyzed. Defaults to 1L (first layer).
#' @param do_computation Logical; if TRUE, the function performs the texture analysis. Defaults to TRUE.
#' @return A string representing the file path where the texture analysis results are written.
#' @examples
#' # Example usage of calculate_texture
#' inpath <- "path/to/raster.tif"
#' result_path <- calculate_texture(inpath, window = 5, statistic = "glcm_contrast", layer = 1)
#'
#' @export
calculate_texture <- function(inpath, window = 5, statistic = "glcm_contrast", layer = 1L, do_computation = TRUE) {
  #Texture Path to Write
  out_path <- texture_outpath(inpath, window, statistic, layer)
  
  if (!file.exists(inpath)) {
    do_computation <- FALSE
    message(paste0(inpath, " does not exist"))
  }
  
  if (do_computation) {
    
    raster <-  inpath |>
      terra::rast(lyrs = layer)
    
    contrast <- glcm_textures(
      raster,
      metrics = statistic,
      w = c(window, window),
      n_levels = 16,
      shift = list(c(0, 1), c(1, 1), c(1, 0), c(1, -1)),
      quantization = "equal prob"
    )
    
    terra::writeRaster(filename = out_path,
                       format = "GTiff",
                       overwrite = TRUE)
  }
  return(out_path)
}

#' Parallel Texture Analysis Function
#'
#' This function performs texture analysis on multiple raster images in parallel. 
#' It allows for processing multiple images with different parameters for window size, 
#' statistical method, and layers. The function can conditionally perform computation based 
#' on the 'do_computation' parameter and controls file overwriting with the 'over_write' parameter.
#'
#' @param inpaths A vector of strings, where each string is a file path representing a raster image to be analyzed.
#' @param windows A vector of integers specifying the window sizes for each texture analysis corresponding to 'inpaths'.
#' @param statistics A vector of strings, where each string specifies the statistical method for texture analysis 
#'                   corresponding to each path in 'inpaths'. Possible values include 'glcm_contrast', 'glcm_dissimilarity', etc.
#' @param layers A vector of integers indicating the layers of the rasters to be analyzed, corresponding to 'inpaths'.
#' @param do_computation Logical; if TRUE, the function performs texture analysis for each input path. 
#'                      Defaults to FALSE.
#' @param over_write Logical; if TRUE, the function will overwrite any existing files with the same name 
#'                   as the output files. Defaults to FALSE.
#' @return A vector containing the file paths where the results of the texture analyses are written.
#' @examples
#' # Example usage of parallel_texture_
#' file_paths <- c("path/to/raster1.tif", "path/to/raster2.tif")
#' window_sizes <- c(5, 7)
#' statistics <- c("glcm_contrast", "glcm_dissimilarity")
#' layers <- c(1, 2)
#'
#' results <- parallel_texture_(file_paths, window_sizes, statistics, layers, do_computation = TRUE, over_write = FALSE)
#'
#' @export
parallel_texture_calculation <- function(inpaths, windows, statistics, layers, do_computation = FALSE, over_write = FALSE){
  do_computation_vector <- rep(do_computation, length(inpaths))
  
  if (!over_write & do_computation) {
    out_paths <- list(inpaths, windows, statistics, layers) |>
      pmap(.f = texture_outpath)  |>
      unlist() 
    
    do_computation_vector <- !file.exists(out_paths)
  }
  
  args <- list(inpaths, windows, statistics, layers, do_computation_vector)
  args |>
    pmap(.f = calculate_texture) |>
    unlist()
}

