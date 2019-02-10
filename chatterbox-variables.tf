######## ################### ########
######## Mandatory Variables ########
######## ################### ########

variable in_vpc_id { description = "The ID of the existing VPC in which to create the subnet network." }
variable in_vpc_cidr { description = "The CIDr block defining the range of IP addresses allocated to this VPC." }
variable in_subnets_max { description = "Two to the power of in_subnets_max is the ma number of subnets carvable from the VPC." }
variable in_subnet_offset { description = "The number of subnets already carved out of the existing VPC to skip over." }
variable in_gateway_id { description = "The internet gateway ID of the existing VPC." }
variable in_ecosystem_id { description = "Creational name stamp denoting the class of this eco-system." }
variable in_ssh_public_key { description = "The public SSH key for accessing the secure shell of the instance." }

########## ########################### ######
########## The terraform data objects. ######
########## ########################### ######

/*
 | --
 | -- This cloud config yaml is responsible for the configuration management
 | -- (through user data) of the ec2 instance (or instances).
 | --
 | -- The documentation for cloud-config directives and their parameters can
 | -- be found at this url below.
 | --
 | --
 | --     https://cloudinit.readthedocs.io/en/latest/index.html
 | --
*/
data template_file cloud_config
{
    template = "${ file( "${path.module}/cloud-config.yaml" ) }"
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
