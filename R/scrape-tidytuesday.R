library(rtweet)
library(dplyr)
library(purrr)
library(pins)


# Authenticate ------------------------------------------------------------

auth <- rtweet_bot(
  api_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)


# Get tweets and users ----------------------------------------------------

tidytuesday_tweets <- search_tweets("#tidytuesday", token = auth,
                                    include_rts = FALSE,
                                    n = 10000, retryonratelimit = TRUE) %>%
  filter(!is.na(id)) %>%
  transmute(
    created_at, id = id_str, full_text, retweet_count, favorite_count,
    images = map(entities, pluck, "media")
  )

tidytuesday_users <- users_data(tidytuesday_tweets)

tidytuesday_tweets <- tidytuesday_tweets %>%
  bind_cols(
    tidytuesday_users %>% select(name, screen_name, followers_count, verified)
  )

stopifnot(nrow(tidytuesday_tweets) == nrow(tidytuesday_users))

tidytuesday_tweets <- tidytuesday_tweets %>%
  mutate(
    created_at =  strptime(created_at,
                           "%a %b %d %H:%M:%S +0000 %Y", tz = "UTC"),
    tweet_url = paste0("https://twitter.com/", screen_name, "/status/", id_str)
  ) %>%
  arrange(desc(favorite_count))


# Pin data ----------------------------------------------------------------

board <- board_register_github(
  name = "tidytuesday-tweets", repo = "taylordunn/tidytuesday-scraper",
  path = "data", token = Sys.getenv("GITHUB_PAT")
)

pin(tidytuesday_tweets, name = paste0("tidytuesday-tweets_", Sys.date()),
    board = "tidytuesday-tweets")
