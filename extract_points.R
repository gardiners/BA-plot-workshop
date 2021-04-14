# Extract point data from an SVG plot. The SVG itself is a figure from
# @Robinson2021, exctracted from the PDF and cleaned by hand to ease parsing.
# SG 2021-04-12

library(tidyverse)
library(xml2)

# Read SVG
raw_data <- read_xml("FIX_clean_scaled.svg") %>%
  xml_ns_strip()

# Extract point nodes
points_paths <- raw_data %>%
  xml_find_all("//g[@id='g4125']/path")
d <- points_paths %>%
  xml_attr("d") %>%
  str_extract("(?<=m )[0-9.,]+(?= c)")
ids <- points_paths %>%
  xml_attr("id")
style <- points_paths %>%
  xml_attr("style")

# Parse point attributes and create dataframe
style_data <- tibble(style = style) %>%
  mutate(id = ids) %>%
  separate(style, into = as.character(1:6), sep = ";") %>%
  pivot_longer(-id) %>%
  select(-name) %>%
  separate(value, into = c("name", "value"), sep = ":") %>%
  pivot_wider()
  
points_unscaled <- tibble(d = d, style_data) %>%
  separate(d, into = c("x", "y"), sep = ",", convert = TRUE) %>%
  mutate(y = -1 * y)

# Scale to match published plot

width <- function(x) max(x) - min(x)

true_x <- c(5, 60)
true_y <- c(8, 88)

scale_x <- width(true_x) / width(points_unscaled$x)
scale_y <- width(true_y / width(points_unscaled$y))
offset_x <- min(true_x) - min(points_unscaled$x * scale_x)
offset_y <- min(true_y) - min(points_unscaled$y * scale_y)

points_scaled <- points_unscaled %>%
  mutate(x = x * scale_x + offset_x,
         y = y * scale_y + offset_y,
         id = row_number())

write_csv(points_scaled, "data/fix_points.csv")

