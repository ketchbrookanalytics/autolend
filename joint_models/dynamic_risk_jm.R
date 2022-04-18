library(rstanarm)
library(tibble)
library(data.table)

pbcLong |> 
  tibble::tibble()


pbcSurv |> 
  tibble::tibble()


mod1 <- stan_jm(
  formulaLong = logBili ~ sex + trt + year + (year | id),
  dataLong = pbcLong, 
                
  formulaEvent = survival::Surv(futimeYears, death) ~ sex + trt,
  dataEvent = pbcSurv,
                
  time_var = "year", 
  chains = 1, 
  refresh = 2000, 
  seed = 12345
)


alpha_mod1 <- as.data.frame(mod1)[["Assoc|Long1|etavalue"]]

alpha_median <- median(alpha_mod1) |> 
  round(3)

# Calculate the estimated x-fold increase in the hazard of death for each one 
# unit increase in an individual's underlying level of log serum bilirubin 
# (Long1|etavalue)
exp(alpha_median) |> 
  round(3)


