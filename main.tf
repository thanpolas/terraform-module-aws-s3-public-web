terraform {
  required_version = ">= 0.12.19"
}

provider "aws" {
  alias = "main"
}

provider "aws" {
  alias = "virginia"
}
