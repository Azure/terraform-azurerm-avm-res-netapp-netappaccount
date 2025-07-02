resource "azapi_resource" "anf_snapshot_policy" {
  location  = var.location
  name      = var.name
  parent_id = var.account.resource_id
  type      = "Microsoft.NetApp/netAppAccounts/snapshotPolicies@2024-07-01"
  body = {
    properties = {
      enabled = var.enabled

      hourlySchedule = var.hourly_schedule != null ? {
        snapshotsToKeep = var.hourly_schedule.snapshots_to_keep
        minute          = var.hourly_schedule.minute
        } : {
        snapshotsToKeep = null
        minute          = null
      }

      dailySchedule = var.daily_schedule != null ? {
        snapshotsToKeep = var.daily_schedule.snapshots_to_keep
        hour            = var.daily_schedule.hour
        minute          = var.daily_schedule.minute
        } : {
        snapshotsToKeep = null
        hour            = null
        minute          = null
      }

      weeklySchedule = var.weekly_schedule != null ? {
        snapshotsToKeep = var.weekly_schedule.snapshots_to_keep
        day             = local.weekly_schedule_day
        minute          = var.weekly_schedule.minute
        hour            = var.weekly_schedule.hour
        } : {
        snapshotsToKeep = null
        day             = null
        minute          = null
        hour            = null
      }

      monthlySchedule = var.monthly_schedule != null ? {
        snapshotsToKeep = var.monthly_schedule.snapshots_to_keep
        daysOfMonth     = local.monthly_schedule_days_of_month
        hour            = var.monthly_schedule.hour
        minute          = var.monthly_schedule.minute
        } : {
        snapshotsToKeep = null
        daysOfMonth     = null
        hour            = null
        minute          = null
      }
    }
  }
  schema_validation_enabled = false
  tags                      = var.tags
}
