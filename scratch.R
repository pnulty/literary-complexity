library(dplyr)
library(feather)
library(ggplot2)
library(ggrepel)
library(quanteda)
library(readtext)
library(spacyr)
library(stringr)

corp_path <- '~/Dropbox/DSH/text_subsets/all/'
corp <- corpus(readtext(file = corp_path, docvarsfrom = 'filenames', dvsep = '-', docvarnames = c('title','author','year')))

t1 <- texts(corp)
ts <- tokens(t1, what='sentence') 