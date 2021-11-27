#! /home/shiauck/bin/Rscript

library(dplyr)
library(ggplot2)

df <- data.frame(read.table("1_1_enhancer_ensid_ae_psi.SE.txt", header=T, sep="\t"))
df$tissue_id <- as.numeric(row.names(df)) %% 84
df <- df[, c("Ensembl.Gene.ID","AE_nth", "tissue_id", "PSI")]
df <- unique(df)

med_df <- df %>%
          group_by(Ensembl.Gene.ID, AE_nth) %>%
          summarize(median_PSI=median(PSI, na.rm=T))
med_df <- as.data.frame(med_df)

merge_df <- merge(df, med_df, by.x=c("Ensembl.Gene.ID", "AE_nth"), by.y=c("Ensembl.Gene.ID", "AE_nth"))

regressor <- lm(formula = PSI ~ median_PSI, data=merge_df)
summary(regressor)
# Call:
# lm(formula = PSI ~ median_PSI, data = merge_df)

# Residuals:
#      Min       1Q   Median       3Q      Max
# -0.93392 -0.06984  0.00107  0.07939  0.90735

# Coefficients:
#              Estimate Std. Error t value Pr(>|t|)
# (Intercept) 0.0435090  0.0002819   154.3   <2e-16 ***
# median_PSI  0.9075182  0.0004481  2025.3   <2e-16 ***
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# Residual standard error: 0.1507 on 945894 degrees of freedom
#   (488992 observations deleted due to missingness)
# Multiple R-squared:  0.8126,    Adjusted R-squared:  0.8126
# F-statistic: 4.102e+06 on 1 and 945894 DF,  p-value: < 2.2e-16

p <- ggplot(data = merge_df[!is.na(merge_df$PSI),], aes(x = median_PSI))
p <- p + geom_point(aes(y = PSI), size = 0.1)
p <- p + geom_smooth(aes(y = PSI), method = 'lm', se = T)
p <- p + coord_cartesian(ylim = c(0, 1.03), xlim = c(0, 1))
p <- p + annotate('text', x = 0.5, y = 1.04,
                  label = paste0('PSI = ',
                          sprintf("%.4f", regressor$coefficients[2]),
                          ' median_PSI + ',
                          sprintf("%.4f", regressor$coefficients[1]), "\n",
                          'Adjusted R-squared: ',
                          sprintf("%.4f", summary(regressor)$adj.r.squared)))
p <- p + theme_bw()

ggsave(p, file="2_regression_test_PSI_vs_medPSI.png", width=12, height=7, dpi=300)
