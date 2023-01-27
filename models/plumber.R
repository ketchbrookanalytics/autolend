# plumber.R

#* @apiTitle AutoLend
#* @apiDescription The automated lending & probability of default (PD) model from Ketchbrook Analytics

#* Return the model output
#* @param credit_bureau_score The applicant's credit bureau score
#* @param last_payment_days_past_due The number of days past the due date of the applicant's last payment on any existing credit (if new applicant, provide `0`)
#* @post /model
function(credit_bureau_score, last_payment_days_past_due){
 
  mdl <- readRDS(here::here("models/survival_model.RDS"))
  
  est <- survival::survfit(
    mdl, 
    newdata = data.frame(
      credit_bureau_score = as.integer(credit_bureau_score), 
      last_payment_days_past_due = as.integer(last_payment_days_past_due)
    )
  )
  
  # Create separate arrays for the months of the forecast & associated 
  # probabilities of default
  month <- est$time[1:11] 
  prob <- ((1 - est$surv[1:11]) * 100) |> round(2) |> paste0("%")
  
  # If the probability of the loan defaulting in the first 10 months is < 50%, 
  # then "approve" the loan; otherwise, "reject" it
  decision <- ifelse(
    (1 - est$surv[10]) < 0.5, 
    "approved",
    "rejected"
  )
  
  list(
    month = month, 
    prob_default = prob, 
    decision = decision
  )
  
}