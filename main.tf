module "scheduler" {
  source = "github.com/Coaktion/terraform-aws-event-bridge-sns-scheduler-module"

  region     = var.aws_region
  account_id = var.account_id

  schedulers = [{
    name                = "${var.service.name}"
    description         = "This is a test scheduler"
    schedule_expression = var.schedule_expression
    mode                = "OFF"
    create_pubsub       = false
    topic_name          = var.topic_name
    queue_name          = ""
    input = jsonencode({
      "queues_prefix"     = var.queues_prefix,
      "messages_per_task" = var.messages_per_task,
      "cluster_name"      = var.cluster_name,
      "service_name"      = var.service.name,
      "min_tasks"         = var.service.autoscaling.min_capacity,
      "max_tasks"         = var.service.autoscaling.max_capacity,
    })
    timezone = "America/Sao_Paulo"
  }]
}
