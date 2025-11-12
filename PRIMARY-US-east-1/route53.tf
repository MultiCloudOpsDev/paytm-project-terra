#Use existing Route 53 hosted zone
data "aws_route53_zone" "existing" {
  name         = "shrii.shop"
  private_zone = false
}


#Route 53 record → Frontend ALB
resource "aws_route53_record" "frontend_dns" {
  zone_id = data.aws_route53_zone.existing.zone_id
  name    = "shrii.shop"
  type    = "A"

  alias {
    name                   = aws_lb.front_end.dns_name
    zone_id                = aws_lb.front_end.zone_id
    evaluate_target_health = true
  }
}

#Route 53 record → Backend ALB
resource "aws_route53_record" "backend_dns" {
  zone_id = data.aws_route53_zone.existing.zone_id
  name    = "backend.shrii.shop"
  type    = "A"

  alias {
    name                   = aws_lb.back_end.dns_name
    zone_id                = aws_lb.back_end.zone_id
    evaluate_target_health = true
  }
}


#Create Private Hosted Zone
resource "aws_route53_zone" "private_zone" {
  name = "shrii.shop"
  vpc {
    vpc_id = aws_vpc.three-tier.id
  }
  comment       = "Private DNS zone for internal RDS"
  force_destroy = true
}

#Use existing Route 53 private hosted zone
# data "aws_route53_zone" "private" {
#   name         = "shrii.shop"
#   private_zone = true
# }

#Associate existing private zone with your new VPC
# resource "aws_route53_zone_association" "private_zone_assoc" {
#   zone_id = data.aws_route53_zone.private.zone_id
#   vpc_id  = aws_vpc.three-tier.id
# }

#Create Private DNS Record → RDS Endpoint
resource "aws_route53_record" "rds_record" {
  #zone_id = data.aws_route53_zone.private.zone_id     #if not using exsiting private zone just cmmt this line
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "rds.shrii.shop"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.rds.address]    # RDS endpoint
}
