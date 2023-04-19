#!/usr/local/bin/Rscript

# This Rscript will download DNR data for Rx burn requests within Okanogan
# County. This is part of the USFS AirFire coding-challenge.

# ===== Internal Functions =====================================================

# Modified from: https://github.com/ropensci/geojson/blob/master/R/geo_write.R
my_geo_write <- function(x, file) {

  # # Original code:
  # geo_write.geojson <- function(x, file) {
  #   if (inherits(file, "file")) on.exit(close(file))
  #   cat(
  #     jsonlite::toJSON(jsonlite::fromJSON(x), pretty = TRUE, auto_unbox = TRUE),
  #     "\n",
  #     file = file
  #   )
  # }

  # NOTE:  According to the function signature for jsonline::toJSON(), it should
  # NOTE:  use "na = 'null'" by default but it also says that "defaults are class
  # NOTE:  specific". Here we specify what we want to retain NA values

  if (inherits(file, "file")) on.exit(close(file))

  cat(
    jsonlite::toJSON(
      jsonlite::fromJSON(x),
      pretty = TRUE,
      na = 'null',            # <-- Recode NA as 'null' (don't just drop them)
      auto_unbox = TRUE
    ),
    "\n",
    file = file
  )

}

# ===== END Internal Functions =================================================

# first pass . ---- . ----
VERSION <- "1.0.0"

# Start timer
ptm <- proc.time()

# Load these packages now so that version information appears in the logs.
suppressPackageStartupMessages({
  library(geojsonio)
  library(optparse)
  # MazamaScience packages
  library(MazamaCoreUtils)
})

# ----- Get command line arguments ---------------------------------------------

if ( interactive() ) {

  # Desktop
  opt <- list(
    outputBaseDir = "./test",
    version = FALSE
  )

} else {

  # Set up OptionParser
  option_list <- list(
    make_option(
      c("-o", "--outputBaseDir"),
      default = getwd(),
      help = "Base directory for output files' [default = \"%default\"]"
    ),
    make_option(
      c("-V", "--version"),
      action = "store_true",
      default = FALSE,
      help = "Print out version number [default = \"%default\"]"
    )
  )

  # Parse arguments
  opt <- parse_args(OptionParser(option_list = option_list))

}

# Print out version and quit
if ( opt$version ) {
  message(paste0("DNR_burnportal_exec.R ", VERSION, "\n"))
  quit()
}


# ----- Validate parameters ----------------------------------------------------

if ( !dir.exists(opt$outputBaseDir) )
  stop(paste0("outputBaseDir not found:  ", opt$outputBaseDir))

outputBaseDir <- opt$outputBaseDir

# Create necessary output directories
dataDir <- file.path(outputBaseDir, "data/DNR")
logDir <- file.path(outputBaseDir, "logs")

dir.create(dataDir, showWarnings = FALSE, recursive = TRUE)
dir.create(logDir, showWarnings = FALSE, recursive = TRUE)


# ----- Set up logging ---------------------------------------------------------

# Set up logging
logger.setup(
  traceLog = file.path(logDir, "DNR_burnportal_TRACE.log"),
  debugLog = file.path(logDir, "DNR_burnportal_DEBUG.log"),
  infoLog  = file.path(logDir, "DNR_burnportal_INFO.log"),
  errorLog = file.path(logDir, "DNR_burnportal_ERROR.log")
)

if ( interactive() )
  logger.setLevel(TRACE)

# For use at the very end
errorLog <- file.path(logDir, "DNR_burnportal_ERROR.log")

# Silence other warning messages
options(warn = -1) # -1=ignore, 0=save/print, 1=print, 2=error

# Start logging
logger.info("Running DNR_burnportal_exec.R version %s",VERSION)
sessionString <- paste(capture.output(sessionInfo()), collapse = "\n")
logger.debug("R session:\n\n%s\n", sessionString)

optString <- paste(capture.output(str(opt)), collapse = "\n")
logger.debug("Command line options:\n\n%s\n", optString)


# ----- Create DNR data --------------------------------------------------------

logger.info("Getting BurnRequests ...")

