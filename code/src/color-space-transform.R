library(raster)
library(terra)
library(tidyverse)
library(magick)
library(imager)
source("code/src/file-utilities.R")

#' Color Transforms Function
#'
#' This function applies color transformations to a set of image paths.
#' It allows for conditional computation and overwriting of existing files.
#' Define custom color space transforms here (transformations not in the imager package)
# 'color_transform takes function names from imager package
# '"RGBtoHSV" "RGBtoLab" "RGBtoHSL" "RGBtoHSI" "RGBtoYCbCr" "RGBtoYUV"

#'
#' @param inpath A string representing the file path of the image to be transformed.
#' @param transforms A vector of strings representing the color transformations to be applied.
#' @param do_computation A boolean value; if TRUE, computation is performed. If FALSE, computation is skipped. Defaults to FALSE.
#' @param over_write A boolean value; if TRUE, existing files will be overwritten. If FALSE, existing files are preserved. Defaults to FALSE.
#' @return A vector of the results of the color transformations, dependent on the conditions specified by do_computation and over_write.
#' @examples
#' # Example usage of color_transforms_function
#' # Define file paths and transformations
#' file_paths <- c("path/to/image1.jpg", "path/to/image2.jpg")
#' transformations <- c("transformation1", "transformation2")
#'
#' # Apply color transformations without overwriting existing files
#' color_transforms_function(file_paths, transformations, do_computation = TRUE, over_write = FALSE)
#'
#' @export
color_transform <- function(inpath, transform = "RGBtoHSV", do_computation = TRUE) {
  tryCatch({
    # Get Path to Write
    out_path <- color_outpath(inpath, transform)
    color_space <- get_color_space(out_path)
    
    if(!file.exists(inpath)) { 
      stop(paste0(inpath, " does not exist")) 
    }
    
    if (do_computation) {
      # read in image with imager
      image <- inpath |>
        magick::image_read() |>
        imager::magick2cimg()
      
      # get transform from environment
      color_transform <- transform |>
        get()
      
      # do transform and normalize variables
      rast <- image |>
        color_transform() |>
        drop() |>
        as.array() |>
        terra::rast() |>
        terra::t() |>
        terra::stretch()
      
      names(rast) <- paste0(color_space, "_", seq(terra::nlyr(rast)))
      
      rast[is.na(rast)] <- 254
      rast[is.nan(rast)] <- 254
      rast[rast == 255] <- 254
      NAflag(rast) <- 255
      
      terra::writeRaster(
        x = rast,
        filename = out_path,
        datatype = "INT1U",
        overwrite = TRUE
      )
      
      rm(rast)
    }
    return(list(outpath = out_path, error = NA_character_)) # No error
  }, error = function(e) {
    return(list(outpath = out_path, error = e$message))
  })
}

#' Parallel Color Transforms Function
#'
#' This function applies color transformations to a set of image paths in parallel. 
#' It allows for conditional computation based on the 'do_computation' parameter and 
#' controls file overwriting with the 'over_write' parameter. If 'do_computation' is set to TRUE,
#' the function computes the color transformations. If 'over_write' is set to FALSE, 
#' it checks for existing files and prevents overwriting.
#'
#' @param inpaths A vector of strings representing the file paths of the images to be transformed.
#' @param transforms A vector of strings representing the color transformations to be applied.
#' @param do_computation Logical; if TRUE, the function performs the computation 
#'                      of color transformations. Defaults to FALSE.
#' @param over_write Logical; if TRUE, the function will overwrite any existing files 
#'                  with the same name as the output files. Defaults to FALSE.
#' @return A vector containing the results of the color transformations, dependent 
#'         on the conditions specified by 'do_computation' and 'over_write'.
#' @examples
#' # Example usage of parallel_color_transforms
#' file_paths <- c("path/to/image1.jpg", "path/to/image2.jpg")
#' transformations <- c("transformation1", "transformation2")
#'
#' # Apply color transformations in parallel without overwriting existing files
#' results <- parallel_color_transforms(file_paths, transformations, 
#'                                     do_computation = TRUE, over_write = FALSE)
#'
#' @export
parallel_color_transforms <- function(inpaths, transforms, do_computation = FALSE, over_write = FALSE){
  
  do_computation_vector <- rep(do_computation, length(inpaths))
  
  if (!over_write & do_computation) {
    out_paths <- list(inpaths, transforms) |>
      pmap(.f = color_outpath) |>
      unlist()
    
    do_computation_vector <- !file.exists(out_paths)
  }
  
  args <- list(inpaths, transforms, do_computation_vector)
  
  results <- args |>
    pmap(.f = function(inpath, transform, do_computation) {
      result <- color_transform(inpath, transform, do_computation)
      return(result)
    })
  
  return(results)
}
