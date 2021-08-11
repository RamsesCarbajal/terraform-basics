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
  name_base      = "reports-generator-alpha"
  deployment-tag = "sandbox"
  domain         = "funds-liquidations.conekta.party"

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
  name = "reports-generator"
}

data "aws_iam_role" "ecs_task_role"{
  name = "ecsTaskExecutionRole"
}

data "aws_iam_role" "ecs_task_execution_role"{
  name = "ecsTaskExecutionRole"
}

module "reports_backend" {
  source = "../../../../../../modules/apps/reports-generator/backend"
  app-port = 8080
  app_name = "reportsGenerator"
  aws-region = "us-east-1"
  base-name = "reportsBackend"
  brokers = 2
  certificate-arn = local.network.certificate-arn
  cluster_arn = data.aws_ecs_cluster.default.arn
  deployment-tag = "sandbox"
  ecr_url = data.aws_ecr_repository.default.repository_url
  environment = "sandbox"
  execution_role_arn = data.aws_iam_role.ecs_task_role.arn
  internal_security_group = local.network.internal-security-group-id
  kafka_client_subnets = [local.network.subnet-a-id, local.network.subnet-b-id]
  kafka_security_groups = [local.network.internal-security-group-id]
  public-http-security-group-id = local.network.public-http-security-group-id
  security_groups = [local.network.internal-security-group-id]
  subnet-a-id = local.network.subnet-a-id
  subnet-b-id = local.network.subnet-b-id
  task_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  vpc_id = local.network.vpc-id
  kafka_version = "2.4.1.1"
  kafka_instance_size = "kafka.m5.large"
  standard-tags = {}
  domain = "reports-generator.conekta.party"
  enabled = true
}
