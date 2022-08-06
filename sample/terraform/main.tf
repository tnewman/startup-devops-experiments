module "network" {
  source = "../../terraform/modules/network"

  suffix     = "-dev"
  region     = "us-east-2"
}