result <- try({

  burnRequestsUrl <- "https://api.burnportal.dnr.wa.gov/api/v1/BurnRequests/Search?CountyId=25" # 25 = Okanogan

  rawDF <-
    jsonlite::fromJSON(
      txt = burnRequestsUrl,
      simplifyVector = TRUE,
      simplifyDataFrame = TRUE,
      simplifyMatrix = TRUE,
      flatten = FALSE
    )

  # Fix data types
  timezone <- "America/Los_Angeles"
  burnRequests <-
    rawDF %>%
    # Assign types
    dplyr::mutate(
      BurnRequestId = as.character(.data$BurnRequestId),
      BurnPermitId = as.character(.data$BurnPermitId),
      BurnRequestDate = MazamaCoreUtils::parseDatetime(.data$BurnRequestDate, timezone),
      BurnPermitExpirationDate = MazamaCoreUtils::parseDatetime(.data$BurnPermitExpirationDate, timezone),
      PlannedIgnitionDate = MazamaCoreUtils::parseDatetime(.data$PlannedIgnitionDate, timezone),
      BurnRequestStatusDate = MazamaCoreUtils::parseDatetime(.data$BurnRequestStatusDate, timezone),
      PostBurnDate = MazamaCoreUtils::parseDatetime(.data$PostBurnDate, timezone)
    )

}, silent = TRUE)

# Handle errors
if ( "try-error" %in% class(result) ) {
  msg <- paste("Error loading monitor data: ", geterrmessage())
  logger.fatal(msg)
  stop(msg)
}


# ----- Save files -------------------------------------------------------------

logger.info("Saving files ...")

result <- try({

  # File names and paths
  burnRequestsPath <- file.path(dataDir, "burnRequests.rda")
  burnRequestsPath_csv <- burnRequestsPath %>% stringr::str_replace("\\.rda", "\\.csv")

  # .rda version
  save(burnRequests, file = burnRequestsPath)

  # .csv version
  readr::write_csv(burnRequests, file = burnRequestsPath_csv)

}, silent = TRUE)

# Handle errors
if ( "try-error" %in% class(result) ) {
  msg <- paste("Error saving updated files: ", geterrmessage())
  logger.fatal(msg)
  stop(msg)
}


# ----- Create/Save geojson ----------------------------------------------------

logger.info("Creating/saving geojson ...")

