variable "group_name" {}

variable "group_location" {}

variable "subnet_id" {}

variable "as_backends_add_pool" {}

variable "image_id" {
  default = "/subscriptions/ef314f22-873a-4fce-8baa-74af90e23731/resourceGroups/Containers/providers/Microsoft.Compute/images/kickscooter-golden-image"
}
