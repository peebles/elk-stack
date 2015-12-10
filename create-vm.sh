#!/bin/bash
#
# Usage: $0 -p aws_profile_name -h hostname [-s security_group] [-v vpcid] [-i instance-type]
#
# Run this script with an aws profile name as an
# argument (the profile name is the name of a profile
# you have defined in $HOME/.aws/config).
#
# Security group defaults to the hostname argument.
#
# This will create a machine in AWS called $hostname.
#
# This script uses docker-machine, which would then
# obviously need to be installed on your machine.
#
# Also uses aws-cli (aws).  
#

while getopts ":p:h:s:v:" opt; do
    case $opt in
	p)
	    profile_name=$OPTARG
	    ;;
	h)
	    hostname=$OPTARG
	    ;;
	s)
	    security_group=$OPTARG
	    ;;
	v)
	    vpcid=$OPTARG
	    ;;
	i)
	    itype=$OPTARG
	    ;;
	\?)
	    echo "Usage: $0 -p aws_profile_name -h hostname [-s security_group] [-v vpcid]  [-i instance-type]"
	    ;;
    esac
done

if [[ ("$profile_name" = "") || ("$hostname" = "") ]]; then
    echo "Usage: $0 -p aws_profile_name -h hostname [-s security_group] [-v vpcid] [-i instance-type]"
    exit 1
fi

echo "Creating \"$hostname\" ..."

# parse the $HOME/.aws/config file.
function parse_aws {
    cat $1 | awk -F' ' '{
if ( $1 == "[default]" ) { profile="default"; }
else if ( substr($1,0,8) == "[profile" ) { profile=$2; gsub(/[\[\]]/,"",profile); }
else if ( substr($1,0,1) == "[" ) { profile=$1; gsub(/[\[\]]/,"",profile); }
else { printf("%s_%s=\"%s\"\n", profile, $1, $3); }
}'
}

# given a profile and an attribute, return
# the correct value from the $HOME/.aws/config.
function aws_value {
    local profile=$1
    local attr=$2
    pv=${profile}_${attr}
    eval "V=\$$pv"
    echo $V
}

eval $(parse_aws $HOME/.aws/config)
eval $(parse_aws $HOME/.aws/credentials)

# This will be created if it does not already
# exist.  If it gets created, you will need to
# use the AWS console to add rules for accessing
# the ports you need (port 80 specifically).
if [ ! -z "$security_group" ]; then
    SecurityGroup=$security_group
else
    SecurityGroup="${hostname}-sg"
fi
    
# The type of machine to create
InstanceType="t2.small"
if [ ! -z "$itype" ]; then
    InstanceType=$itype
fi

if [ -z "$vpcid" ]; then
    VpcId=$(aws ec2 --profile $profile_name describe-vpcs --query 'Vpcs[].[VpcId,IsDefault]' --output text|grep True|awk '{print $1}')
else
    VpcId=$vpcid
fi
azone=$(aws ec2 --profile $profile_name  describe-subnets --filters "Name=vpc-id,Values=$VpcId" --output text --query 'Subnets[0].AvailabilityZone')
Region=$(aws_value $profile_name "region")
Zone=${azone#$Region}

Key=$(aws_value $profile_name 'aws_access_key_id')
Secret=$(aws_value $profile_name 'aws_secret_access_key')

echo "Hostname     = $hostname"
echo "Access Key   = $Key"
echo "Secret       = $Secret"
echo "VPC ID       = $VpcId"
echo "Zone         = $Zone"
echo "Region       = $Region"
echo "Security Grp = $SecurityGroup"

docker-machine create --driver amazonec2 \
  --amazonec2-access-key $Key \
  --amazonec2-secret-key $Secret \
  --amazonec2-vpc-id $VpcId \
  --amazonec2-region $Region \
  --amazonec2-zone $Zone \
  --amazonec2-security-group $SecurityGroup \
  --amazonec2-instance-type $InstanceType \
  $hostname
