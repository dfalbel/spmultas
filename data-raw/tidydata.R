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
# alguns arquivos são excel e outros txt (por isso essa função complicadinha)
bases <- data_frame(arqs = arqs) %>%
  filter(str_detect(arqs, "[xls|csv]$")) %>%
  mutate(dados = map(arqs, failwith(NA, function(arq){
    nomes <- c("data", "enquadramento", "local", "qtd")
    if(str_detect(arq, "xls$")){
      read_excel(arq, col_names = nomes, skip = 1)
    } else {
      read_delim(arq, ";", escape_double = FALSE, trim_ws = TRUE,
                 col_names = nomes, skip = 1)
    }
  })))
bases <- bases %>% unnest(dados)
bases <- bases %>% filter(!is.na(qtd))
carros_eletronicas <- bases %>%
  mutate(
    hora = str_match(arqs, "([0-9]{2}).xls")[,2] %>% as.integer(),
    data = lubridate::dmy(data)
    ) %>%
  select(data, hora, enquadramento, local, qtd)

devtools::use_data(carros_eletronicas, overwrite = TRUE)
