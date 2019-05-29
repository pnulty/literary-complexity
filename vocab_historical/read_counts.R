library(dplyr)
library(feather)
library(ggplot2)
library(quanteda)
library(readtext)
library(stringr)

freq_score <- function(t1, y){
  y <- paste0('y',y)
  print(y)
  d1 <- dfm(t1, remove_numbers=TRUE, remove_punct=TRUE, remove_symbols=TRUE,remove_hyphens=TRUE) %>% t %>% data.frame 
  colnames(d1) <- 'count'
  d1$word <- rownames(d1)
  counts <- mutate(counts, freq = counts[[y]])
  y1 <- select(counts, word,freq) %>% na.omit
  y1$probs <- log(y1$freq/mean(y1$freq))
  result <- left_join(d1, y1, by='word')
  result$word=gsub("'", '', result$word)
  result <- filter(result, count > 0)
  result$freq[is.na(result$freq)] <- 10
  result$probs[is.na(result$probs)] <- log(10/mean(y1$freq))
  sum(result$probs*result$count)/sum(result$count)
}

# this is where the google books word count table is read.
counts <- read_feather('/home/paul/Dropbox/old_cambridge/style/nodes_with_sw.feather')

colnames(counts) <- paste0('y', colnames(counts))

tmp <- select(counts, starts_with('y188'), starts_with('y189'))
tmp[is.na(tmp)] <- 0
t2 <- rowSums(tmp)
names(t2) <- counts$yword

base_counts_df <- data.frame(base_count=t2, word=names(t2)) %>% filter(base_count > 41)
base_counts_df$base_rate <- base_counts_df$base_count/sum(base_counts_df$base_count) * 10000
write_feather(base_counts_df, 'base_counts.feather')

corp <- readtext('texts/*.txt', dvsep = "-",
                 docvarsfrom = "filenames",
                 docvarnames = c("title", "author", "year")) %>% corpus
t1 <- corpus_subset(corp, author=='Stevenson')
t1 <- texts(t1)

d1 <- dfm(t1, remove_numbers=TRUE, remove_punct=TRUE, remove_symbols=TRUE,remove_hyphens=TRUE) %>% t %>% data.frame 

tw <- d1$document
d1$document <- c()
rls_counts <- rowSums(d1)
names(rls_counts) <- tw
rls_counts_df <- data.frame(rls_count=rls_counts, word=tw)

rls_counts_df$rls_rate <- rls_counts_df$rls_count/sum(rls_counts_df$rls_count) * 10000

write_feather(rls_counts_df, 'rls_counts.feather')

options(scipen=999)
all_counts <- left_join(rls_counts_df, base_counts_df, by='word')
all_counts$rate_ratio <- all_counts$rls_rate/all_counts$base_rate
all_counts$error <- sqrt(all_counts$rls_count)*1.96

write_feather(all_counts, 'all_counts.feather')
