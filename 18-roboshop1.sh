#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5" #Replace with your AMI ID
SG_ID="sg-052c76aba2d33b868" #Replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "forntend") #Number of instances with their names.
ZONE_ID="Z051120136E8EIBY61NGW" #Replace with your ZONE ID
DOMAIN_NAME="arohvya.online" #Replace with your DOMAIN NAME

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

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating or Updating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$instance'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }
done
#Manikantha