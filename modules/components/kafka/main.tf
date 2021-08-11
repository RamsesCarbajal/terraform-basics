resource "aws_cloudwatch_log_group" "cloudwatch_kafka_internal" {
  name = "msk_broker_logs_${var.base_name}_${var.environment}"
}

resource "aws_msk_cluster" "msk_internal_kafka" {
  cluster_name           = "${var.base_name}-${var.environment}"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.brokers

  broker_node_group_info {
    instance_type   = var.kafka_instance_size
    ebs_volume_size = 1000
    client_subnets  = var.kafka_client_subnets
    security_groups = var.kafka_security_groups
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
    }
  }
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.cloudwatch_kafka_internal.name
      }
    }
  }
  tags = {
    Name = "${var.base_name}-${var.environment}"
  }
}
