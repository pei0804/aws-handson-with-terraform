#################
# Password Policy
#################
resource aws_iam_account_password_policy strict {
  minimum_password_length        = 64
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

########
# Budget
########
resource aws_budgets_budget cost {
  name              = "sandbox"
  budget_type       = "COST"
  limit_amount      = var.limit_usd_amount
  limit_unit        = "USD"
  time_period_start = "2020-05-10_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.email]
  }
}
