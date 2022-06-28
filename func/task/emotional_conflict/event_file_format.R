setwd("C:/neurodesktop-storage/github/func/task/emotional_conflict")
library(tidyverse)

event.file <- read.table("C:/neurodesktop-storage/qtab_bids/sub-0005/ses-02/func/sub-0005_ses-02_task-emotionalconflict_events.tsv", 
                         sep = '\t', na.strings = 'n/a', header = T)

Congruent <- event.file %>% filter(trial_type=="Congruent")
Congruent <- Congruent %>% select(onset)
Congruent$x1 <- 1
Congruent$x2 <- 1
write.table(Congruent, "events/sub-0005_congruent.tab", sep = '\t', row.names = F, col.names = F, quote = F)

Incongruent <- event.file %>% filter(trial_type=="Incongruent")
Incongruent <- Incongruent %>% select(onset)
Incongruent$x1 <- 1
Incongruent$x2 <- 1
write.table(Incongruent, "events/sub-0005_incongruent.tab", sep = '\t', row.names = F, col.names = F, quote = F)
