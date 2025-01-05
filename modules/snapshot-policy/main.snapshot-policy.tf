resource "azapi_resource" "anf-snapshot-policy" {

  type      = "Microsoft.NetApp/netAppAccounts/snapshotPolicies@2024-07-01"
  parent_id = var.account.resource_id
  name      = var.name
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      enabled = var.enabled

      hourlySchedule = var.hourly_schedule != null ? {
        snapshotsToKeep = var.hourly_schedule.snapshots_to_keep
        minute          = var.hourly_schedule.minute
      } : {}

      dailySchedule = var.daily_schedule != null ? {
        snapshotsToKeep = var.daily_schedule.snapshots_to_keep
        hour            = var.daily_schedule.hour
        minute          = var.daily_schedule.minute
      } : {}

      weeklySchedule = var.weekly_schedule != null ? {
        snapshotsToKeep = var.weekly_schedule.snapshots_to_keep
        day             = join(",", var.weekly_schedule.day)
        minute          = var.weekly_schedule.minute
        hour            = var.weekly_schedule.hour
      } : {}

      monthlySchedule = var.monthly_schedule != null ? {
        snapshotsToKeep = var.monthly_schedule.snapshots_to_keep
        daysOfMonth     = join(",", var.monthly_schedule.days_of_month)
        hour            = var.monthly_schedule.hour
        minute          = var.monthly_schedule.minute
      } : {}
    }
  }

  schema_validation_enabled = false
}
