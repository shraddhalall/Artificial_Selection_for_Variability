# Plotting TB var data for populations before, after selection and after relaxation

library(dplyr)
library(ggplot2)

setwd("E:/Selection/analysis_by_assay/TB_data")

# 1. Read & tag each timepoint
df1 <- readRDS("gen21_TB.rds") %>% mutate(timepoint = 1)
df2 <- readRDS("gen24_TB.rds") %>% mutate(timepoint = 2)
df3 <- readRDS("gen38_TB.rds") %>% mutate(timepoint = 3)

df0 <- readRDS("gen0_TB.rds") %>% 
  mutate(
    timepoint = 0,
    # at tp0 there's no selection factor, so set to a single level
    selection = factor("ancestral", levels = c(levels(df1$selection), "ancestral"))
  )


# 2. Combine
df_all <- bind_rows(df0, df1, df2, df3) %>%
  # make timepoint a factor so ggplot spaces it equally
  mutate(timepoint = factor(timepoint, levels = 0:3,
                            labels = c("G0","G21","G24","G38")))

# 3. Plot: points ± errorbars, color = selection, shape = sex
# 1) Turn timepoint into a numeric 1:4
df_plot <- df_all %>%
  mutate(
    tp_num = as.numeric(timepoint),  # 1,2,3,4
    
    # 2) assign small offsets so con cluster sits left, sel cluster sits right
    x = tp_num + case_when(
      selection == "con" & sex == "F" ~ -0.20,
      selection == "con" & sex == "M"   ~ -0.10,
      selection == "sel" & sex == "F" ~ +0.10,
      selection == "sel" & sex == "M"   ~ +0.20,
      # “all” cluster at T0  (two sexes only)
      selection == "ancestral" & sex == "F" ~ -0.10,
      selection == "ancestral" & sex == "M"   ~ +0.10
    )
  )

# 3) Plot at those x’s – points and errorbars will  share exact positions
ggplot(df_plot, aes(x = x, y = sd_est,
                    color = selection, shape = sex)) +
  geom_errorbar(aes(ymin = sd_lower, ymax = sd_upper),
                width = 0.05) +
  geom_point(size = 3) +
  # 4) force x-axis to show the four timepoints at integer positions
  scale_x_continuous(breaks = 1:4,
                     labels = levels(df_all$timepoint)) +
  # 5) manual two colors
  scale_color_manual(values = c(
    con = "#A733B2",
    sel = "#00A1A1"
  )) +
  labs(x     = "Timepoint",
       y     = "Estimate ± 95% CI",
       color = "Population",
       shape = "Sex") +
  theme_classic() +
  
  theme(
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),  
    panel.border = element_rect(              # draw a rectangle around the panel
      colour = "black",
      fill   = NA,                            # don’t fill it
      linewidth   = 1)                              # thickness
  )

ggsave("TBvar_4tp_wide.pdf",width = 7, height = 4, bg ='transparent')
