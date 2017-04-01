# Pacotes -----------------------------------------------------------------

library(dplyr)
library(purrr)
library(stringr)
library(readr)
library(readxl)
library(tidyr)

# Leitura -----------------------------------------------------------------

# base de multas de forma eletrônica
arqs <- list.files("data-raw/carros/eletronica/", full.names = TRUE, recursive = TRUE)

csv_reader <- function(path, col_names){
  read_delim(path, ";", escape_double = FALSE, trim_ws = TRUE,
             col_names = col_names, skip = 1, progress = FALSE
             )
}

excel_reader <- function(path, col_names){
  read_excel(path, col_names = col_names, skip = 1)
}

reader <- function(path, col_names){
  if(str_detect(path, "xls$")){
    excel_reader(path, col_names)
  } else {
    csv_reader(path, col_names)
  }
}

bases <- data_frame(arqs = arqs) %>%
  filter(str_detect(arqs, "[xls|csv]$")) %>%
  mutate(
    dados = map(arqs, failwith(NA, function(path){
      nomes <- c("data", "enquadramento", "local", "qtd")
      reader(path, nomes)
    }))
  )

bases <- bases %>% unnest(dados)
bases <- bases %>% filter(!is.na(qtd) & !is.na(data))

carros_eletronicas <- bases %>%
  mutate(
    hora = str_match(arqs, "([0-9]{2}).[xls|csv]")[,2] %>% as.integer(),
    data = lubridate::dmy(data)
    ) %>%
  select(data, hora, enquadramento, local, qtd)

devtools::use_data(carros_eletronicas, overwrite = TRUE)
