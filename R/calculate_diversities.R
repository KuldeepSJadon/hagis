
#' Calculate Diversities Indices
#'
#' @description Calculates _Phytophthora_ diversity index
#' @inheritParams summarize_rps
#' @examples
#' # locate system file for import
#' Ps <- system.file("extdata", "practice_data_set.csv", package = "hagis")
#'
#' # import 'practice_data_set.csv'
#' Ps <- read.csv(Ps)
#' head(Ps)
#'
#' # calculate susceptibilities with a 60 % cutoff value
#' diversities <- calculate_diversities(x = Ps,
#'                                      cutoff = 60,
#'                                      control = "susceptible",
#'                                      sample = "Isolate",
#'                                      Rps = "Rps",
#'                                      perc_susc = "perc.susc")
#' 
#' diversities
#' 
#' @export calculate_diversities

calculate_diversities <- function(x,
                                  cutoff,
                                  control,
                                  sample,
                                  Rps,
                                  perc_susc) {
  
  # check inptuts and rename fields to work with this package
  x <- .check_inputs(
    .x = x,
    .cutoff = cutoff,
    .control = control,
    .sample = sample,
    .Rps = Rps,
    .perc_susc = perc_susc
  )
  
  # CRAN NOTE avoidance
  Pathotype <- Frequency <- susceptible.1 <- NULL
  
  # The susceptible control is removed from all samples in the data set so that
  #  it will not affect complexity calculations and a new data set is made that
  #  it does not contain susceptible controls.
  x <- subset(x, Rps != control)

  # summarise the reactions, create susceptible.1 field, see
  # internal_functions.R
  x <- .binary_cutoff(.x = x, .cutoff = cutoff)

  # remove resistant reactions from the data set, leaving only susceptible
  # reactions (pathotype)
  x <- subset(x, susceptible.1 != 0)

  # split the data frame by sample and Rps
  y <- vapply(split(x[, Rps],
                    x[, sample]),
              toString, character(1))
  
  individual_pathotypes <- data.table::setDT(data.frame(
    Sample = as.numeric(names(y)),
    Pathotype = unname(y),
    stringsAsFactors = FALSE
  ))
  
  table_of_pathotypes <- data.table::as.data.table(
    table(individual_pathotypes$Pathotype))
  data.table::setnames(table_of_pathotypes, c("Pathotype", "Frequency"))
  data.table::setcolorder(table_of_pathotypes, c("Frequency", "Pathotype"))
  
  # determines the number of samples within the data
  N_samples <- length(unique(x[, sample]))
  
  # Determines the number of unique pathotypes for this analysis
  N_pathotypes <- length(unique(individual_pathotypes[, Pathotype]))
  
  # indices --------------------------------------------------------------------
  # simple diversity will show the proportion of unique pathotypes to total
  # samples. As the values gets closer to 1, there is greater diversity in
  # pathoypes within the population.
  Simple <- N_pathotypes / N_samples
  
  # An alternate version of Simple diversity index. This index is less
  # sensitive to sample size than the simple index.
  Gleason <- (N_pathotypes - 1) / log(N_samples)
  
  # Shannon diversity index is typically between 1.5 and 3.5. As richness and
  # evenness of the population increase, so does the Shannon index value
  Shannon <-
    vegan::diversity(table_of_pathotypes[, Frequency], index = "shannon")
  
  # Simpson diversity index values range from 0 to 1. 1 represents high
  # diversity and 0 represents no diversity.
  Simpson <-
    vegan::diversity(table_of_pathotypes[, Frequency], index = "simpson")
  
  # Evenness ranges from 0 to 1. As the Eveness value approaches 1, there is a
  # more even distribution of each pathoypes frequency within the population.
  Evenness <- Shannon / log(N_pathotypes)
  
  z <-
    list(
      individual_pathotypes = individual_pathotypes,
      table_of_pathotypes = table_of_pathotypes,
      number_of_samples = N_samples,
      number_of_pathotypes = N_pathotypes,
      Simple = Simple,
      Gleason = Gleason,
      Shannon = Shannon,
      Simpson = Simpson,
      Evenness = Evenness
    )
  
  # Set new class
  class(z) <- union("hagis.diversities", class(z))
  return(z)
}