# > dplyr::glimpse(burnRequests, width = 75)
# Rows: 1,000
# Columns: 47
# $ BurnRequestId             <chr> "19986", "20011", "19985", "20010", "19…
# $ BurnPermitId              <int> 21793, 21574, 21571, 21571, 21027, 2055…
# $ BurnPermitNumber          <chr> "NE20230102", "NE20230045", "NE20230042…
# $ TotalPermitTonnage        <dbl> 21.18, 381.23, 30.00, 30.00, 35.78, 138…
# $ MultiDayBurn              <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALS…
# $ BurnPriority              <int> 1, 1, 1, 1, NA, NA, 1, NA, 600, 193, 1,…
# $ Agent                     <chr> "", "", "", "", "", "", "", "", "", "",…
# $ Landowner                 <chr> "", "", "", "", "", "", "", "", "", "",…
# $ Agency                    <chr> "Okanogan Wenatchee National Forest", "…
# $ BurnRequestDate           <dttm> 2023-03-27 00:00:00, 2023-04-03 00:00:…
# $ BurnPermitExpirationDate  <dttm> 2024-03-27 12:46:20, 2024-02-09 11:52:…
# $ PlannedIgnitionDate       <dttm> 2023-03-30, 2023-04-06, 2023-03-29, 20…
# $ PlannedIgnitionTime       <chr> "10:00:00", "10:00:00", "10:00:00", "10…
# $ PlannedIgnitionPeriod     <int> 360, 360, 360, 360, 120, 360, 360, 240,…
# $ SmokeDispersedFlag        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
# $ TotalProposedBurnQuantity <dbl> 21.00, 10.00, 30.00, 20.00, 35.70, 500.…
# $ ProposedBurnArea          <dbl> 5, 5, 5, 5, 4, 200, 150, 0, 300, 100, 1…
# $ LegalDescQ1               <chr> "None", "None", "None", "None", "NE", "…
# $ LegalDescQ2               <chr> "None", "None", "None", "None", "SE", "…
# $ LegalDescSection          <int> 19, 3, 19, 19, 9, 1, 1, 1, 16, 16, 16, …
# $ LegalDescTownship         <int> 37, 34, 34, 34, 36, 33, 33, 33, 36, 36,…
# $ LegalDescRange            <int> 22, 21, 19, 19, 26, 23, 23, 23, 33, 33,…
# $ LegalDescDirection        <chr> "East", "East", "East", "East", "East",…
# $ Address1                  <chr> "24 West Chewuch", "24 W Chewuch", "24 …
# $ Address2                  <chr> "", "", "", "", "", NA, NA, NA, "", "",…
# $ Address3                  <chr> "", NA, NA, NA, NA, NA, NA, NA, "", "",…
# $ AddressCity               <chr> "Winthrop", "Winthrop", "Winthrop", "Wi…
# $ AddressState              <chr> "WA", "WA", "WA", "WA", "WA", NA, NA, N…
# $ AddressZip                <chr> "98862", "98862", "98862", "98862", "98…
# $ County                    <chr> "Okanogan", "Okanogan", "Okanogan", "Ok…
# $ Region                    <chr> "Northeast", "Northeast", "Northeast", …
# $ BurnRequestStatus         <chr> "Submitted", "Approved", "Submitted", "…
# $ BurnRequestStatusDate     <dttm> 2023-03-27 12:48:01, 2023-04-03 12:42:…
# $ BurnType                  <chr> "Pile", "Pile", "Pile", "Pile", "Pile",…
# $ Longitude                 <dbl> -120.1294, -120.2568, -120.5248, -120.5…
# $ Latitude                  <dbl> 48.68993, 48.59873, 48.43323, 48.43323,…
# $ BurnAcres                 <dbl> 10, 86, 5, 5, 15, 450, 450, 450, 396, 3…
# $ BurnUnitName              <chr> "Chewuch Piles 2021", "Buck", "Twisp Ri…
# $ HasPostBurn               <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRU…
# $ IsUGA                     <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALS…
# $ IsForestHealthExempt      <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
# $ PostBurnDate              <dttm> 2023-03-30, 2023-04-07, 2023-03-29, 20…
# $ PostBurnTonnage           <dbl> 21.18, 0.00, 0.00, 0.00, 35.78, 138.57,…
# $ PostBurnArea              <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
# $ HUC                       <chr> "1702000804", "1702000804", "1702000805…
# $ polygonName               <chr> "Lower Chewuch River", "Lower Chewuch R…

# NOTE:  Ignore: "Registered S3 method overwritten by 'geojsonlint':"
suppressMessages({

  geojsonObject <-

    burnRequests %>%

    # Choose fields to include
    dplyr::select(c(
      "Longitude",
      "Latitude",
      "BurnPermitId",
      "TotalPermitTonnage",
      "BurnType",
      "BurnUnitName",
      "BurnAcres",
      "BurnRequestStatus",
      "Agency",
      "PlannedIgnitionDate",
      "TotalProposedBurnQuantity",
      "ProposedBurnArea",
    )) %>%

    # TODO:  Rename current status columns here if needed

    # Create geojson string
    geojsonio::geojson_json(
      lat = "Latitude",
      lon = "Longitude",
      group = NULL,
      geometry = "point",
      type = "FeatureCollection",
      convert_wgs84 = FALSE,
      crs = NULL,
      precision = 5,
      null = "null",
      na = "null"
    )

})

# File names and paths
geojsonPath <- file.path(dataDir, "burnRequests.geojson")

logger.trace("Saving geojson file: %s", geojsonPath)
my_geo_write(geojsonObject, geojsonPath)

# ----- Finish -----------------------------------------------------------------

logger.info("Completed successfully!")
ptm <- proc.time()
logger.info("User: %.0f, System: %.0f, Elapsed: %.0f seconds", ptm[1], ptm[2], ptm[3])

# ===== END ====================================================================
