

library(data.table)
library(rvest)     
library(stringr)
page <- read_html("http://www.football-data.co.uk/data.php")
text <- page  %>% html_nodes('a')  %>% html_text()
links <- page  %>% html_nodes('a')  %>% html_attr('href')
text_index <- text %>% str_detect(' Football Results')
text <- text[text_index]
links <- links[text_index]
dt <- data.table()

for (i in 1:length(links)){
  print(i)
  page_country <- read_html(paste0('http://www.football-data.co.uk/', links[i]))
  text_country<- page_country  %>% html_nodes('a')  %>% html_text()
  links_country<- page_country  %>% html_nodes('a')  %>% html_attr('href') 
  links_country_index <- links_country%>% str_detect('.csv')
  dt_aux <- data.table(Link_File = text_country[links_country_index], League = links_country[links_country_index])
  dt_aux[, Link := links[i]]
  dt_aux[, Country :=  text[i]]
  dt <- rbind(dt, dt_aux, fill = T)
  
  print(i)
  Sys.sleep(1)

}


#==============

dt <- dt[!duplicated(dt$League),]

dt[, Total_Link := paste0('http://www.football-data.co.uk/', League)]

fread_v2 <- function(link_f){
  aaa <- fread(link_f, fill = T, blank.lines.skip=TRUE)
  aaa[, link := link_f]
  Sys.sleep(2)
  return(aaa)
}
file_lines <- readLines(dt$Total_Link[84])
writeLines(gsub(",+$", "", file_lines),
           "without_commas.txt")
fread("without_commas.txt")
aa_csv <- lapply(dt$Total_Link[84], fread_v2) %>% rbindlist(fill = T)
aa_csv[, .N, by = link]