#' Prints hagis.diversities Object
#'
#' Custom [print()] method for `hagis.diversities` objects.
#'
#' @param x a hagis.diversities object
#' @param ... ignored
#' @export
#' @noRd
print.hagis.diversities <- function(x,
                                    digits = max(3L, getOption("digits") - 3L),
                                    ...) {
  cat("\nhagis Diversities\n")
  cat("\nNumber of Samples", x[[3]])
  cat("\nNumber of Pathotypes", x[[4]], "\n")
  cat("\n")
  cat("Indices\n")
  cat("Simple  ",  x[[5]], "\n")
  cat("Gleason ",  x[[6]], "\n")
  cat("Shannon ",  x[[7]], "\n")
  cat("Simpson ",  x[[8]], "\n")
  cat("Evenness ",  x[[9]], "\n")
  cat("\n")
  invisible(x)
}

#' Prints Table of Diversities
#' 
#' Print the frequency table of diversities from a `hagis.diversities` object
#' The resulting object is a [pander] table (a text object for Markdown) for
#' ease of use in reporting and viewing in the console.
#' 
#' @param x a hagis.diversities object generated by [calculate_diversities()]
#' @param ... other arguments passed to [pander::panderOptions()]
#' 
#' @examples 
#' # locate system file for import
#' Ps <- system.file("extdata", "practice_data_set.csv", package = "hagis")
#'
#' # import 'practice_data_set.csv'
#' Ps <- read.csv(Ps)
#' head(Ps)
#'
#' # calculate susceptibilities with a 60 % cutoff value
#' diversities <- calculate_diversities(x = Ps,
#'                                      cutoff = 60,
#'                                      control = "susceptible",
#'                                      sample = "Isolate",
#'                                      Rps = "Rps",
#'                                      perc_susc = "perc.susc")
#' 
#' # print the diversities table
#' diversities_table(diversities)
#' 
#' @return A [pander][pandoc.table] object of diversities
#' @seealso [calculate_diversities()], [individual_pathotypes()]
#' @export
diversities_table <- function(x,...) {
  if (class(x)[1] != "hagis.diversities") {
    stop(call. = FALSE,
         "This is not a hagis.diversities object.") 
  } else {
      pander::pander(x[[2]], ...)
  }
}

#' Prints Individual Pathotypes for Each Sample
#' 
#' Print an object from a `hagis.diversities` object with individual pathotypes,
#' _i.e._ each sample's pathotype. #' The resulting object is a [pander] table
#' (a text object for Markdown) for ease of use in reporting and viewing in the
#' console.
#' 
#' @inheritParams diversities_table
#' @examples 
#' # locate system file for import
#' Ps <- system.file("extdata", "practice_data_set.csv", package = "hagis")
#'
#' # import 'practice_data_set.csv'
#' Ps <- read.csv(Ps)
#' head(Ps)
#'
#' # calculate susceptibilities with a 60 % cutoff value
#' diversities <- calculate_diversities(x = Ps,
#'                                      cutoff = 60,
#'                                      control = "susceptible",
#'                                      sample = "Isolate",
#'                                      Rps = "Rps",
#'                                      perc_susc = "perc.susc")
#' 
#' # print the diversities table
#' individual_pathotypes(diversities)
#' 
#' @return A [pander][pander] object of individual pathotypes
#' @seealso [calculate_diversities()], [diversities_table()]
#' @export
individual_pathotypes <- function(x, ...) {
  if (class(x)[1] != "hagis.diversities") {
    stop(call. = FALSE,
         "This is not a hagis.diversities object.") 
  } else
  {
    pander::pander(x[[1]], ...)
  }
}


#' Pander Method for hagis diversities
#'
#' Prints a hagis diversities in Pandoc's markdown.
#' @param x a diversities object
#' @param caption caption (string) to be shown under the table
#' @param ... optional parameters passed to raw \code{pandoc.table} function
#' @importFrom pander pander
#' @export
#' @noRd
pander.hagis.diversities <-
  function(x, caption = attr(x, "caption"), ...) {
    pander::pander(
      data.frame(
        "Simple" = x$Simple,
        "Gleason" = x$Gleason,
        "Shannon" = x$Shannon,
        "Simpson" = x$Simpson,
        "Evenness" = x$Evenness
      ),
      caption = paste0(
        "Diversity indices where n = ",
        x$number_of_samples,
        " with ",
        x$number_of_pathotypes,
        " pathotypes."
      )
    )
  }
