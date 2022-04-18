


# Fitting a Cox PH Mixed Effects Model

library(coxme)
library(survival)

head(eortc)

fit1 <- coxme::coxme(
  formula = survival::Surv(endage, cancer) ~ parity + (1 | famid)
)
