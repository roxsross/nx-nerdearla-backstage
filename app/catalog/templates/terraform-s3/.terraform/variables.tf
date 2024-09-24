variable "aws_region" {
  default = "${{ values.region }}"
}

variable "project" {
  default = "${{ values.name }}"
}

variable "defualt_tags" {
  default = {
    "Project" = "${{ values.name }}"
    "Team" = "${{ values.team }}"
    "Environment" = "dev"
  }
}
