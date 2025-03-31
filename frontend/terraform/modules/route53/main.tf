module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 3.0"

  zones = {
    (var.domain_name) = {
      comment = "${(var.domain_name)} (production)"
      tags = {
        env = "production"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}