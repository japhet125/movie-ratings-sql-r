#install.packages("DBI")
library(DBI)
#install.packages("RPostgres")
library(RPostgres)
#install.packages("dplyr")
library(dplyr)
#install.packages("tidyr")
library(tidyr)


#install.packages("usethis")

#usethis::edit_r_environ()


#Dtabase connection
con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "Ass2A",
  host     = "127.0.0.1",       # Local server
  port     = 5432,              # Default PostgreSQL port
  user     = "guibrilramde",    # Your pgAdmin username
  password = Sys.getenv("PGPASSWORD")
)

# Check that tables exist and load
DBI::dbListTables(con)


users = dbReadTable(con, "users")
movies = dbReadTable(con, "movies")
ratings = dbReadTable(con, "ratings")

head(users)
head(movies)
head(ratings)

#building the rating dataset
ratings_df = dbGetQuery(con, "
SELECT
    u.name AS user_name,
    m.title AS movie_title,
    r.rating
FROM users u
CROSS JOIN movies m
LEFT JOIN ratings r
    ON u.user_id = r.user_id
    AND m.movie_id = r.movie_id
   ")

head(ratings_df)

#Basic analysis getting the average rating from movies
movie_summary = ratings_df %>%
  group_by(movie_title) %>%
  summarise(
    avg_rating = mean(rating, na.rm = TRUE),
    rating_count = sum(!is.na(rating))
  ) %>%
  arrange(desc(avg_rating))
movie_summary

#Basic analysis getting the average rating from each user
user_summary = ratings_df %>%
  group_by(user_name) %>%
  summarise(
    avg_rating = mean(rating, na.rm = TRUE),
    movie_seen = sum(!is.na(rating))
    
  )
user_summary 

#the user item matrix
rating_matrix = ratings_df %>%
  pivot_wider(
    names_from = movie_title,
    values_from = rating
  )

rating_matrix

dbDisconnect(con)