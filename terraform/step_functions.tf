data "aws_iam_policy_document" "lambda_invoke_functions" {
  statement {
    sid = "LambdaInvokeFunctions"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "lambda_invoke_functions" {
  name   = "lambda_invoke_functions"
  policy = "${data.aws_iam_policy_document.lambda_invoke_functions.json}"
}

resource "aws_iam_role" "sfn" {
  name = "sfn_to_invoke_lambda_functions"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.eu-west-1.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sfn_lambda_invoke_functions" {
    role       = "${aws_iam_role.sfn.name}"
    policy_arn = "${aws_iam_policy.lambda_invoke_functions.arn}"
}

data "template_file" "sfn_state_machine" {
  template = "${file("templates/sfn_state_machine.json")}"
  vars {
    backup_table_fn_arn          = "${module.backup_table.function_arn}"
    get_backup_status_fn_arn     = "${module.get_backup_status.function_arn}"
    delete_table_fn_arn          = "${module.delete_table.function_arn}"
    restore_table_fn_arn         = "${module.restore_table.function_arn}"
    get_table_status_fn_arn      = "${module.get_table_status.function_arn}"
    update_table_capacity_fn_arn = "${module.update_table_capacity.function_arn}"
  }
}

resource "aws_sfn_state_machine" "ddb_table_backup_and_restore" {
  name     = "DDB_table_backup_and_restore"
  role_arn = "${aws_iam_role.sfn.arn}"

  definition = "${data.template_file.sfn_state_machine.rendered}"
}