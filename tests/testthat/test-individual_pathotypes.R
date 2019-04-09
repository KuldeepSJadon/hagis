
# test diversities table -------------------------------------------------------
context("Test that individual_pathotypes() works as expected")

Ps <- system.file("extdata", "practice_data_set.csv", package = "hagis")
Ps <- read.csv(Ps)
diversities <- calculate_diversities(x = Ps,
                                     cutoff = 60,
                                     control = "susceptible",
                                     sample = "Isolate",
                                     Rps = "Rps",
                                     perc_susc = "perc.susc")

test_that("individual_pathotypes() returns a pander object", { 
  expect_type(
    capture.output(individual_pathotypes(x = diversities, type = "text")),
    "character")
})

test_that("invidual_pathotypes() returns a gridExtra object", { 
  expect_s3_class(
   individual_pathotypes(x = diversities, type = "graphic"),
    c("ggtable", "gTree", "grob", "gDesc"))
})

test_that("individual_pathotypes() stops if object is not hagis.diversities object",
          {expect_error(individual_pathotypes("y"),
                        regexp = "This is not a hagis.diversities object.")
          })