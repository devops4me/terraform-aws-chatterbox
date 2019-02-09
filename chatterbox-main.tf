
### ---> ##################### <--- ### || < ####### > || ###
### ---> --------------------- <--- ### || < ------- > || ###
### ---> Instance Layer Module <--- ### || < Layer I > || ###
### ---> --------------------- <--- ### || < ------- > || ###
### ---> ##################### <--- ### || < ####### > || ###

resource aws_instance machine
{
    instance_type          = "m4.large"
    ami                    = "${ data.aws_ami.ubuntu-1804.id }"
    subnet_id              = "${ element ( module.sub-network.out_public_subnet_ids, 0 ) }"
    vpc_security_group_ids = [ "${ module.security-group.out_security_group_id }" ]
    iam_instance_profile   = "${ module.s3-instance-profile.out_profile_name }"
    user_data              = "${ data.template_file.cloud_config.rendered }"

    root_block_device
    {
        volume_size = "64"
    }

    tags
    {
        Name     = "ec2-${ local.ecosystem_id }-${ module.resource-tags.out_tag_timestamp }"
        Class    = "${ local.ecosystem_id }"
        Instance = "${ local.ecosystem_id }-${ module.resource-tags.out_tag_timestamp }"
        Desc     = "AI server instance being used by Stathis for artificial intelligence ${ module.resource-tags.out_tag_description }"
    }
}



### ---> ##################### <--- ### || < ####### > || ###
### ---> --------------------- <--- ### || < ------- > || ###
### ---> Network Layer Modules <--- ### || < Layer N > || ###
### ---> --------------------- <--- ### || < ------- > || ###
### ---> ##################### <--- ### || < ####### > || ###

/*
 | --
 | -- This module creates a VPC and then allocates subnets in a round robin manner
 | -- to each availability zone. For example if 8 subnets are required in a region
 | -- that has 3 availability zones - 2 zones will hold 3 subnets and the 3rd two.
 | --
 | -- Whenever and wherever public subnets are specified, this module knows to create
 | -- an internet gateway and a route out to the net.
 | --
*/
module sub-network
{
    source            = "github.com/devops4me/terraform-aws-sub-network"
    in_vpc_id         = "${ local.the_vpc_id }"
    in_vpc_cidr       = "${ local.the_vpc_cidr }"
    in_net_gateway_id = "${ local.the_net_gateway_id }"
    in_subnets_max    = "${ local.the_subnets_max }"
    in_subnet_offset  = "${ local.the_subnet_offset }"

    in_num_public_subnets   = 1
    in_num_private_subnets  = 0

    in_ecosystem_name      = "${ local.ecosystem_id }"
    in_tag_timestamp       = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description     = "${ module.resource-tags.out_tag_description }"
}

/*
 | --
 | -- This AI server only requiress SSH access in and an alternative
 | -- http port numbered 8888.
 | --
*/
module security-group
{
    source      = "github.com/devops4me/terraform-aws-security-group"
    in_ingress  = [ "http", "https", "ssh" ]
    in_vpc_id   = "${ local.the_vpc_id }"

    in_ecosystem_name  = "${ local.ecosystem_id }"
    in_tag_timestamp   = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description = "${ module.resource-tags.out_tag_description }"
}



output public_ip_addresses
{
    value  = "${ aws_instance.machine.*.public_ip }"
}


module s3-instance-profile
{
    source = "github.com/devops4me/terraform-aws-s3-instance-profile"

    in_ecosystem_name  = "${ local.ecosystem_id }"
    in_tag_timestamp   = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description = "${ module.resource-tags.out_tag_description }"
}


/*
 | --
 | -- Remember the AWS resource tags! Using this module, every
 | -- infrastructure component is tagged to tell you 5 things.
 | --
 | --   a) who (which IAM user) created the component
 | --   b) which eco-system instance is this component a part of
 | --   c) when (timestamp) was this component created
 | --   d) where (in which AWS region) was this component created
 | --   e) which eco-system class is this component a part of
 | --
*/
module resource-tags
{
    source = "github.com/devops4me/terraform-aws-resource-tags"
}
