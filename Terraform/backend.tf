terraform {
  required_version = "1.15.2"

  backend "s3" {
    bucket         = "kubevision-tf-state-114223852322-us-east-1-an"               
    key            = "kubevision/terraform.tfstate"   
    region         = "us-east-1"                      
    encrypt        = true                             
  }
}
