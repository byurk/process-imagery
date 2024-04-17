# Process photographs

Generic repository to pre-process photographs used in machine learning tasks.

## Getting started

1.  Clone the github repository to your local machine.

``` bash
git clone git@github.com:byurk/process-imagery.git
```

2.  Open up the project by navigating inside the directory and click `image-processing.Rproj`.

3.  Install the `renv` package to manage the project dependencies.

``` r
install.packages("renv")
library(renv)
```

4.  Run the command `renv::init()` to install the project dependencies. If this is your first time setting up the project you will want to select option 1: Restore the project from the lockfile.

Done! Now you should be able to run the code in the project.

Python troubleshooting: If you are unable to create the python virtual environment due to privileges you can create the environment manually.

``` bash
python3 -m pip3 install --upgrade --user virtualenv
python3 -m virtualenv './renv/python/virtualenvs/renv-python-3.10'
```

Next, activate the virtual environment and install the dependencies.

``` bash
source ./renv/python/virtualenvs/renv-python-3.10/bin/activate
python3 -m pip install -r requirements.txt
```

or if you are using fish shell

``` bash
source ./renv/python/virtualenvs/renv-python-3.10/bin/activate.fish
pip3 install numpy
python3 -m pip install -r requirements.txt
```

Now restart your R session and the python environment should be detected.

## Project structure

The project is organized into the following directories:

1.  code - Contains the R and Python scripts used to process the images.

2.  raw_data - Contains the raw images and associated metadata.

3.  clean_data - Contains the processed images and associated metadata.

4.  outputs - Contains the output of the analysis used to take on future projects.

You should either create the raw_data, clean_data, and outputs directories and/or create symlinks to these directories (probably somewhere on google drive).

Currently the \*\_data and outputs folders are located at `epsilon.hope.edu:/media/DataSSD1/data/process-imagery/`. There is a corresponding [google drive folder](https://drive.google.com/drive/u/1/folders/1JjEJP3AFmPqS1FXrk8XQ5duAeXRuezp-).

## Workflow for processing the ground based images for the dune project at Saugatuck Harbor Natural Area (SHNA)

> **Yurk testing notes (April 2024)** - I did not test steps 1-4 since these are pretty specific to how we collected photographs for this flight - Typically we would need to have some process (usually simpler) that would result in one rgb image being added to each `clean_data/quadrats/quadrat##/` directory - Jack followed the steps 1-4 on epsilon to get the images ready for processing - I lightly modified the code to locate the selected_images_key.csv file in the `raw_data` directory instead of the `clean_data` directory. I also simplified the csv file so that it now has a column with the quadrat_number (using our current numbering system) and no longer has a column showing the path to the folder containing the images. This path was pointing at one of Jack's google drive folders, which is no longer used.

1.  The photos were captured with the Trimble iPhone app with associated GPS coordinates. For each quadrat \~3 photographs were taken to be used in subsequent analysis. This data is located in `raw_data/veg_Quadrats`.

2.  First run the script `code/src/organize-ground-images.R` to organize the raw data. This script will create a directory for each quadrat and store the associated photographs and metadata inside `raw_data`. These directories are stored in `raw_data/quadrats/` and are named `quadrat##` where `##` is the quadrat number. The script also converts each photograph to tiff format. The tiffs are stored in the directory `raw_data/quadrats/quadrat##/image_selection/`. Typically there are 3 photos of each quadrat, `iphone1.tif`, `iphone2.tif`, and `iphone3.tif`.

3.  Next, you will have to manually look at the photographs and decide which ones to use from each quadrat. Create a csv file with the decided photograph. This should be `iphone1`, `iphone2`,or `iphone3` for each quadrat. The csv file is stored in the `raw_data` directory: `raw_data/selected_images_key.csv`. The file lists the quadrat number and the file name of the selected image.

4.  Run the script `code/src/copy-selected-rgb-images.R` to copy the selected photographs to the `clean_data` directory. For example, the image selected for quadrat 79 will have the path `clean_data/quadrats/quadrat79/rgb.tif`

5.  Decide which hyperparameters to use for the image processing.

6.  Render the quarto document or run code cells of `code/process-imagery.qmd` to process the images.

Main entry points:

> **Yurk testing notes (April 2024)** - I rendered `code/exploration.qmd`. Everything seemed to work fine.

### 1. exploration.qmd

There are 3 main processes used to create feature images.

-   Meanshift image segmentation
-   Color space transformations
-   Texture calculations with the Gray Level Co-Occurrence Matrix

This Quarto document shows examples of what different color space transformations, segmented images, and texture measurements look like on a single photograph.

### 2. process-imagery.qmd

Depending on the setup, many features may need to be generated from numerous photographs. By defining the paths to all images and parameter configurations for according feature types all layers can be generated at once. The code provided allows for dry runs and checking if a feature is already generated.
