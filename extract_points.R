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

# # Plot
# 
# participants <- unique(points_scaled$fill)
# scale_part <- scale_colour_manual(values = set_names(participants))
# 
# pfizer_plot <- ggplot(points_scaled, aes(x, y, colour = fill)) +
# coord_equal() +
#   scale_x_continuous(limits = c(0, NA), breaks = scales::breaks_width(10)) +
#   scale_y_continuous(limits = c(0, 100), breaks = scales::breaks_width(10)) +
#   theme(legend.position = "none") +
#   scale_part
# 
# pfizer_plot + geom_point()
# 
# pfizer_plot + geom_text(aes(label = id)) + part_scale
# 
# pfizer_plot +
#   geom_point() +
#   geom_abline(slope = 1, linetype = "dashed")
# 
# pfizer_plot + 
#   geom_point() +
#   geom_abline(slope = 1, linetype = "dashed") +
#   geom_smooth(method = "lm", colour = "black", group = 1, fullrange = TRUE, se = FALSE)
#   
# 
# # Bland-Altman
# ba_data <- points_scaled %>%
#   transmute(mean_value = x + y / 2,
#             difference =  x - y,
#             pct_difference = (difference / mean_value),
#             subject = fill,
#             id = row_number())
# 
# # Plain BA plot:
# ggplot(ba_data, aes(x = mean_value, y = difference, colour = subject)) +
#   geom_point() +
#   scale_part
# 
# 
# # Percent difference BA plot:
# ggplot(ba_data, aes(x = mean_value, y = pct_difference, colour = subject)) +
#   geom_point() +
#   scale_part