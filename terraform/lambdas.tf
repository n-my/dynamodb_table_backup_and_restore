### Variables
variable region {
  type = "string"
}

variable lambda_runtime {
  type = "string"
  default = "python3.6"
}

### Provider
provider "aws" {
  region = "${var.region}"
}

data "aws_iam_policy_document" "ddb_open_bar" {
  statement {
    sid = "DDBFullAccess"
    actions = [
      "dynamodb:*",
    ]
    resources = [
      "*",
    ]
  }
}

module "backup_table" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "ddb_backup_table"
  description   = "DDB : backup the table"
  handler       = "ddb_backup_and_restore.ddb_backup_table"
  runtime       = "${var.lambda_runtime}"
  timeout       = 60
  source_path = "${path.module}/../lambda_functions/ddb_backup_and_restore.py"

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.ddb_open_bar.json}"
}

module "get_backup_status" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "ddb_get_backup_status"
  description   = "DDB : return the status of the backup"
  handler       = "ddb_backup_and_restore.ddb_get_backup_status"
  runtime       = "${var.lambda_runtime}"
  timeout       = 60
  source_path = "${path.module}/../lambda_functions/ddb_backup_and_restore.py"

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.ddb_open_bar.json}"
}

module "delete_table" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "ddb_delete_table"
  description   = "DDB : delete the table"
  handler       = "ddb_backup_and_restore.ddb_delete_table"
  runtime       = "${var.lambda_runtime}"
  timeout       = 60
  source_path = "${path.module}/../lambda_functions/ddb_backup_and_restore.py"

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.ddb_open_bar.json}"
}

module "restore_table" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "ddb_restore_table"
  description   = "DDB : restore the backup to the target table"
  handler       = "ddb_backup_and_restore.ddb_restore_table"
  runtime       = "${var.lambda_runtime}"
  timeout       = 60
  source_path = "${path.module}/../lambda_functions/ddb_backup_and_restore.py"

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.ddb_open_bar.json}"
}

module "get_table_status" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "ddb_get_table_status"
  description   = "DDB : return the status of the table"
  handler       = "ddb_backup_and_restore.ddb_get_table_status"
  runtime       = "${var.lambda_runtime}"
  timeout       = 60
  source_path = "${path.module}/../lambda_functions/ddb_backup_and_restore.py"

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.ddb_open_bar.json}"
}

module "update_table_capacity" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "ddb_update_table_capacity"
  description   = "DDB : update the table read and write capacity units"
  handler       = "ddb_backup_and_restore.ddb_update_table_capacity"
  runtime       = "${var.lambda_runtime}"
  timeout       = 60
  source_path = "${path.module}/../lambda_functions/ddb_backup_and_restore.py"

  attach_policy = true
  policy        = "${data.aws_iam_policy_document.ddb_open_bar.json}"
}
