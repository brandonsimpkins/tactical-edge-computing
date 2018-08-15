

## Snowball Edge Setup

The [AWS Snowball Edge Developer Guide](https://docs.aws.amazon.com/snowball/latest/developer-guide/using-device.html)
has a lot of very good information, but the information is scattered and not
organized in a procedural format. These steps will alow you to initially unlock
and configure a Snowball Edge using EC2 services.

Note: These procedures assume that you have already ordered and recieved a
Snowball Edge.

### Initialize the Snowball Edge
01. Connect network and power cables to the Snowball Edge and power the device
    on.
    * The device is quite loud for the first 10 - 15 minutes.
    * These procedures assume that the Snowball Edge can obtain IP
      addresses through DHCP.
    * See the
      [Snowball Edge - Getting Started](https://docs.aws.amazon.com/snowball/latest/developer-guide/getting-started-connect.html)
      documentation if you have issues obtaining network connectivity.
02. Download and install the appropriate [Snowball Edge Client](https://aws.amazon.com/snowball-edge/resources/)
    * Note: The installation on MacOS left the client unusable since my root
      user `UMASK` is set to `0077` (as it should be). Setting my `UMASK` to
      `0022` worked fine for the install.
03. Log into the **AWS Console** and go to the **Snowball** Service.
    01. In the **Job Dashboard** expand the dropdown for the job you ordered the
        snowball with, and click the **Get Credentials** button.
    02. Save the **Client Unlock Code** and download the **Manifest File** to your
        local computer. I stored my credentials in my home directory like so:
        ```
        [bssimpk@MacBook tec-snowball-credentials]$ find $(pwd)
        /Users/bssimpk/tec-snowball-credentials
        /Users/bssimpk/tec-snowball-credentials/tec-snowball.cert
        /Users/bssimpk/tec-snowball-credentials/tec-snowball.manifest
        /Users/bssimpk/tec-snowball-credentials/tec-snowball.unlock_code

        [bssimpk@MacBook tec-snowball-credentials]$ cat tec-snowball.unlock_code
        XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
        ```
04. Once the Snowball Edge has powered on and established a network connection,
    get the IP address from the front panel display.
    * Commands below will reference the Snowball Edge IP Address as
      `10.200.10.105`

### Configure the Snowball Edge CLI
You will manage the Snowball Edge directly with the `snowballEdge` CLI. This is
_deceptively similar_ to the `aws` CLI, but it is very different! If commands
don't work, check to make sure you aren't using the wrong CLI.

01. Create a **Named Profile** for the `snowballEdge` CLI:
    ```
    [bssimpk@MacBook ~]$ snowballEdge configure --profile TEC
    Configuration will stored at /Users/bssimpk/.aws/snowball/config/snowball-edge.config
    Snowball Edge Manifest Path: /Users/bssimpk/tec-snowball-credentials/tec-snowball.manifest
    Unlock Code: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
    Default Endpoint: https://10.200.10.105
    ```

I opted to create the named profile `TEC`, since I will be working with
numerous Snowball Edge devices. I used the Manifest, Unlock Code, and
public IP address obtained above.

You can configure the default profile and remove the `--profile TEC` parameter
from the `snowballEdge` commands below.

If you don't configure a profile, subsequent `snowballEdge` commands will
require the following parameters:
* `--endpoint https://${snowball ip}`
* `--manifest-file ${manifest file name}`
* `--unlock-code ${unlock code}`


### Unlock The Snowball Edge
Once you unlock and initialize the Snowball Edge, you interact with it as if it
is a local region. You will need to obatin the Access Keys and configure an
AWS profile accordingly.

01. Unlock the Snowball Edge:
    ```
    [bssimpk@MacBook ~]$ snowballEdge unlock-device --profile TEC
    Your Snowball Edge device is unlocking. You may determine the unlock state of your device using the describe-device command. Your Snowball Edge device will be available for use when it is in the UNLOCKED state.
    ```
02. Verify that you can interact with services running on the Snowball Edge:
    ```
    [bssimpk@MacBook ~]$ snowballEdge list-services --profile TEC
    {
      "ServiceIds" : [ "s3", "ec2", "fileinterface" ]
    }
    ```

### Configure the AWS CLI
We will need to use the `snowballEdge` CLI to obtain the credentials to interact with the


01. Obtain an **Access Key** from the Snowball Edge:
    ```
    [bssimpk@MacBook ~]$ snowballEdge list-access-keys --profile TEC
    {
      "AccessKeyIds" : [ "ABCDEFGHIJKLMNOPQRST" ]
    }
    ```
02. Obtain the matching **Secret Access Key** from the Snowball Edge:
    ```
    [bssimpk@MacBook ~]$ snowballEdge get-secret-access-key --profile TEC --access-key-id ABCDEFGHIJKLMNOPQRST
    [snowballEdge]
    aws_access_key_id = ABCDEFGHIJKLMNOPQRST
    aws_secret_access_key = 0123456789abcdefghijklmnopqrstuvxyz01234
    ```
03. Save the keys in a **Named Profile** for the AWS CLI:
    ```
    bssimpk@MacBook ~]$ aws configure --profile TEC
    AWS Access Key ID [None]: ABCDEFGHIJKLMNOPQRST
    AWS Secret Access Key [None]: 0123456789abcdefghijklmnopqrstuvxyz01234
    Default region name [None]: us-west-2
    Default output format [None]: json
    ```
    * You need to specify a region in the profile, even though it doesn't
      actually get used.
    * You can view your **Named Profile** configuration by running:
      ```
      aws configure list --profile TEC
      ```
04. Find the **CertificateArn** for the snowball edge certificate:
    ```
    [bssimpk@MacBook ~]$ snowballEdge describe-service --service-id ec2
    {
      "ServiceId" : "ec2",
      "Status" : {
        "State" : "ACTIVE"
      },
      "Endpoints" : [ {
        "Protocol" : "http",
        "Port" : 8008,
        "Host" : "10.200.10.105"
      }, {
        "Protocol" : "https",
        "Port" : 8243,
        "Host" : "10.200.10.105",
        "CertificateAssociation" : {
          "CertificateArn" : "arn:aws:snowball-device:::certificate/7db3d80001d7d2b71a04ec0d4940775c"
        }
      } ]
    }
    ```
05. Get the certificate used by the EC2 service and save it to a file:
    ```
    [bssimpk@MacBook ~]$ snowballEdge get-certificate --profile TEC --certificate-arn arn:aws:snowball-device:::certificate/7db3d80001d7d2b71a04ec0d4940775c > tec-snowball.cert
    ```

    I saved the certificate in the same location as the manifest and the unlock codes.

    ```
    [bssimpk@MacBook tec-snowball-credentials]$ find $(pwd)
    /Users/bssimpk/tec-snowball-credentials
    /Users/bssimpk/tec-snowball-credentials/tec-snowball.cert
    /Users/bssimpk/tec-snowball-credentials/tec-snowball.manifest
    /Users/bssimpk/tec-snowball-credentials/tec-snowball.unlock_code
    ```
06. Add the Snowball Edge certificate to the `aws` CLI `TEC` profile to trust
    HTTPS connections.
    ```
    [bssimpk@MacBook ~]$ aws configure --profile TEC set ca_bundle /Users/bssimpk/tec-snowball-credentials/tec-snowball.cert
    ```
    Note: the [instructions for associating certificates with a profile](https://docs.aws.amazon.com/snowball/latest/developer-guide/using-adapter.html#adapter-credentials)
    do not appear to be correct. I was able to correctly add the `ca_bundle`
    setting to my `TEC` profile with the command above.
07. Verify That you can interact with the EC2 services on the Snowball Edge
    though the AWS CLI using the HTTPS protocol:
    ```
    [bssimpk@MacBook ~]$ aws ec2 --profile TEC describe-instances --endpoint https://10.200.10.105:8243
    {
        "Reservations": []
    }
    ```

### Create an EC2 Instance
At it's most basic, when you create a EC2 instance on a Snowball Edge you need
to:

01. Run an instance using an AMI as the base image.
02. Create a virtual network interface.
03. Attach the virtual network interface to the EC2 instance.

To create a EC2 instance and be able to connect to it:

01. List the images available on the Snowball Edge and find the `ImageId` for
    the AMI you want to use:
    ```
    [bssimpk@MacBook ~]$ aws ec2 --profile TEC describe-images --endpoint https://10.200.10.105:8243
    {
        "Images": [
            {
                "Description": "[Copied ami-b1574bce from us-east-1] tce-dev-image",
                "EnaSupport": false,
                "ImageId": "s.ami-07f9de7f",
                "State": "AVAILABLE",
                "Public": false,
                "Name": "tce-dev-image"
            }
        ]
    }
    ```
    In this case, my `ImageId` I want to use is `s.ami-07f9de7f`
02. Run an EC2 instance using the desired AMI `ImageId`:
    ```
    [bssimpk@MacBook ~]$ aws ec2 --profile TEC run-instances --image-id s.ami-07f9de7f --count 1 --instance-type sbe1.xlarge  --endpoint https://10.200.10.105:8243
    {
        "Instances": [
            {
                "SourceDestCheck": false,
                "InstanceId": "s.i-836058c13ba4da0b8",
                "EnaSupport": false,
                "ImageId": "s.ami-07f9de7f",
                "State": {
                    "Code": 0,
                    "Name": "pending"
                },
                "EbsOptimized": false,
                "AmiLaunchIndex": 0,
                "InstanceType": "sbe1.xlarge"
            }
        ],
        "ReservationId": "s.r-86a934fdad2275001"
    }
    ```
    * Currently, the available [Snowball Edge EC2 instance types](https://docs.aws.amazon.com/snowball/latest/developer-guide/using-ec2.html) are:
      * sbe1.small
      * sbe1.medium
      * sbe1.large
      * sbe1.xlarge
      * sbe1.2xlarge
      * sbe1.4xlarge
    * Specify the AMI
03. Get the `PhysicalNetworkInterfaceId` for the active Physical Network
    Interface.
    ```
    [bssimpk@MacBook ~]$ snowballEdge describe-device --profile TEC
    {
      "DeviceId" : "JID36036a19-29e4-41df-bf95-fe1caa5e178f",
      "UnlockStatus" : {
        "State" : "UNLOCKED"
      },
      "ActiveNetworkInterface" : {
        "IpAddress" : "10.200.10.105"
      },
      "PhysicalNetworkInterfaces" : [ {
        "PhysicalNetworkInterfaceId" : "s.ni-8b34890878bc0facc",
        "PhysicalConnectorType" : "RJ45",
        "IpAddressAssignment" : "DHCP",
        "IpAddress" : "10.200.10.105",
        "Netmask" : "255.255.252.0",
        "DefaultGateway" : "10.200.10.1",
        "MacAddress" : "0c:c4:7a:d3:63:06"
      }, {
        "PhysicalNetworkInterfaceId" : "s.ni-8da40ab73dcbf1991",
        "PhysicalConnectorType" : "QSFP",
        "IpAddressAssignment" : "STATIC",
        "IpAddress" : "0.0.0.0",
        "Netmask" : "0.0.0.0",
        "DefaultGateway" : "10.200.10.1",
        "MacAddress" : "0c:c4:7a:f6:14:2a"
      }, {
        "PhysicalNetworkInterfaceId" : "s.ni-8cc181ec17316a496",
        "PhysicalConnectorType" : "SFP_PLUS",
        "IpAddressAssignment" : "STATIC",
        "IpAddress" : "0.0.0.0",
        "Netmask" : "0.0.0.0",
        "DefaultGateway" : "10.200.10.1",
        "MacAddress" : "0c:c4:7a:d6:48:df"
      } ]
    }
    ```
    In my case, I am using the `RJ45` Physical Network Interface and the
    `PhysicalNetworkInterfaceId` I need to use is `s.ni-8b34890878bc0facc`
04. Create a virtual network interface associated with the active physical
    network interface.
    ```
    [bssimpk@MacBook ~]$ snowballEdge create-virtual-network-interface --ip-address-assignment DHCP --physical-network-interface-id s.ni-8b34890878bc0facc
    {
      "VirtualNetworkInterface" : {
        "VirtualNetworkInterfaceArn" : "arn:aws:snowball-device:::interface/s.ni-89d5fe0df8668e838",
        "PhysicalNetworkInterfaceId" : "s.ni-8b34890878bc0facc",
        "IpAddressAssignment" : "DHCP",
        "IpAddress" : "10.200.10.149",
        "Netmask" : "255.255.252.0",
        "DefaultGateway" : "10.200.10.1",
        "MacAddress" : "3e:81:c8:ad:28:1c"
      }
    }
    ```
    The allocated `IpAddress` value `10.200.10.149` will be associated with the
    EC2 Instance.
05. Associate the IP with the created EC2 Instance:
    ```
    [bssimpk@MacBook ~]$ aws --profile TEC ec2 associate-address --endpoint https://10.200.10.105:8243 --ca-bundle tec-snowball-job-2-uswest2.cert.pem --public-ip 10.200.10.149 --instance-id s.i-836058c13ba4da0b8
    ```
06. Verify the status of the EC2 instance:
    ```
    [bssimpk@MacBook ~]$ aws --profile TEC ec2 describe-instances --endpoint https://10.200.10.105:8243 --ca-bundle tec-snowball-job-2-uswest2.cert.pem
    {
        "Reservations": [
            {
                "Instances": [
                    {
                        "SourceDestCheck": false,
                        "InstanceId": "s.i-836058c13ba4da0b8",
                        "EnaSupport": false,
                        "ImageId": "s.ami-07f9de7f",
                        "State": {
                            "Code": 16,
                            "Name": "running"
                        },
                        "EbsOptimized": false,
                        "LaunchTime": "2018-08-09T21:11:02.194Z",
                        "PublicIpAddress": "10.200.10.149",
                        "AmiLaunchIndex": 0,
                        "InstanceType": "sbe1.xlarge",
                        "PrivateIpAddress": "34.211.108.9"
                    }
                ],
                "ReservationId": "s.r-86a934fdad2275001"
            }
        ]
    }
    ```

### Other Management Commands
You can find the documentation for the `aws ec2` CLI commands available
on the Snowball Edge
[here](https://docs.aws.amazon.com/snowball/latest/developer-guide/using-ec2-endpoint.html).

You can find the documentation for the `snowballEdge` CLI commands
[here](https://docs.aws.amazon.com/snowball/latest/developer-guide/using-client-commands.html).


* To list the existing virtual network interfaces:
  ```
  snowballEdge describe-virtual-network-interfaces --profile TEC
  {
    "VirtualNetworkInterfaces" : [ {
      "VirtualNetworkInterfaceArn" : "arn:aws:snowball-device:::interface/s.ni-89d5fe0df8668e838",
      "PhysicalNetworkInterfaceId" : "s.ni-8b34890878bc0facc",
      "IpAddressAssignment" : "DHCP",
      "IpAddress" : "10.200.10.171",
      "Netmask" : "255.255.252.0",
      "DefaultGateway" : "10.200.10.1",
      "MacAddress" : "3e:81:c8:ad:28:1c"
    } ]
  }
  ```
* To start EC2 instances on the Snowball Edge:

  Get the `InstanceId` from the output of the `aws ec2 describe-instances` command.

  Note: You need to associate a public IP address to the EC2 instance after starting it.

  ```
  [bssimpk@MacBook ~]$ aws ec2 start-instances --profile TEC --endpoint https://10.200.10.126:8243 --instance-ids s.i-836058c13ba4da0b8
  {
      "StartingInstances": [
          {
              "InstanceId": "s.i-836058c13ba4da0b8",
              "CurrentState": {
                  "Code": 0,
                  "Name": "pending"
              },
              "PreviousState": {
                  "Code": 80,
                  "Name": "stopped"
              }
          }
      ]
  }
  ```
* To stop EC2 instances on the Snowball Edge:

  Get the `InstanceId` from the output of the `aws ec2 describe-instances` command.

  ```
  [bssimpk@MacBook ~]$ aws ec2 stop-instances --profile TEC --endpoint https://10.200.10.126:8243 --instance-ids s.i-836058c13ba4da0b8
  ```







