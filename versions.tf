terraform {
  required_version = ">= 1.2.1"
  required_providers {
    aws = {
      version               = "~> 5.0"
      configuration_aliases = [aws.useast1]
    }
  }
}
