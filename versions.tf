terraform {
  required_version = ">= 1.8.1"
  required_providers {
    aws = {
      version               = ">= 5.46.0"
      configuration_aliases = [aws.useast1]
    }
  }
}
