resource "aws_s3_bucket" "input_company_ledgers" {
  bucket = "input-company-ledgers"
  acl    = "private"

  tags = {
    Name = "input-company-ledgers"
  }
}

resource "aws_s3_bucket" "output_company_ledgers" {
  bucket = "output-company-ledgers"
  acl    = "private"

  tags = {
    Name = "output-company-ledgers"
  }
}

module "kafka" {
  source  = "../../../components/kafka"
  base_name = "consumer-kafka"
  kafka_client_subnets = var.kafka_client_subnets
  kafka_security_groups = var.kafka_security_groups
  brokers = var.brokers
  environment = var.environment
  kafka_version = var.kafka_version
  kafka_instance_size = var.kafka_instance_size
}

module "webservice" {
  source = "../../../components/webservice"
  app-port = var.app-port
  aws-region = var.aws-region
  base-name = var.base-name
  certificate-arn = var.certificate-arn
  cluster-arn = var.cluster_arn
  deployment-tag = var.deployment-tag
  enabled = var.enabled
  internal-security-group = var.internal_security_group
  public-http-security-group-id = var.public-http-security-group-id
  repository-url = var.ecr_url
  service-name = var.app_name
  standard-tags = var.standard-tags
  subnet-a-id = var.subnet-a-id
  subnet-b-id = var.subnet-b-id
  vpc-id = var.vpc_id
  healthcheck-grace-seconds = 45
  secrets_environment = [
    { name = "POSTGRES_USER"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/POSTGRES_USER"},
    { name = "POSTGRES_PASSWORD"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/POSTGRES_PASSWORD"},
    { name = "POSTGRES_DB"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/POSTGRES_DB"},
    { name = "POSTGRES_SSL_MODE"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/POSTGRES_SSL_MODE"},
    { name = "POSTGRES_HOST"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/POSTGRES_HOST"},
    { name = "POSTGRES_PORT"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/POSTGRES_PORT"},
    { name = "RETRIES"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/RETRIES"},
    { name = "TIMEOUT"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/TIMEOUT"},
    { name = "SERVICE_HOST"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/SERVICE_HOST"},
    { name = "SERVICE_PORT"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/SERVICE_PORT"},
    { name = "SQL_DEBUG"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/SQL_DEBUG"},
    { name = "LOG_FILE"
    valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/LOG_FILE"},
    { name = "KAFKA_URL"
    valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/KAFKA_URL"},
    { name = "KAFKA_TOPIC"
    valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsBackend/KAFKA_TOPIC"}
  ]
}

module "domain" {
  source = "../../../components/domain"
  domain = var.domain
  target = module.webservice.balancer-dns-name
}