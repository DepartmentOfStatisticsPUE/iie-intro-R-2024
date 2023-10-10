library(purrr)
library(data.table)
library(rvest)
library(glue)
library(janitor)
library(data.table)
library(writexl)

policja <- list()

read_html_safely <- safely(read_html)
for (i in 0:359) {
  Sys.sleep(0.10)
  if (i %% 10 == 0) print(i)
  m <- glue::glue("https://policja.pl/pol/form/1,Informacja-dzienna.html?page={i}")
  doc <- read_html_safely(m)
  
  if (!is.null(doc$error)) {
    print("=====================================")
    print(glue::glue("Error in {i} iteration"))
    print(doc$error)
    Sys.sleep(1)
    doc <- read_html_safely(m)
    print(doc$error)
    print("=====================================")
    
  }
  
  policja[[i+1]] <- doc$result |> html_table() |> {\(x) x[[1]]}() |> janitor::clean_names()
}

stats_df <- rbindlist(policja)
stats_df[, data:=as.Date(data)]
stats_df <- unique(stats_df)

fwrite(stats_df, file = "data-raw/policja-droga-info-dzienne.csv")
write_xlsx(stats_df, path = "data-raw/policja-droga-info-dzienne.xlsx")

