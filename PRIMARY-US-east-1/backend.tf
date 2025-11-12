terraform {
  backend "s3" {
    bucket         = "mybuckletprojects3"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true # Enables S3 native state locking(versions of Terraform(e.g., 1.9 and later))
    # dynamodb_table = "terraform-state-locking" #add dynamodb table name ->any version we can use dynamodb state locking (DynamoDB table must have a partition key named LockID)
    # encrypt = true
  }
}








