# Answers

If break_workspace has been enabled, the following information may be of use:

## Triage

Use the terraform output in conjunction to increase the EC2 instance volume to 10GB:
```
aws ec2 modify-volume --size=10 --volume-id vol-05c4aaaaabvbss0dcca78 --region us-east-1
```

Login to the EC2 instance using the ssh string in the terraform output, sudo up and run

```
growpart /dev/nvme0n1 1
xfs_growfs /
```

## Fix

Ideally, a candidate should attempt to find the root cause and fix without expanding the volume.
