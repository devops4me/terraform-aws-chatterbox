
#### Use the chatterbox when you want to either say a lot of things (like when performance testing a queue) or listen to a lot (like to a huge Kubernetes log stream).

# chatterbox | ec2 instance

This chatterbox ec2 instance is a terraform module designed for when

- you want to **send or receive a lot of data** during a conversation with cloud infrastructure
- your VPN is way too slow to handle the potentially volumous interaction
- you are troubleshooting and/or performing relatively short-lived use case interactions


---


## module usage


---


## secure shell (ssh) | secure copy (scp)

The plan is to copy the key to the chatterbox, SSH onto it and then ssh onto instances within private subnets.

**`scp -C -i ~/.ssh/box-key.pem ~/.ssh/box-key.pem ubuntu@<<public-ip-address>>:~/box-key.pem`**
**`ssh ubuntu@<<public.ip.address>> -i ~/.ssh/box-key.pem`**
**`ssh core@<<private.ip.address>> -i box-key.pem`**

Note that if an ssh error occurs it may be solvable using a **`ssh-keygen`** command with the minus R switch.

**`ssh-keygen -R <<primate-ip-address`**


---


## coreos troubleshooting

Once you are on CoreOS there are a raft of commands  that enable you to track down and eradicate bugs.

**[Visit here to see those commands.](https://github.com/devops4me/rabbitmq-systemd-cloud-config)**  



## Information Gathering Commands

```bash

docker logs fluentd.box   # AWESOME command if fluentd fails for some reason

docker ps -a                              # Is our container running?
docker logs rabbitmq                      # Tell me the docker viewpoint?
etcdctl cluster-health                 # Health of etcd cluster nodes?
journalctl --unit rabbitmq.service        # Examine the service
journalctl --unit fluentd.service        # Examine the service
journalctl --identifier=ignition --all    # look at the ignition logs
systemctl list-unit-files                 # Is your service in this list?
journalctl --unit coreos-metadata.service # Examine the fetched metadata
journalctl --unit docker.socket           # Did docker start okay?
journalctl --unit network-online.target   # Did the network come onlie?
cat /etc/systemd/system/rabbitmq.service  # Print the systemd unit file
cat /etc/systemd/system/fluentd.service  # Print the systemd unit file
sudo systemctl start rabbitmq         # Will service startup fine?
systemctl status rabbitmq                 # Is service enabled or what?
systemctl cat rabbitmq                    # Print the systemd unit file
journalctl --unit etcd-member.service     # Examine the ETCD 3 service
etcdctl ls / --recursive                  # list the keys that etcd has
```


## Checking S3 Access on CoreOS | Does EC2 instance have it?

With an **AWS CLI docker container** we can check whether an EC2 instance has the necessary **role profile** to

- list all S3 Buckets
- list the contents of one bucket
- write a file into a bucket

### List all S3 Buckets

```bash
sudo rkt run docker://quay.io/coreos/awscli \
      --insecure-options=image \
      --dns=8.8.8.8 \
      --exec aws -- --region eu-central-1 s3 ls
```

**`awscli[5]: An error occurred (AccessDenied) when calling the ListBuckets operation: Access Denied`**

This error means no!

### List S3 Bucket Contents

Replace the **`<<s3-bucket-name>>`** placeholder.

```bash
sudo rkt run docker://quay.io/coreos/awscli \
    --insecure-options=image \
    --dns=8.8.8.8 \
    --exec aws -- --region eu-central-1 s3 ls s3://<<s3-bucket-name>>
```


### Put object into S3 Bucket

If you replace the **`<<s3-bucket-name>>`** placeholder with an existing bucket name these commands create a file and put it into your S3 bucket if the EC2 instance has the needful role profile. We then list the bucket's contents for good measure.

```bash
echo "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" >> alphabet.txt
echo "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" >> alphabet.txt
echo "cccccccccccccccccccccccccccccccccccccccc" >> alphabet.txt
echo "dddddddddddddddddddddddddddddddd" >> alphabet.txt
cat alphabet.txt
```

```bash
sudo rkt run docker://quay.io/coreos/awscli \
    --insecure-options=image \
    --dns=8.8.8.8 \
    --volume data,kind=host,source=$PWD/alphabet.txt,readOnly=true \
    --mount volume=data,target=/tmp/alphabet.txt \
    --exec aws -- --region eu-central-1 s3 cp /tmp/alphabet.txt s3://<<s3-bucket-name>>
```

```bash
sudo rkt run docker://quay.io/coreos/awscli \
    --insecure-options=image \
    --dns=8.8.8.8 \
    --exec aws -- --region eu-central-1 s3 ls s3://<<s3-bucket-name>>
```
