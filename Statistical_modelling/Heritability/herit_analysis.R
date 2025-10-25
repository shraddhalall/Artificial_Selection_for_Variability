
library(lme4)
library(readr)

VS_h2 <- read_csv("sel_herit.csv")
VC_h2 <- read_csv("con_herit.csv")

VS.mod <- lmer(Rc ~ Sc + (1 |block) , data = VS_h2)
VC.mod <- lmer(Rc ~ Sc + (1 |block) , data = VC_h2)

#for output table:
summary(VS.mod)
summary(VC.mod)

#for CI:
confint(VS.mod)
