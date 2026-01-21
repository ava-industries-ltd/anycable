data "aws_iam_policy_document" "anycable_task" {
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

resource "aws_iam_policy" "anycable_task" {
  name   = "${local.anycable_name}-ecs-task-policy"
  policy = data.aws_iam_policy_document.anycable_task.json
}

resource "aws_iam_role_policy_attachment" "anycable_task" {
  role       = module.anycable.task_role_name
  policy_arn = aws_iam_policy.anycable_task.arn
}

data "aws_iam_policy_document" "anycable_task_execution" {
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

resource "aws_iam_policy" "anycable_task_execution" {
  name   = "ava-anycable-execution"
  policy = data.aws_iam_policy_document.anycable_task_execution.json
}


resource "aws_iam_role_policy_attachment" "anycable_task_execution" {
  role       = module.anycable.task_execution_role_name
  policy_arn = aws_iam_policy.anycable_task_execution.arn
}
