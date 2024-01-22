# Load necessary libraries
library(sf)
library(terra)

# Define the base path for the research data
base_path <- "./raw_data"

# Load the image key using the sf package
image_key <- st_read(dsn = paste0(base_path, "/veg_Quadrats/data-8"), layer = "l353766_Quadrat")

# Function to process each image using terra
process_image <- function(image_path, output_path) {
  if (!file.exists(output_path)) {
    image <- rast(image_path)
    terra::writeRaster(image, output_path, datatype = "INT1U", overwrite = TRUE, NAflag=NA)
  }
}


number_of_frames <- length(image_key$FrameNumbe)

# Iterate over each frame in the image key
for (frame_index in 1:number_of_frames) {
  #frame_index <- 1
  print(frame_index)
  
  # Split image data
  image_info <- strsplit(toString(image_key$Image[frame_index]), split = "|", fixed = TRUE)
  image_paths <- lapply(image_info[[1]], function(x) strsplit(x, split = "/", fixed = TRUE))
  
  # Construct file paths for each image
  frame_path <- paste0(base_path, "/quadrats/quadrat", image_key$FrameNumbe[frame_index])
  image_selection_path <- paste0(frame_path, "/image_selection")
  
  # Check and create directories if they don't exist
  if (!dir.exists(image_selection_path)) {
    dir.create(image_selection_path, recursive = TRUE)
  }
  
  # Process each image
  for (i in 1:length(image_paths)) {
    image_file_path <- paste0(base_path, "/veg_Quadrats/data-8/images/insphere/", image_paths[[i]][[1]][3])
    output_file <- paste0(image_selection_path, "/iphone", i, ".tif")
    process_image(image_file_path, output_file)
  }
}


