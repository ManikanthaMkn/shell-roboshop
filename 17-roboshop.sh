#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-052c76aba2d33b868"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "forntend")
ZONE_ID="Z051120136E8EIBY61NGW"
DOMAIN_NAME="arohvya.online"

for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t2.micro --security-group-ids sg-052c76aba2d33b868 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    
    if [ $instance != "forntend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0]. Instances[0].PrivateIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0]. Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance IP address: $IP"
done