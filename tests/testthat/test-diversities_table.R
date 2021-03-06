
# test diversities table -------------------------------------------------------
context("diversities_table()")
Ps <- system.file("extdata", "practice_data_set.csv", package = "hagis")
Ps <- read.csv(Ps)
diversities <- calculate_diversities(x = Ps,
                                     cutoff = 60,
                                     control = "susceptible",
                                     sample = "Isolate",
                                     Rps = "Rps",
                                     perc_susc = "perc.susc")

test_that("diversity_table() returns a pander object", { 
  expect_type(
    capture.output(diversities_table(x = diversities, type = "text")),
    "character")
})

test_that("diversity_table() stops if object is not hagis.diversities object",
          {expect_error(diversities_table("y"),
                        regexp = "This is not a hagis.diversities object.")
          })
