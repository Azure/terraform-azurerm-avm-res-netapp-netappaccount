locals {
  weekly_schedule_day            = var.weekly_schedule != null ? jsondecode(jsonencode(join(",", var.weekly_schedule.day))) : null
  monthly_schedule_days_of_month = var.monthly_schedule != null ? jsondecode(jsonencode(join(",", var.monthly_schedule.days_of_month))) : null
}
