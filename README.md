## Scenario 1

### Security Group adjustments
#### Explanation:
>aws_security_group.allow_all

Observing the resources this security group is associated with and recognizing that the alb is only listening/forwarding traffic on `port 80`. This observation motivated my decision in adjusting this security to only accept ingress traffic on port 80 and egress traffic to the specified private subnets. Also changing the security group name to `allow_http`.

>aws_security_group.ec2_sg

I created a separate security group for the EC2 instances as the allow_http does not follow the guidelines of least privledge. This security group protects the ec2 instances by only allowing traffic that is forwarded from `aws_alb.alb` on `port 80`.

>---start, line **38** at ***network.tf***---
```terraform
/* Adjusting the security group to only allow HTTP traffic
Setting egress to private subnet cidr blocks*/
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private1.cidr_block, aws_subnet.private2.cidr_block, aws_subnet.private3.cidr_block]
  }
}

/* Security group associated with EC2 instances.
Only allowing inbound traffic forwarded from the ALB
*/
resource "aws_security_group" "ec2_sg" {
    name = "ec2_sg"
    description = "Allow inbound http traffic from ALB"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port  = 80
        protocol = "tcp"
        security_groups = [aws_security_group.allow_http.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
```
>---end, line **76** at ***network.tf***---


>---start, changes at line **21** at ***compute.tf***---
```terraform
vpc_security_group_ids = [aws_security_group.ec2_sg.id] #Updating security group to ec2_sg
```
>---end, changes on line **21** at ***compute.tf***---


### Application Load Balancer adjustments
#### Explanation:
>aws_lb.alb

Updated the application load balancer to reference the new security group "aws_security_group.allow_http".

>---start, changes on line **36**---
```
security_groups = [aws_security_group.allow_http.id] # Updating security group to allow_http
```
>---end, changes on line **36** at ***compute.tf***---


## Scenario 2

#### Explanation:
>expand_volume.sh

Assuming the mount point of the disk we are intending on expanding is located at root directory `/`,

This bash script will: 
1. Get the root devices working directory
2. Isolate the disk and partition number
3. Expands the disk using `sudo growpart $disk_ $partition_number`

```bash
#!/bin/bash
root_device=$(df / | awk 'NR==2 {print $1}')

#Isolating the disk and partition number
disk_=$(echo $root_device | sed -r 's/(.*[a-z])([0-9]+)$/\1/')
partition_number=$(echo $root_device | sed -r 's/.*[a-z]([0-9]+)$/\1/')

#Checking if the disk and partition number are empty
if [[ -z "$disk_" || -z "$partition_number" ]]; then 
    echo "Could not parse disk device from $root_device"
    exit 1
fi

#Expanding the disk
echo "Expanding disk $disk_ partition $partition_number"
sudo growpart $disk_ $partition_number
```