#Modelling differences in selection vs control turn bias variability before selection, at the end of selection, 
#after 3 generations of relaxation and after 17 generations of relaxation

options(contrasts = c("contr.treatment", "contr.poly"), digits = 3)

library(glmmTMB)
library(dplyr)
library(emmeans)
library(MASS)
library(knitr)
library(ggplot2)

df0 <- read.csv("analysis_by_assay/Generations_Ymaze/gen0_data.csv")
df21 <- read.csv("analysis_by_assay/Generations_Ymaze/gen21.csv")

df24 <- read.csv("analysis_by_assay/Relaxed_Ymaze/relax_data.csv")
df24 <- subset(df24, gen == 24)

df38 <- read.csv("analysis_by_assay/Relaxed_Ymaze/gen38.csv")

df0$pop <- 'anc'
df0$experimenter <- 'Shraddha'
df0$gen <- 0

df21$family <- NULL
df21$gen <- 21

names(df21)[names(df21) == 'selection'] <- 'pop'

df24$family <- NULL
df24$relaxation <- NULL
names(df24)[names(df24) == 'selection'] <- 'pop'

df38$day <- c("08-07-2024", "08-08-2024", "08-09-2024")[df38$day]

names(df38)[names(df38) == 'day'] <- 'date'
names(df38)[names(df38) == 'selection'] <- 'pop'

df38$experimenter <- 'Noah'
df38$gen <- 38

df <- rbind(df0,df21,df24,df38)

df$block <- as.factor(df$block)
df$gen <- as.factor(df$gen)
df$R <- as.integer(round(df$N*df$TB)) #re-calculate num right turns from N and TB
df$pop_gen <- with(df, interaction(pop, gen, drop = TRUE))

mod1 <- glmmTMB( cbind(R, N - R) ~ 1 + pop_gen*sex,
                 
                 #dispersion model
                 
                 dispformula = ~ 1 + pop_gen*sex + 
                   diag(0 + pop_gen|block) +
                   (1 | box)+ (1|tray) + (1|arena_pos) + (1|date) + (1|experimenter),
                 family = betabinomial(link = "logit"),
                 data = df, REML = FALSE)
summary(mod1)

em_disp <- emmeans(mod1, ~ pop_gen * sex, component = "disp", type = 'response')
summary(em_disp)

#contrasts of interest:
mf_contrasts <- contrast(em_disp, method = "revpairwise", by = "pop_gen") %>%
  summary(infer = TRUE) %>%
  mutate(contrast_type = "Sex (M - F) within pop_gen")

pg_contrasts <- contrast(em_disp, method = "pairwise", by = "sex") %>%
  summary(infer = TRUE) %>%
  mutate(contrast_type = "pop_gen within sex")

full_contrasts <- pairs(em_disp) %>%
  summary(infer = TRUE) %>%
  mutate(contrast_type = "All pairwise (pop_gen × sex)")

em_nosex <- emmeans(mod1, ~ pop_gen, component = "disp", type = 'response')
summary(em_nosex)

nosex_cont <- contrast(em_nosex, method = 'pairwise')
summary(nosex_cont)
