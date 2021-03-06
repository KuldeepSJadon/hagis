% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_diversities.R
\name{individual_pathotypes}
\alias{individual_pathotypes}
\title{Prints Individual Pathotypes for Each Sample}
\usage{
individual_pathotypes(x, ...)
}
\arguments{
\item{x}{a hagis.diversities object generated by \code{\link[=calculate_diversities]{calculate_diversities()}}}

\item{...}{other arguments passed to \code{\link[pander:panderOptions]{pander::panderOptions()}}}
}
\value{
A \link{pander} object of individual pathotypes
}
\description{
Print an object from a \code{hagis.diversities} object with individual pathotypes,
\emph{i.e.} each sample's pathotype. #' The resulting object is a \link{pander} table
(a text object for Markdown) for ease of use in reporting and viewing in the
console.
}
\examples{
# locate system file for import
Ps <- system.file("extdata", "practice_data_set.csv", package = "hagis")

# import 'practice_data_set.csv'
Ps <- read.csv(Ps)
head(Ps)

# calculate susceptibilities with a 60 \% cutoff value
diversities <- calculate_diversities(x = Ps,
                                     cutoff = 60,
                                     control = "susceptible",
                                     sample = "Isolate",
                                     Rps = "Rps",
                                     perc_susc = "perc.susc")

# print the diversities table
individual_pathotypes(diversities)

}
\seealso{
\code{\link[=calculate_diversities]{calculate_diversities()}}, \code{\link[=diversities_table]{diversities_table()}}
}
