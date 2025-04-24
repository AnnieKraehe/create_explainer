# Automatically write an explainer.txt file in the last used output folder

# Try to detect script path
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- tryCatch(
    rstudioapi::getActiveDocumentContext()$path,
    error = function(e) NA
  )
} else {
  script_path <- NA
}

script_name <- if (!is.na(script_path) && nzchar(script_path)) {
  basename(script_path)
} else {
  "Unknown (script path not available outside RStudio)"
}

# Look for a variable named plot_path or output_dir
output_dir <- tryCatch({
  if (exists("plot_path")) {
    dirname(get("plot_path", envir = .GlobalEnv))
  } else if (exists("output_dir")) {
    get("output_dir", envir = .GlobalEnv)
  } else {
    stop("No plot_path or output_dir found in the global environment.")
  }
}, error = function(e) {
  warning("Explainer not written: ", e$message)
  return(NULL)
})

if (!is.null(output_dir)) {
  explainer_text <- c(
    paste("These files were generated using", R.version.string),
    paste("Date run:", Sys.Date()),
    paste("Script title:", script_name),
    paste("Script location:", if (!is.na(script_path)) script_path else "Not available (non-RStudio environment)"),
    "Packages used:",
    paste(
      sapply(.packages(), function(pkg) {
        version <- as.character(packageVersion(pkg))
        paste0("  - ", pkg, ": ", version)
      }),
      collapse = "\n"
    )
  )
  
  writeLines(explainer_text, con = file.path(output_dir, "explainer.txt"))
}
