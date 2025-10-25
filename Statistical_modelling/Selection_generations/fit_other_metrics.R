#Curves of generation-wise mean TB and activity measures (via number of turns) for selection and control populations

options(contrasts = c("contr.treatment", "contr.poly"), digits = 3) # make your contrasts sum to zero, instead of treatment contrasts, for the ANOVA analysis. If you have interactions you care about, this is the only way to have them make sense.

library(ggplot2)

df_sel <- read.csv("analysis_by_assay/Generations_Ymaze/sel_supp_allgen.csv")
df_sel$block <- as.factor(df_sel$block)

df_con <- read.csv("analysis_by_assay/Generations_Ymaze/con_supp_allgen.csv")
df_con$block <- as.factor(df_con$block)

# MEAN TB

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
    limits = c(0.39, 0.61), 
    breaks = seq(0.40, 0.60, by = 0.10),
    labels = paste0(seq(0.40, 0.60, by = 0.10))
  )+
  # polish labels and theme
  labs(title = "",
       x     = "Generation",
       y     = "Mean Turn-bias",
       color = "Block") +  # legend title for points+
  theme_classic() +
  
  theme(
    legend.position = "none",
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),  
    panel.border = element_rect(              # draw a rectangle around the panel
      colour = "black",
      fill   = NA,                            # don’t fill it
      linewidth   = 1)                              # thickness
  )

ggsave("analysis_by_assay/Generations_Ymaze/sel_mean_TB.pdf",width = 6, height = 4, bg ='transparent')


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
    limits = c(0.39, 0.61), 
    breaks = seq(0.40, 0.60, by = 0.10),
    labels = paste0(seq(0.40, 0.60, by = 0.10))
  )+
  # polish labels and theme
  labs(title = "",
       x     = "Generation",
       y     = "Mean Turn-bias",
       color = "Block") +  # legend title for points
  theme_classic() +
  
  theme(
    legend.position = "none",
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),
    panel.border = element_rect(              # draw a rectangle around the panel
      colour = "black",
      fill   = NA,                            # don’t fill it
      linewidth   = 1)                              # thickness
  )

ggsave("analysis_by_assay/Generations_Ymaze/con_mean_TB.pdf",width = 6, height = 4, bg = 'transparent')

# MEAN N

#plotting and fitting selection populations

df_sel_N <- df_sel[df_sel$gen != 1, ]
df_con_N <- df_con[df_con$gen != 1, ]


ggplot(df_sel_N, aes(x = gen, y = N_mean)) +
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
    limits = c(300, 850), 
    breaks = seq(400, 850, by = 200),
    labels = paste0(seq(400, 850, by = 200))
  )+
  # polish labels and theme
  labs(title = "",
       x     = "Generation",
       y     = "Mean Number of Turns",
       color = "Block") +  # legend title for points+
  theme_classic() +
  
  theme(
    legend.position = "none",
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),  
    panel.border = element_rect(              # draw a rectangle around the panel
      colour = "black",
      fill   = NA,                            # don’t fill it
      linewidth   = 1)                              # thickness
  )

ggsave("analysis_by_assay/Generations_Ymaze/sel_mean_N.pdf",width = 6, height = 4, bg ='transparent')


#plotting and fitting control populations

ggplot(df_con_N, aes(x = gen, y = N_mean)) +
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
    limits = c(300, 850), 
    breaks = seq(400, 850, by = 200),
    labels = paste0(seq(400, 850, by = 200))
  )+
  # polish labels and theme
  labs(title = "",
       x     = "Generation",
       y     = "Mean Number of Turns",
       color = "Block") +  # legend title for points
  theme_classic() +
  
  theme(
    legend.position = "none",
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),
    panel.border = element_rect(              # draw a rectangle around the panel
      colour = "black",
      fill   = NA,                            # don’t fill it
      linewidth   = 1)                              # thickness
  )

ggsave("analysis_by_assay/Generations_Ymaze/con_mean_N.pdf",width = 6, height = 4, bg = 'transparent')

# VAR N

#plotting and fitting selection populations

ggplot(df_sel_N, aes(x = gen, y = N_var)) +
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
    limits = c(0.3, 0.65),
    breaks = seq(0.4, 0.6, by = 0.1),
    labels = paste0(seq(0.4, 0.6, by = 0.1))
  )+
  # polish labels and theme
  labs(title = "",
       x     = "Generation",
       y     = "Variability in Number of Turns (s.d./mean)",
       color = "Block") +  # legend title for points+
  theme_classic() +
  
  theme(
    legend.position = "none",
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),  
    panel.border = element_rect(              # draw a rectangle around the panel
      colour = "black",
      fill   = NA,                            # don’t fill it
      linewidth   = 1)                              # thickness
  )

ggsave("analysis_by_assay/Generations_Ymaze/sel_var_N.pdf",width = 6, height = 4, bg ='transparent')


#plotting and fitting control populations

ggplot(df_con_N, aes(x = gen, y = N_var)) +
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
    limits = c(0.3, 0.65),
    breaks = seq(0.4, 0.6, by = 0.1),
    labels = paste0(seq(0.4, 0.6, by = 0.1))
  )+
  # polish labels and theme
  labs(title = "",
       x     = "Generation",
       y     = "Variability in Number of Turns (s.d./mean)",
       color = "Block") +  # legend title for points
  theme_classic() +
  
  theme(
    legend.position = "none",
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),
    panel.border = element_rect(              # draw a rectangle around the panel
      colour = "black",
      fill   = NA,                            # don’t fill it
      linewidth   = 1)                              # thickness
  )

ggsave("analysis_by_assay/Generations_Ymaze/con_var_N.pdf",width = 6, height = 4, bg = 'transparent')

