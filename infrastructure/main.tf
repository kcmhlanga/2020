# main.tf 2 modules for 1 for a step function and 1 for the actual glue job

module "step_1_parallelism" {
    resource "aws_sfn_state_machine" "sfn_state_machine" {
      name     = var.step_1_parallelism_name
      role_arn = aws_iam_role.step_1_parallelism.arn

      definition = << EOF
      {
          "Comment": "Invoke AWS Lambda from AWS Step Functions with Terraform",
          "StartAt": "IngestData",
          "States": {
            "IngestData": {
                "Type": "Task",
                "Resource": "${aws_lambda_function.lambda_function.arn}",
                "Next": "ProcessData"
            }
            "ProcessData": {
                "Type": "Task",
                "Resource": "${aws_lambda_function.lambda_function.arn}",
                "End": true
            }
          }
      }
      EOF

      service_integrations = {
        s3bucket = {
          s3bucket = ["arn:aws:s3bucket:region:rawbucket"]
        }

        lambda = {
          lambda = ["arn:aws:lambda:region:function:ingest", "arn:aws:lambda:region:function:process"]
        }
      }

    }
}

module "glue_ingest_default_job" {
  resource "aws_glue_crawler" "ingest" {
    database_name = aws_glue_catalog_database.name
    name          = "data_ingest"
    schedule      = "cron(0 1 * * ? *)"
    role          = aws_iam_role.glue_role.arn

    catalog_target {
      database_name = aws_glue_catalog_database.name
      tables        = [aws_glue_catalog_table.name]
    }

    schema_change_policy {
      delete_behavior = "LOG"
    }

    configuration = <<EOF
  {
    "Version":1.0,
    "Grouping": {
      "TableGroupingPolicy": "CombineCompatibleSchemas"
    }
  }
  EOF
  }
}
