#' Using the Twitter oEmbed API, get the embed HTML for a single tweet
embed_tweet <- function(id) {
  url <- paste0("https://publish.twitter.com/oembed?url=https%3A%2F%2Ftwitter.com%2FInterior%2Fstatus%2F", id)
  fromJSON_possibly <- purrr::possibly(~ jsonlite::fromJSON(.)$html,
                                       otherwise = "")
  tweet <- HTML(fromJSON_possibly(url))

  class(tweet) <- c("tweet", class(tweet))
  tweet
}
