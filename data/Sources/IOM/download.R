library(httr)

url <- "https://missingmigrants.iom.int/sites/g/files/tmzbdl601/files/report-migrant-incident/Missing_Migrants_Global_Figures_allData.csv"
resp <- GET(
  url,
  add_headers(
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    "Accept" = "text/csv,application/csv,text/plain;q=0.9,*/*;q=0.8"
  )
)
stop_for_status(resp)
csv_text <- content(resp, "text", encoding = "UTF-8")
df <- read.csv(text = csv_text, stringsAsFactors = FALSE)
write.csv(df, "../data/Sources/IOM/Missing_Migrants_Global_Figures_allData.csv", row.names = FALSE)
