library(dplyr)

df = data.frame(
  X1 = LETTERS[1:5], 
  X2 = c("apple", "apple", "apple", "banana", "banana"),
  X3 = c("apple", "banana", "apple", "banana", "apple"), 
  stringsAsFactors=FALSE
)

column_string = "X2"
column_value = "banana"
column_name <- rlang::sym(column_string)

filtered_df <- df %>%
  filter(UQ(column_name) == UQ(column_value))

filtered_df

filtered_df <- df %>%
  filter(!!column_name == !!column_value)

filtered_df


