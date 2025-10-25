#Overall response curves in TB variability for selection and control populations over 21 generations of selection

options(contrasts = c("contr.treatment", "contr.poly"), digits = 3) # make your contrasts sum to zero, instead of treatment contrasts, for the ANOVA analysis. If you have interactions you care about, this is the only way to have them make sense.

library(ggplot2)

df_sel <- read.csv("analysis_by_assay/Generations_Ymaze/sel_allgen.csv")
df_sel$block <- as.factor(df_sel$block)

df_con <- read.csv("analysis_by_assay/Generations_Ymaze/con_allgen.csv")
df_con$block <- as.factor(df_con$block)

#plotting and fitting selection populations

ggplot(df_sel, aes(x = gen, y = TB)) +
  # scatter of each block, colored by block
  geom_point(aes(color = block),
             shape = 16,
             alpha = 0.6,    # make points a bit transparent
             size  = 2) +     

# pooled smooth across all points (group = 1 averages across 'block')
geom_smooth(aes(group = 1),
              se     = TRUE,        # display confidence band
              color  = "black",     # curve color
              fill   = "grey80",    # band fill
              linewidth = 0.75) +
  # manually set the three replicate colors
  scale_color_manual(
    values = c(
      "1" = "#3DED51",  # green
      "2" = "#DC2B18",  # red
      "3" = "#5694FF"   # blue
    )
  ) +
  scale_y_continuous(
    limits = c(0.098, 0.20), 
    breaks = seq(0.10, 0.20, by = 0.02),
    labels = paste0(seq(0.10, 0.20, by = 0.02))
  )+
# polish labels and theme
labs(title = "",
       x     = "Generation",
       y     = "Turn-bias Variability",
       color = "Block") +  # legend title for points+
theme_classic() +

theme(
  panel.background = element_rect(fill = "transparent", colour = NA),
  plot.background  = element_rect(fill = "transparent", colour = NA),  
  panel.border = element_rect(              # draw a rectangle around the panel
      colour = "black",
      fill   = NA,                            # don’t fill it
      linewidth   = 1)                              # thickness
    )
    
ggsave("analysis_by_assay/Generations_Ymaze/geomfit_sel.pdf",width = 6, height = 4, bg ='transparent')


#plotting and fitting control populations

ggplot(df_con, aes(x = gen, y = TB)) +
  # scatter of each block, colored by block
  geom_point(aes(color = block), 
             shape = 17,
             alpha = 0.6,    # make points a bit transparent
             size  = 2) +     
  
  # pooled smooth across all points (group = 1 averages across 'block')
  geom_smooth(aes(group = 1),
              se     = TRUE,        # display confidence band
              color  = "black",     # curve color
              fill   = "grey80",    # band fill
              linewidth = 0.75) +
  # manually set the three replicate colors
  scale_color_manual(
    values = c(
      "1" = "#1C7324",  # darkgreen
      "2" = "#75150D",  # darkred
      "3" = "#1A1D7A"   # darkblue
    )
  ) +
  scale_y_continuous(
    limits = c(0.098, 0.20), 
    breaks = seq(0.10, 0.20, by = 0.02),
    labels = paste0(seq(0.10, 0.20, by = 0.02))
  ) +
  # polish labels and theme
  labs(title = "",
       x     = "Generation",
       y     = "Turn-bias Variability",
       color = "Block") +  # legend title for points
  theme_classic() +
  
  theme(
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),
    panel.border = element_rect(              # draw a rectangle around the panel
      colour = "black",
      fill   = NA,                            # don’t fill it
      linewidth   = 1)                              # thickness
  )

ggsave("analysis_by_assay/Generations_Ymaze/geomfit_con.pdf",width = 6, height = 4, bg = 'transparent')
