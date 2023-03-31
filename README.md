# CIS_MRP

Local packages used:

cismrp:
[![R](https://github.com/ONSdigital/cismrp_PUBLIC/actions/workflows/r.yaml/badge.svg?branch=main)](https://github.com/ONSdigital/cismrp_PUBLIC/actions/workflows/r.yaml)
[![codecov](https://codecov.io/gh/ONSdigital/cismrp_PUBLIC/branch/main/graph/badge.svg?token=N70MPthEj1)](https://codecov.io/gh/ONSdigital/cismrp_PUBLIC)

gcptools:
[![R-CMD-check](https://github.com/ONSdigital/gcptools_PUBLIC/actions/workflows/r.yml/badge.svg)](https://github.com/ONSdigital/gcptools_PUBLIC/actions/workflows/r.yml)
[![codecov](https://codecov.io/gh/ONSdigital/gcptools_PUBLIC/branch/main/graph/badge.svg?token=bV6FD7PUSr)](https://codecov.io/gh/ONSdigital/gcptools_PUBLIC)

## Description

CIS_MRP is a repo containing the pipeline for the headline COVID-19 Prevalence model. This has been constructed as a main.R (or .ipynb) file which calls on functionalised code from other packages/repos. This Reproducible Analytical Pipeline (RAP) uses Multilevel Regression with Postsratification a bayesian estimation method. This pipeline is dependent on the `gcptools` and `cismrp` packages which have been developed by ONS. The links to public versions of these repo's can be found below. 

The pipeline has been set up to run on Google Cloud Platform (GCP). 

## Repo contents
  
  1. root (.)<br>
    1. `.github` GitHub templates and GitHub Workflows *(invisible in GCP)*<br>
    2. `configs_long/` Country configuration settings for normal running<br>
    3. `configs_short/` Country configuration settings for testing only<br>
    4. `.gitignore` File extensions to ignore when pushing to GitHub *(invisible in GCP)*<br>
    5. `.pre-commit-config.yaml` Pre-commit hook instruction file *(invisible in GCP)*<br>
    6. `METHODOLOGY.md` Document detailing the methodology used in this pipeline<br>
    7. `README.md` Important information about this package<br>
    8. `main.R` Main pipeline script in an executable file<br>
    9. `main.ipynb` Main pipline script in an annotated notebook<br>
    10. `main_config.yaml` Main configuration settings for the system<br>
    11. `qa_report_template.Rmd` R markdown template for the Quality Assurance Report<br>
    12. `style.css` Style template for the R markdown (used in conjunction with the qa_report_template.Rmd)
   
    
## Installation

### 1. Cloning the CIS_MRP_PUBLIC repo
 1. Use git clone button 
 2. Copy the repo address to your clipboard
 3. Paste the address into the user interface
 
### 2. Install devtools
 1. Open a console an run `install.packages(devtools)`

### 3. Install `cismrp` from the cismrp_PUBLIC repo
 1. run the following code: `devtools::install_github("ONSdigital/cismrp_PUBLIC")`

### 4. Install `gcptools` from the gcptools_PUBLIC repo
1.  run the following code `devtools::install_github("ONSdigital/gcptools_PUBLIC")

## Regular production

 1. Open main.ipynb in your google cloud notebook
 2. Ensure you are in the main branch and `git pull`
 3. Update main_config.yaml to use the latest dates and setting, press ctrl + s to save.
 4. Check <country>_config.yamls have the correct model settings, press ctrl + s to save.
 5. `Commit` your changes.
 6. Check your outputs, if the run has completed sucessfully `push` your commits.
 7. If you are no longer working in google cloud close your notebook


## Synthetic Data

Because not all users will have access to the internal systems, we have created dummy and synthetic data within the cismrp package [(read more about synthetic and dumy data here)](https://syntheticus.ai/guide-everything-you-need-to-know-about-synthetic-data#:~:text=Synthetic%20and%20dummy%20data%20are,typically%20create%20dummy%20data%20manually). This data can be called from the package by first installing the cismrp package into your environment, and then calling `cismrp::synthetic_` or `cismrp::dummy_` prefix infront of the name of the data object, e.g. `cismrp::dummy_config` for the dummy version of main config, or `cismrp::synthetic_prevalence_time_series` for the synthetic version of the final output. This data has been predominantly used for unit testing within the package, but it could also be useful for anyone looking to visualise what the data looks like at each of the processing stages. 
<br> **Disclaimer: Synthetic and dummy data is not real data, so should only be used for testing purposes.**

## Public Repositories
To improve transparency of how we produce our official statistics and to support future pandemic preparedness, we have cloned our active repositories and made them available to the public. We have removed the commit history for security purposes. 
- [cismrp_PUBLIC - the package](https://github.com/ONSdigital/cismrp_PUBLIC)
- [CIS_MRP_PUBLIC - the pipeline](https://github.com/ONSdigital/CIS_MRP_PUBLIC)
- [gcptools_PUBLIC - an additional support package](https://github.com/ONSdigital/gcptools_PUBLIC)

## Further Reading

 1. Methodology for the pipeline - `METHODOLOGY.md`
 2. Most recent changes to the pipeline - `CHANGELOG.md`

