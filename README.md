# Process photographs

Generic repository to pre-process photographs used in  machine learning tasks.

Main entry points:

### 1. exploration.qmd

There are 3 main processes used to create feature images. 
  
  - Meanshift image segmentation
  - Color space transformations
  - Texture calculations with the Gray Level Co-Occurrence Matrix
  

This Quarto document shows examples of what different color space transformations, segmented images, and texture measurements look like on a single photograph.


### 2. process-imagery.qmd

Depending on the setup, many features may need to be generated from numerous photographs. By defining the paths to all images and parameter configurations for according feature types all layers can be generated at once. The code provided allows for dry runs and checking if a feature is already generated.