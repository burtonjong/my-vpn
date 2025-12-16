# MyVpn

Trying to make my own self hosted VPN with Terraform and Wireguard

## Getting the project working

1. You'll have to cd into the `terraform` folder first:

```bash
cd terraform
```

2. And then you can run the appropriate terraform workflow:

```bash
terraform validate
terraform plan
terraform apply
```

3. This step is optional, but just to see that it's working, since I have the SSM agent configured on the EC2 instance, you can use SSM to connect to it. Details to do that are in [Development Note 1](#development-note-1).

You can then run:

```bash
cat /var/log/user-data.log
```

And then you should see a log that says that the wireguard server was properly setup. For further validation you can run this:

```bash
sudo wg show
```

This will show you proof that wireguard is running and what the traffic status is. You can also see how many clients are connected

4. You should be able to access the wireguard client config in parameter store now.

# Development Note

Things that I took note of when I was creating this project

## Development Note 1

In solar car one of my teammates (david) told me that his work used SSM to SSH into instances instead of opening a port for SSH as it is more secure. So, I decided that for this project I would try and configure the SSM agent on my wireguard instance.

After applying the plan, you can use this command:

```bash
aws ssm describe-instance-information
```

And you should get a response like this:

```bash
{
    "InstanceInformationList": [
        {
            "InstanceId": "i-xxxxxxxxxx",
            "PingStatus": "Online",
            "LastPingDateTime": "2025-12-11T19:31:07.841000-07:00",
            "AgentVersion": "3.3.3050.0",
            "IsLatestVersion": false,
            "PlatformType": "Linux",
            "PlatformName": "Amazon Linux",
            "PlatformVersion": "2023",
            "ResourceType": "EC2Instance",
            "IPAddress": "10.0.x.x",
            "ComputerName": "ip-10-0-x-x.ca-central-1.compute.internal"
        }
    ]
}
```

And then we can connect to the instance via SSM with this command:

```bash
aws ssm start-session --target i-xxxxxxxxxxxxxxxxxx

# after, you should get something like:

Starting session with SessionId: burton-37pjhgvsejb7d9vdfgd8rqeb4a
sh-5.2$
```

If you get a message saying that `SessionManagerPlugin` is not found (which happened to me), you have to install it. I installed it via scoop:

```bash
scoop bucket add extras (if not already added)
scoop install aws-session-manager-plugin
```

## Development Note 2

This line is so that when Terraform replaces the instance it will rerun the user data script. This is useful so that I don't have to tell it do that (although I will probably comment it out eventually once I'm done this project)

```
  user_data_replace_on_change = true
```

## Development Note 3

I'm still not 100% on the principle of least privilege or how to implement it at least...

For this role polciy to allow the EC2 instance to store in SSM parameter store, I defined the resource block as such, but I'm not sure if this is the best way to do so? If this ever comes up again I'll have to look into it again.

```
resource "aws_iam_role_policy" "ssm_parameter_store" {
  name = "ssm-parameter-store-access"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:GetParameter",
          "ssm:DeleteParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/wireguard/*"
      }
    ]
  })
}
```
