module "glue_job_default_artifact_py" {
  source       = "git::ssh://git..."
  filename     = "glue_job.py"

  #Fill in the rest of the terraform template needed

    resource "aws_glue_job" "data_ingest" {
      name     = "data_ingest"
      role_arn = aws_iam_role.arn

      command {
        script_location = var.file_path
      }
    }

    default_arguments = {
      "--continuous-log-logGroup"          = aws_cloudwatch_log_group.name
      "--enable-continuous-cloudwatch-log" = "true"
      "--enable-continuous-log-filter"     = "true"
      "--enable-metrics"                   = ""
    }
  }
}

module "glue_job_default_artifact_dependencies" {
  source       = "git::ssh://git..."
  filename     = "dependencies.zip"
  #Fill in the rest of the terraform template needed
  }
}

module "glue_ingest" {
  source = "git::ssh://git..."
  job_name = "ingest-glue-job"
  
  #Fill in the rest of the terraform template needed
  
  role_arn = var.glue_job_role_arn

    command {
      script_location = var.glue_job_command_script_location

      name           = var.glue_job_command_name
      python_version = var.glue_job_command_python_version
    }

    dynamic "execution_property" {
      iterator = execution_property
      for_each = var.glue_job_execution_property
      content {
        max_concurrent_runs = lookup(execution_property.value, "max_concurrent_runs", 1)
      }
    }

    dynamic "notification_property" {
      iterator = notification_property
      for_each = var.glue_job_notification_property
      content {
        notify_delay_after = lookup(notification_property.value, "notify_delay_after", null)
      }
    }

    tags = merge(
      {
        Name = var.glue_job_name != "" ? lower(var.glue_job_name) : "${lower(var.name)}-glue-job-${lower(var.environment)}"
      },
      var.tags
    )

    lifecycle {
      create_before_destroy = true
      ignore_changes        = []
    }
  }
  glue_connections_name = var.config["glue_connections_list"]
}

