variable "name-prefix" {}
variable "aws_region" {}

variable "natCount" {
  type    = number
  default = 2
}

variable "vpcCidr" {
  type    = string
  default = "10.36.0.0/16"
}

variable "PublicSubnet-List" {
  type = list(object({
    name    = string
    az      = number
    newbits = number
    netnum  = number
  }))
  default = [
    {
      name    = "Public-0"
      az      = 0
      newbits = 8
      netnum  = 10
    },
    {
      name    = "Public-1"
      az      = 1
      newbits = 8
      netnum  = 11
    }
  ]
}

variable "PrivateSubnet-List" {
  type = list(object({
    name    = string
    az      = number
    newbits = number
    netnum  = number
  }))
  default = [
    {
      name    = "Private-0"
      az      = 0
      newbits = 8
      netnum  = 20
    },
    {
      name    = "Private-1"
      az      = 1
      newbits = 8
      netnum  = 21
    }
  ]
}