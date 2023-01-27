
library(rstanarm)
library(dplyr)
library(tibble)
library(coxme)
library(surv)


final_status <- pbcSurv |> 
  dplyr::select(id, death) |> 
  dplyr::mutate(death = dplyr::if_else(death == 1L, 0L, 1L)) |> 
  dplyr::inner_join(
    pbcLong |> 
      dplyr::group_by(id) |> 
      dplyr::summarize(year = max(year), .groups = "drop"), 
    by = "id"
  )

train <- pbcLong |> 
  tibble::tibble() |> 
  dplyr::mutate(loan_id = as.character(id + 1000)) |> 
  dplyr::group_by(id) |> 
  dplyr::mutate(
    month = dplyr::row_number(), 
    loan_amount = sample(
      x = seq(from = 10000, to = 500000, by = 2500), 
      size = 1, 
      replace = TRUE
    )
  ) |> 
  dplyr::ungroup() |> 
  dplyr::mutate(
    fico_score = scales::rescale(albumin, to = c(500, 850)) |> round() |> as.integer(), 
    last_payment_days_past_due = scales::rescale(logBili, to = c(-5, 15)) |> round() |> as.integer(), 
  ) |> 
  dplyr::left_join(
    final_status, 
    by = c("id", "year")
  ) |> 
  dplyr::mutate(default_status = dplyr::if_else(is.na(death), 0L, death)) |> 
  dplyr::select(loan_id:default_status, -death) |> 
  # changes for coxme
  dplyr::mutate(
    last_payment_days_past_due = dplyr::if_else(
      last_payment_days_past_due < 1, 1L, last_payment_days_past_due, 
    ), 
    loan_id = as.integer(loan_id)
  ) |> 
  dplyr::mutate(
    dplyr::across(.cols = -loan_amount, .fns = function(x) as.numeric(x))
  )
  

mdl <- coxme(
  Surv(month, default_status) ~ fico_score + last_payment_days_past_due + (1|loan_id) + (loan_amount|loan_id), 
  train
)

predict(
  mdl, 
  newdata = train |> dplyr::slice(1) |> dplyr::select(-default_status)
)

# {coxme} has no `predict()` method...


# Forget about {coxme}, straight survival ---------------------------------

set.seed(1234)

train <- rstanarm::pbcSurv |> 
  dplyr::mutate(
    default_status = dplyr::if_else(death == 1L, 0L, 1L), 
    loan_id = as.character(1000 + id), 
    month = scales::rescale(futimeYears, to = c(1, 12)) |> round() |> as.integer(), 
    credit_bureau_score = ifelse(
      trt == 1L, 
      sample(c(700:850), size = nrow(rstanarm::pbcSurv |> dplyr::filter(trt == 1L))), 
      sample(c(600:750), size = nrow(rstanarm::pbcSurv |> dplyr::filter(trt == 0L)))
    ),
    last_payment_days_past_due = scales::rescale(age, to = c(0, 15)) |> round() |> as.integer()
  ) |> 
  dplyr::select(default_status:last_payment_days_past_due) |> 
  dplyr::relocate(default_status, .after = dplyr::everything())

train$default_status[2] <- 0L
train$default_status[16] <- 0L
train$default_status[19] <- 0L
  
mdl <- survival::coxph(
  survival::Surv(month, default_status) ~ credit_bureau_score + last_payment_days_past_due, 
  data = train
)

# saveRDS(here::here("models/survival_model.RDS"))

plot(survival::survfit(mdl), ylab = "Probability of Survival",
     xlab = "Time", col = c("red", "black", "black"))

# Make an individual prediction
est <- survival::survfit(
  mdl, 
  newdata = data.frame(
    credit_bureau_score = 815, 
    last_payment_days_past_due = 2
  )
)

data.frame(
  month = est$time[1:12], 
  prob = 1 - est$surv[1:12]
)

lines(est$time, est$surv, col = 'blue', type = 's')
