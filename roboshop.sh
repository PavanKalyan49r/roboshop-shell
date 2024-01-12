#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-03f8f4d516bfc9736 #replace with your sg_id
INSTANCES=("mongodb" "redis" "mysql" "rabitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z0318892E6XHJ09MU47M
DOMAIN_NAME="pavanaws.online"

for -i in "${INSTANCES[@]}"
do
  if[ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
  then
    INSTANCE_TYPE="t3.small"
  else
    INSTANCE_TYPE="t2.micro"
fi

IP_ADDRESS=$(aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-03f8f4d516bfc9736 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instance[0].PrivateIpAddress' --output text)
  echo "$i:$IP_ADDRESS"

#CREATE R53 RECORD, MAKE SURE YOU DELETE EXISTING RECORD
aws route53 change-resource-record-sets \
  --hosted-zone-id 1234567890ABC \
  --change-batch '
  {
    "Comment": "creating a record set"
    ,"Changes": [{
      "Action"              : "CREATE"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$i'.'$DOMAIN_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP_ADDRESS"
        }]
      }
    }]
  }
  '
done