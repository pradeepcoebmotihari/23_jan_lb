#!/bin/bash
set -e
for i in `aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:ap-south-1:623240248731:targetgroup/firsttarget/79751f4508ef9c54 --query 'TargetHealthDescriptions[*].Target.Id' --output text`
do
aws elbv2 deregister-targets --target-group-arn arn:aws:elasticloadbalancing:ap-south-1:623240248731:targetgroup/firsttarget/79751f4508ef9c54 --targets Id=$i 
echo "[server]" > /etc/ansible/hosts
aws ec2 describe-instances --instance-ids $i |jq -r '.Reservations[].Instances[].PrivateIpAddress' >> /etc/ansible/hosts
ansible-playbook -e 'host_key_chaking=False' ansible.yaml --private-key=/home/id_rsa -u ansible --ssh-common-args='-o StrictHostKeyChecking=no'
sleep 330
aws elbv2 register-targets --target-group-arn arn:aws:elasticloadbalancing:ap-south-1:623240248731:targetgroup/firsttarget/79751f4508ef9c54 --targets Id=$i
done
