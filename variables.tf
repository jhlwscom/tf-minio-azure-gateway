variable "prefix" {
  description = "The prefix used for all resources"
  default = "fairdev"
}

variable "location" {
  description = "The Azure location where all resources should be created"
  default = "uksouth"
}

variable "subscription" {
  description = "The Azure subscription to place resources in"
}