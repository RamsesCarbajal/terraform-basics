module "webservice" {
  source = "../../../components/worker"
  base-name = var.base-name
  cluster-arn = var.cluster-arn
  deployment-tag = var.deployment-tag
  internal-security-group-id = var.internal-security-group-id
  repository-url = var.repository-url
  service-name = var.base-name
  standard-tags = var.standard-tags
  subnet-a-id = var.subnet-a-id
  subnet-b-id = var.subnet-b-id
  vpc-id = var.vpc-id
  desired-instances = 1
  secrets = [
    { name = "KAFKA_URL"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/KAFKA_URL"},
    { name = "KAFKA_TOPI"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/KAFKA_TOPI"},
    { name = "KAFKA_GROUP_ID"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/KAFKA_GROUP_ID"},
    { name = "AWS_PROFILE"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/AWS_PROFILE"},
    { name = "AWS_REGION"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/AWS_REGION"},
    { name = "ATHENA_DATABASE"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/ATHENA_DATABASE"},
    { name = "ATHENA_BUCKET"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/ATHENA_BUCKET"},
    { name = "ATHENA_BUCKET_RESULT"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/ATHENA_BUCKET_RESULT"},
    { name = "ATHENA_S3_BUCKET_RESULT"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/ATHENA_S3_BUCKET_RESULT"},
    { name = "URL_REPORT_GENERATOR"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/URL_REPORT_GENERATOR"},
    { name = "LOG_FILE"
      valueFrom = "arn:aws:ssm:us-east-1:565557057306:parameter/ReportsWorker/LOG_FILE"}
  ]
}