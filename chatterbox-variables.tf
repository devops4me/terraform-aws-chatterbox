
######## ################### ########
######## Mandatory Variables ########
######## ################### ########

variable in_vpc_id             { description = "The ID of the existing VPC in which to create the subnet network."  }
variable in_vpc_cidr           { description = "The CIDr block defines the range of VPC allocable IP addresses."    }
variable in_subnets_max        { description = "Two to the power of subnets_max is the carvable subnets quantity."  }
variable in_subnet_offset      { description = "The number of subnets to skip over in the existing VPC."            }
variable in_gateway_id         { description = "The internet gateway ID of the existing VPC for routing traffic."   }
variable in_ssh_public_key     { description = "The public SSH key for accessing the secure shell of the instance." }
variable in_safe_local_db_id   { description = "The id of the local safe database."                                 }
variable in_safe_remote_db_id  { description = "The id of the remote safe database."                                }
variable in_safe_book_name     { description = "The name of the safe database book."                                }
variable in_safe_book_password { description = "The password of the safe database book."                            }
variable in_dot_username       { description = "The username to the dot (devops task platform."                     }
variable in_dot_password       { description = "The password to the dot (devops task platform."                     }
variable in_dot_repo_path      { description = "The dot repository url, group name and repository name."            }
variable in_dot_fullname       { description = "The full name of she who talks to the dot platform."                }
variable in_dot_email_address  { description = "The email address of she who talks to the platform."                }
variable in_ecosystem_name     { description = "Creational name stamp denoting the class of this eco-system."       }


######## ######################################### ######
######## This Terraform Module's Output Variables. ######
######## ######################################### ######

output public_ip_addresses
{
    value  = "${ module.ec2-instance.out_public_ip_addresses }"
}


######## ########################### ######
######## The terraform data objects. ######
######## ########################### ######

/*
 | --
 | -- This cloud config yaml is responsible for the configuration management
 | -- (through user data) of the ec2 instance (or instances).
 | --
 | -- The documentation for cloud-config directives and their parameters can
 | -- be found through this link.
 | --
 | --
 | --     https://cloudinit.readthedocs.io/en/latest/index.html
 | --
*/
data template_file cloud_config
{
    template = "${ file( "${path.module}/cloud-config.yaml" ) }"
    vars
    {
        safe_local_db_id   = "${ var.in_safe_local_db_id }"
        safe_remote_db_id  = "${ var.in_safe_remote_db_id }"
        safe_book_name     = "${ var.in_safe_book_name }"
        safe_book_password = "${ var.in_safe_book_password }"

        dot_username       = "${ var.in_dot_username }"
        dot_password       = "${ var.in_dot_password }"
        dot_repo_path      = "${ var.in_dot_repo_path }"
        dot_fullname       = "${ var.in_dot_fullname }"
        dot_email_address  = "${ var.in_dot_email_address }"
    }
}


data template_file iam_policy_stmts
{
    template = "${ file( "${path.module}/chatterbox-policies.json" ) }"
}


data aws_ami ubuntu-1804
{
    most_recent = true

    filter
    {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter
    {
        name   = "virtualization-type"
        values = [ "hvm" ]
    }

    owners = ["099720109477"]
}
