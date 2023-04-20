# Python data processing scripts

_Updated April 20, 2023_

---

## load-wa-dnr-burns.py

This script loads burn requests planned for the current day from the Washington
state DNR database. It does nothing more than print out the resulting data.

To run it, install any recent version of python 3 (e.g. 3.10.5), and execute the
following in this directory:

    ./load-wa-dnr-burns.py

Don't expect it to work at first.

### Tasks

These tasks are intended to be done for the most part in order.

- Get the script working. It has a few bugs.
- Update it to write out the files to `output-data/dnr-burns.json`.
- Add a timestamp the output file with the planned burn date. e.g. `output-data/2023-05-10.json`
- add logging
- add script options to:
  - load burns for an alternate date.
  - filter out all but approved burns
  - add indentation to the JSON output
  - specify an alternate output file name
  - format the output data as GeoJSON instead of JSON (and change the output file extension appropriately)
  - format the output data as csv isntead of JSON (and change the output file extension appropriately)
  - set an alternate log level (assuming you've already added logging)
