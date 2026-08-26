# Data Access Instructions

The NFHS-5 (National Family Health Survey, Round 5, 2019–21) KR (Children's Recode) and PR (Household Members' Recode) files used in this analysis are **not included** in this repository, in line with DHS Program data-use terms.

## How to obtain the data

1. Register for access at the [DHS Program website](https://dhsprogram.com/data/dataset_admin/login_main.cfm) (free registration for research/academic use).
2. Request the **India: Standard DHS, 2019-21 (NFHS-5)** dataset.
3. Download the following recode files in Stata (`.dta`) format:
   - `KR` (Children's Recode)
   - `PR` (Household Members' Recode)
4. Place the downloaded `.dta` files in this `data/` folder.

## Preparing the files for the do file

The do file (`code/nfhs_malnutrition_anemia.do`) expects:
- A temporary KR file sorted by `hv001 hv002 hvidx` (cluster, household, child line number)
- The PR file merged onto it on the same keys

Update the file paths at the top of the do file to point to wherever you've saved the `.dta` files locally before running.

## Geographic scope

This analysis subsets the national file to three states using the `v024` state code:
- Uttar Pradesh: `v024 == 9`
- Bihar: `v024 == 10`
- West Bengal: `v024 == 19`

(State codes follow the NFHS-5 sampling frame; confirm against your specific recode file's value labels, as codes can shift slightly between rounds.)
