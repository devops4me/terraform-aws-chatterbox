
### ---> ###################### <--- ### || < ####### > || ###
### ---> ---------------------- <--- ### || < ------- > || ###
### ---> Instance Layer Modules <--- ### || < Layer I > || ###
### ---> ---------------------- <--- ### || < ------- > || ###
### ---> ###################### <--- ### || < ####### > || ###

module ec2-instance
{
    source                  = "github.com/devops4me/terraform-aws-ec2-instance-cluster"

    in_node_count           = "1"
    in_user_data            = "${ data.template_file.cloud_config.rendered }"
    in_iam_instance_profile = "${ module.ec2-instance-profile.out_ec2_instance_profile }"
    in_ssh_public_key       = "${ var.in_ssh_public_key }"

    in_ami_id               = "${ data.aws_ami.ubuntu-1804.id }"
    in_subnet_ids           = [ "${ element ( module.sub-network.out_public_subnet_ids, 0 ) }" ]
    in_security_group_ids   = [ "${ module.security-group.out_security_group_id }" ]

    in_ecosystem_name       = "${ var.in_ecosystem_name }"
    in_tag_timestamp        = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description      = "${ module.resource-tags.out_tag_description }"
}

module ec2-instance-profile
{
    source             = "github.com/devops4me/terraform-aws-ec2-instance-profile"
    in_policy_stmts    = "${ data.template_file.iam_policy_stmts.rendered }"
    in_ecosystem_name  = "${ var.in_ecosystem_name }"
    in_tag_timestamp   = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description = "${ module.resource-tags.out_tag_description }"
}


### ---> ##################### <--- ### || < ####### > || ###
### ---> --------------------- <--- ### || < ------- > || ###
### ---> Network Layer Modules <--- ### || < Layer N > || ###
### ---> --------------------- <--- ### || < ------- > || ###
### ---> ##################### <--- ### || < ####### > || ###

module sub-network
{
    source            = "github.com/devops4me/terraform-aws-sub-network"
    in_vpc_id         = "${ var.in_vpc_id }"
    in_vpc_cidr       = "${ var.in_vpc_cidr }"
    in_net_gateway_id = "${ var.in_gateway_id }"
    in_subnets_max    = "${ var.in_subnets_max }"
    in_subnet_offset  = "${ var.in_subnet_offset }"

    in_num_public_subnets   = 1
    in_num_private_subnets  = 0

    in_ecosystem_name      = "${ var.in_ecosystem_name }"
    in_tag_timestamp       = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description     = "${ module.resource-tags.out_tag_description }"
}

module security-group
{
    source      = "github.com/devops4me/terraform-aws-security-group"
    in_ingress  = [ "http", "https", "ssh" ]
    in_vpc_id   = "${ var.in_vpc_id }"

    in_ecosystem_name  = "${ var.in_ecosystem_name }"
    in_tag_timestamp   = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description = "${ module.resource-tags.out_tag_description }"
}

module resource-tags
{
    source = "github.com/devops4me/terraform-aws-resource-tags"
}
