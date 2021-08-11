data "terraform_remote_state" "baseline" {
  backend = "s3"
  config = {
    bucket  = "s3-conektasb-tfs"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "conektasb"
  }
}

locals {
  name_base      = "reports-worker-alpha"
  deployment-tag = "sandbox"

  common-parameters = yamldecode(file("${path.module}/../../../../../../parameters.yml"))
  network           = data.terraform_remote_state.baseline.outputs.common-network

  standard-tags = {
    "Owner" : local.common-parameters.teams.engineering,
    "Conekta:Application" : "ReportsGenerator"
    "Conekta:Platform" = "MerchantReports"
  }
}

data "aws_ecs_cluster" "default" {
  cluster_name = "tf-architecture"
}

data "aws_ecr_repository" "default" {
  name = "reports-backend"
}

data "aws_iam_role" "ecs_task_role"{
  name = "ecsTaskExecutionRole"
}

data "aws_iam_role" "ecs_task_execution_role"{
  name = "ecsTaskExecutionRole"
}

module "reports_worker" {
  source = "../../../../../../modules/apps/reports-generator/task"
  base-name = "reportsWorker"
  cluster-arn = data.aws_ecs_cluster.default.arn
  deployment-tag = "sandbox"
  internal-security-group-id = local.network.internal-security-group-id
  repository-url = data.aws_ecr_repository.default.repository_url
  standard-tags = {}
  subnet-a-id = local.network.subnet-a-id
  subnet-b-id = local.network.subnet-b-id
  vpc-id = local.network.vpc-id
}
