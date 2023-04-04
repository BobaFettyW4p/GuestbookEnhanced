variable "table_name" {
  type    = string
  default = "guestbook"
}

variable "write_function_name" {
  type    = string
  default = "write_to_guestbook"
}

variable "read_function_name" {
  type    = string
  default = "read_from_guestbook"
}

variable "domain_name" {
  type    = string
  default = "guestbook.mivancic.com"
}