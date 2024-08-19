# ECS queues based autoscaling

## Description

This module creates an ECS cluster and service with an autoscaling configuration based on a custom metric that represents the number of messages per task.
To update the metric value, the module creates a Event bridge scheduler that runs in a given cron expression and sends a message to a SNS topic. The topic triggers a lambda function that updates the metric value.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "test" {
  source = "../"

  account_id          = "12345678912"
  aws_region          = "us-east-1"
  messages_per_task   = 4
  schedule_expression = "rate(2 minutes)"
  queues_prefix       = "teste__"

  topic_name     = "process_queues"
  cluster_name   = "test-scaling"
  create_cluster = true
  service = {
    name          = "test-service"
    desired_count = 1
    autoscaling = {
      max_capacity            = 10
      min_capacity            = 1
      use_alarms              = false
    }
    task_definition = {
      cpu         = 512
      memory      = 1024
      family_name = "test-task"
      container_definitions = [
        {
          name                    = "test-container"
          repository_name         = "example-repository"
          create_repository_setup = false
          portMappings = [
            {
              containerPort = 80
              hostPort      = 80
              protocol      = "tcp"
            }
          ]
        }
      ]
    }
    network = {
      subnets_tags         = {
				key	 = "Name"
				values = ["test-subnet"]
			}
      security_groups_tags = {
				key	 = "Name"
				values = ["test-sg"]
			}
    }
  }
}

```

## Autoscaling method
The autoscaling can be triggered by alarms or using the [Autoscaling lambda](https://github.com/Coaktion/process-queues-lambda). This is defined by the variable use_alarms on the example below.

example using alarm:
````
  service = {
    name          = "test-service"
    desired_count = 1
    autoscaling = {
      max_capacity            = 10
      min_capacity            = 1
      metric_target_value     = 4
      scale_up_cooldown       = 30
      scale_down_cooldown     = 60
      scale_up_alarm_period   = 60
      scale_down_alarm_period = 120
    }
````
example using only the lambda:
````
  service = {
    name          = "test-service"
    desired_count = 1
    autoscaling = {
      max_capacity            = 10
      min_capacity            = 1
      use_alarm               = false
    }
````


## Network configuration

You can use the `vpc` property inside the `service` to create a new VPC or use an existing one by setting the `network` property with your *subnets* and *security groups*.

## Create autoscaling only

If you only want to create autoscaling for an existing service. Set the `create_cluster` and `create_service` variables to false. After that, define the cluster name and service name and autoscaling rules
