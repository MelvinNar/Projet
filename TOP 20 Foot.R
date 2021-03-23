title: "Top 20 des joueurs de football"

## Chargement des données ##
library(dplyr)
library(RSQLite)

#Les données sont stockées dans un fichier SQLite. La fonction dbConnect permet de se connecter aux données. 
 

df <- dbConnect(SQLite(), dbname="/Users/Melvin10/Desktop/database.sqlite")

## Liste des tables ##
dbListTables(df)

install.packages("dplyr")
player <- tbl_df(dbGetQuery(df,"SELECT * FROM Player"))
player_stats <- tbl_df(dbGetQuery(df,"SELECT * FROM Player_Attributes"))

player_stats <-  player_stats %>%
  rename(player_stats_id = id) %>%
  left_join(player, by = "player_api_id")

#There are several observations in date_stat so I choose the latest:
latest_ps <- player_stats %>% 
  group_by(player_api_id) %>% 
  top_n(n = 1, wt = date) %>%
  as.data.frame()

#I’m only interested in top 20 players so I choose them from the latest observation based on overall_rating:
top20 <- 
  latest_ps %>% 
  arrange(desc(overall_rating)) %>% 
  head(n = 20) %>%
  as.data.frame()


library(DT)

top20 %>% 
  select(player_name, birthday, height, weight, preferred_foot, overall_rating) %>% 
  datatable(., options = list(pageLength = 10))

library(DescTools)

Desc(top20$overall_rating, plotit = TRUE)
  
install.packages("ggvis")
library(ggvis)

measures <- names(top20[,10:42])

top20 %>% 
  ggvis(x = input_select(measures, label = "Choose the x-axis:", map = as.name)) %>% 
  layer_points(y = ~overall_rating, fill = ~player_name)

