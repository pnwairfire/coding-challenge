# Data Processing Scripts

_Updated April 19, 2023_

---

The `scripts/` directory contains data processing scripts associated
with the USFS AirFire Coding Challenge

# R scripts

## DNR_burnportal_exec.R

This script is designed to be run as a "standalone executable" but can also be
run directly from RStudio.

To run this script, load it into RStudio and set the working directory to
`coding-challenge/scripts/`. You can then run the script by clicking on the
"Source" button. Better would be to walk through the script, running a few lines
at a time.

Output from the script will be generated beneath the `test/` directory.

### Challenges

- Run DNR_burnportal_exec.R from inside RStudio.
- Run DNR burnport_exec.R from the command line, ensuring that data end up
  beneath `test/`.
- Review the sizes of data files generated.
  - How much bigger is the .csv file than the .rda file? Why?
  - How much bigger is the .geojson file than the .rda file? Why?
- Modify the code so that the .geojson file has short, unique identifiers rather
  than long, human-readable ones: _e.g._ change "TotalProposedBurnQuantity" to "tpbq".
  - How much does this reduce the size of the .geojson file?
- Modify the code to get data for Chelan county.
  (See <https://api.burnportal.dnr.wa.gov/api-docs/index.html> for county IDs.)
- Try to modify the code to remove the leading blank spaces from some of the
  fields in the .geojson file.


# Python scripts

You can find the python instructions [here](./python/README.md).
