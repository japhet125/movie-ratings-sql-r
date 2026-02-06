#install.packages("DBI")
library(DBI)
#install.packages("RPostgres")
library(RPostgres)
#install.packages("dplyr")
library(dplyr)
#install.packages("tidyr")
library(tidyr)
Sys.setenv(PGPASSWORD = "newpassword")


con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "Ass2A",
  host     = "127.0.0.1",       # Local server
  port     = 5432,              # Default PostgreSQL port
  user     = "guibrilramde",    # Your pgAdmin username
  password = Sys.getenv("PGPASSWORD")
)

# Check that tables exist
DBI::dbListTables(con)


users = dbReadTable(con, "users")
movies = dbReadTable(con, "movies")
ratings = dbReadTable(con, "ratings")

users
movies
ratings