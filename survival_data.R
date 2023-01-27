


tibble::tribble(
  ~month, ~borrower_id, ~loan_id, ~loan_amount, ~fico_score, ~industry_outlook_slope, ~due_date_vs_pmt_date, ~default_status, 
  0, 1001, 1001001, 50000, 725, 0.3, 0, 0,
  1, 1001, 1001001, 50000, 726, 0.3, 0, -2,
  2, 1001, 1001001, 50000, 732, 0.3, 0, 1
)