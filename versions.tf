terraform {
  required_version = ">= 1.1.7"
  required_providers {
    aws = {
      version               = "~> 4.4"
      configuration_aliases = [aws.useast1]
    }
  }
}
