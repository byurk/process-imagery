library(reticulate)

Sys.setenv(
  RETICULATE_PYTHON = '/usr/bin/python3'
)

source_python("src/segment.py")

#' Parallel Image Segmentation Function
#'
#' This function performs image segmentation on multiple images in parallel. It interfaces with a Python script for the segmentation algorithm.
#' The function can conditionally execute based on 'do_computation' and controls whether to overwrite existing files with the 'over_write' parameter.
#' It sets the Python environment for the reticulate package and then sources a Python script for segmentation.
#'
#' @param inpaths A vector of strings, each representing a file path for an image to be segmented.
#' @param spatial_radii A vector of integers specifying the spatial radii for segmentation corresponding to each image in 'inpaths'.
#' @param range_radii A vector of integers specifying the range radii for segmentation corresponding to each image in 'inpaths'.
#' @param min_densities A vector of integers specifying the minimum densities for segmentation corresponding to each image in 'inpaths'.
#' @param do_computation Logical; if TRUE, the function performs segmentation for each image. Defaults to FALSE.
#' @param over_write Logical; if TRUE, existing files will be overwritten by the segmentation results. Defaults to FALSE.
#' @param python_environment_path A string specifying the file path to the Python environment to be used. Defaults to "/usr/bin/python3".
#' @return A vector containing the file paths where the results of the image segmentations are written.
#' @examples
#' # Example usage of parallel_image_segmentation
#' file_paths <- c("path/to/image1.jpg", "path/to/image2.jpg")
#' spatial_radii <- c(10, 15)
#' range_radii <- c(20, 25)
#' min_densities <- c(5, 10)
#'
#' results <- parallel_image_segmentation(file_paths, spatial_radii, range_radii, min_densities, do_computation = TRUE, over_write = FALSE)
#'
#' @export
parallel_image_segmentation <- function(inpaths, spatial_radii, range_radii, min_densities, do_computation = FALSE, over_write = FALSE, python_environment_path = "/usr/bin/python3"){
  
  #Need to set the environment here because in multidplyr the environment is not copied between clusters
  Sys.setenv(RETICULATE_PYTHON = python_environment_path)
  source_python("src/segment.py")
  
  do_computation_vector <- rep(do_computation, length(inpaths))
  
  if (!over_write & do_computation) {
    do_computation_vector <-
      list(inpaths, spatial_radii, range_radii, min_densities) |>
      pmap(.f = segmentation_outpath) |>
      unlist() |>
      file.exists() |>
      Negate(identity)
  }
  args <-
    list(inpaths,
         spatial_radii,
         range_radii,
         min_densities,
         do_computation_vector)
  args |>
    pmap(.f = segment) |>
    unlist()
}
