# Data prep and exploratory graphics for CMT JC 2021-03-10
# S Gardiner 2021-03-01

library(tidyverse)

# PEFR -------------------------------------------------------------------------
pefr_wide <- read_table(file = "data/pefr.dct",
                        skip = 7,
                        col_names = c("Subject",
                                      "Wright1",
                                      "Wright2",
                                      "Mini1",
                                      "Mini2"))
pefr_long <- pefr_wide %>%
  pivot_longer(-Subject,
               names_to = c("Measure", "Run"),
               names_pattern = "([a-zA-Z]+)([12])")

write_csv(pefr_wide, "data/pefr_wide.csv")
write_csv(pefr_long, "data/pefr_long.csv")

# Darbela ----------------------------------------------------------------------
darbela <- read_table(file = "data/darbela.dct",
                      skip = 5,
                      col_names = c("Subject",
                                    "VCF short axis",
                                    "VCF long axis"))
write_csv(darbela, "data/darbela.csv")

# Sealey -----------------------------------------------------------------------
sealey <- read_table(file = "data/sealey.dct",
                     skip = 4,
                     col_names = c("Subject",
                                   "Pulse oximeter",
                                   "Saturation monitor"))
write_csv(sealey, "data/sealey.csv")


# 
# pefr_ba <- pefr_wide %>%
#   transmute(average = Wright1 + Mini1 / 2,
#             difference = Wright1 - Mini1)
# 
# pefr_anno <- tibble(
#   value = mean(pefr_ba$difference),
#   annotation = "Mean"
# )
#   