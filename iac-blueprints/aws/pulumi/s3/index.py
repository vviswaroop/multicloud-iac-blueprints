"""
Pulumi program to create an S3 bucket with comprehensive configuration options

Below are steps to install pulumi and deploy stack

pip install pulumi-aws

pulumi up
"""

import pulumi
from pulumi_aws import s3

# Define stack configuration
config = pulumi.Config()

# Configuration parameters with defaults
bucket_name = config.get("bucketName")
acl = config.get("acl", "private")
object_ownership = config.get("objectOwnership", "BucketOwnerEnforced")
object_lock_enabled = config.get_bool("objectLockEnabled", False)
bucket_region = config.get("region", "us-east-1")

# Validate ACL
valid_acls = ["private", "public-read", "public-read-write", "authenticated-read"]
if acl not in valid_acls:
    raise ValueError(f"Invalid ACL. Must be one of: {valid_acls}")

# Validate Object Ownership
valid_ownerships = ["BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"]
if object_ownership not in valid_ownerships:
    raise ValueError(f"Invalid object ownership. Must be one of: {valid_ownerships}")

# Create the bucket
bucket = s3.Bucket(
    "myBucket",
    bucket=bucket_name,
    acl=acl,
    object_lock_enabled=object_lock_enabled,
    versioning={
        "enabled": True,
    },
    server_side_encryption_configuration={
        "rule": {
            "applyServerSideEncryptionByDefault": {
                "sseAlgorithm": "AES256",
            },
        },
    },
    ownership_controls={
        "rules": [{
            "objectOwnership": object_ownership,
        }],
    },
    block_public_access={
        "blockPublicAcls": True,
        "blockPublicPolicy": True,
        "ignorePublicAcls": True,
        "restrictPublicBuckets": True,
    },
)

# Create bucket policy to enforce HTTPS
bucket_policy = s3.BucketPolicy(
    "bucketPolicy",
    bucket=bucket.id,
    policy=bucket.id.apply(
        lambda bucket_name: {
            "Version": "2012-10-17",
            "Statement": [{
                "Sid": "SecureTransport",
                "Effect": "Deny",
                "Principal": "*",
                "Action": "s3:*",
                "Resource": [
                    f"arn:aws:s3:::{bucket_name}",
                    f"arn:aws:s3:::{bucket_name}/*",
                ],
                "Condition": {
                    "Bool": {
                        "aws:SecureTransport": "false"
                    }
                }
            }]
        }
    )
)

# Export the bucket information
pulumi.export("bucket_name", bucket.id)
pulumi.export("bucket_arn", bucket.arn)
pulumi.export("bucket_domain_name", bucket.bucket_domain_name)