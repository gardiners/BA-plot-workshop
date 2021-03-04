# Data prep and exploratory graphics for CMT JC 2021-03-10
# S Gardiner 2021-03-01

library(haven)
library(tidyverse)
library(ggstatsplot)

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

ggplot(pefr_wide, aes(Wright1, Mini1)) +
  geom_point(shape = "circle open", size = 3) +
  scale_x_continuous(limits = c(0, 800)) +
  scale_y_continuous(limits = c(0, 800)) +
  geom_abline(slope = 1) +
  coord_equal()

pefr_ba <- pefr_wide %>%
  transmute(average = Wright1 + Mini1 / 2,
            difference = Wright1 - Mini1)

pefr_anno <- tibble(
  value = c(
    mean(pefr_ba$difference),
    
  ),
  annotation = "Mean"
)
  