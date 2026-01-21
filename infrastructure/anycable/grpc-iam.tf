data "aws_iam_policy_document" "grpc_task" {
  statement {
    sid    = "AllowAllActions"
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "grpc_task" {
  name   = "${local.grpc_name}-ecs-task-policy"
  policy = data.aws_iam_policy_document.grpc_task.json
}

resource "aws_iam_role_policy_attachment" "grpc_task" {
  role       = module.grpc.task_role_name
  policy_arn = aws_iam_policy.grpc_task.arn
}

data "aws_iam_policy_document" "grpc_task_execution" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/application/*",
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/database/*",
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/ava/*/config/database/*",
      "arn:aws:ssm:${var.region}:${local.account_id}:parameter/migration/GITHUB_TOKEN"
    ]
  }
}

resource "aws_iam_policy" "grpc_task_execution" {
  name   = "ava-grpc-execution"
  policy = data.aws_iam_policy_document.grpc_task_execution.json
}


resource "aws_iam_role_policy_attachment" "grpc_task_execution" {
  role       = module.grpc.task_execution_role_name
  policy_arn = aws_iam_policy.grpc_task_execution.arn
}
