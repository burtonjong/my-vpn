# MyVpn

Trying to make my own self hosted VPN with Terraform and Wireguard

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
