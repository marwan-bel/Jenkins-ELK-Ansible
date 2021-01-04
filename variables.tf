variable "ansibleFilter" {
  description = "`ansibleFilter` tag value added to all instances, to enable instance filtering in Ansible dynamic inventory"
  default     = "Jenkins01" # IF YOU CHANGE THIS YOU HAVE TO CHANGE instance_filters = tag:ansibleFilter=??????? in ./ansible/hosts/ec2.ini
}
variable "owner" {

  default = "Marwan"


}
