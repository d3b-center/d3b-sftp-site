# 0001 - AWS Transfer for SFTP

- Status: Accepted

- [Context and Problem Statement](#context-and-problem-statement)
  - [Decision Drivers](#decision-drivers)
  - [Considered Options](#considered-options)
- [Decision Outcome](#decision-outcome)
  - [Option 1 Tradeoffs](#option-1-tradeoffs)
  - [Option 2 Tradeoffs](#option-2-tradeoffs)
  - [Option 3 Tradeoffs](#option-3-tradeoffs)
  - [Option 4 Tradeoffs](#option-4-tradeoffs)
- [What is AWS Transfer Family?](#what-is-the-aws-transfer-family)
  - [Managing users and directories in the Transfer Family service](#managing-users-and-directories-in-the-transfer-family-service)
- [Consequences](#consequences)
- [Links](#links)

## Context and Problem Statement

We were asked by the D3b imaging team to provide a way for external sites to transfer pathology images to our S3 storage buckets. Since external sites may have their own concerns about sharing PHI, this solution should allow security teams from those sites to review the configuration in case they have concerns about sharing data.

This could also be used by Clinical Research Coordinators inside of CHOP to upload data that has been sent by external sites by other means to S3 without needing to onboard them to our AWS environment. Once those files are uploaded, we'd like to trigger a [Pathology ETL pipeline](https://github.com/d3b-center/Path-ETL) on each image to remove PHI and allow it to be used for research purposes.

Based on these considerations, we decided to look into providing an SFTP endpoint that could be accessed by different users inside and outside of the CHOP Research organization to allow securely moving files to an S3 bucket we manage, which led us to discover the [AWS Transfer Family](https://aws.amazon.com/aws-transfer-family/) of services.

### Decision Drivers

- The users uploading pathology images would be non-technical staff who would need to be able to interact with our file transfer interface without needing to use the command line while keeping their files seperate from those of other users.
- These files may contain PHI, so the solution needs to be HIPAA compliant, and can only use HIPAA-Compliant AWS services.
- Different users may need to have different workflows with their data after it is uploaded. For example, imaging team may need to trigger a batch workflow using step functions while bioinformatics may need to start an Airflow DAG after a new file is uploaded.
- DevOps is a small team that does not have the bandwidth to manage intricate custom solutions. Relying on managed services is preferred.
- Configuration should be written in a way where it can be shared publically so it can be reviewed by security orgs from outside partners.

### Considered Options

- **Option 1:** Create an EC2 instance with an SFTP endpoint, then allow users to upload to it with S3 mounted with [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse). Users can upload via a graphical SFTP client like [FileZilla](https://filezilla-project.org/) or the command line SFTP utility.
- **Option 2:** Use [AWS Transfer family](https://aws.amazon.com/aws-transfer-family/) with web application as found in [AWSLabs sample](https://github.com/awslabs/web-client-for-aws-transfer-family). Users would login and upload files through web interface.
- **Option 3:** Use [AWS Transfer Family](https://aws.amazon.com/aws-transfer-family/) with password-based authentication, similar to solution from [AWS Storage Blog](https://aws.amazon.com/blogs/storage/enable-password-authentication-for-aws-transfer-family-using-aws-secrets-manager-updated/). Users would upload via [FileZilla](https://filezilla-project.org/) or the SFTP command-line utility.
- **Option 4:** Create individual IAM users for each site with limited IAM credentials to upload to a specific prefix in that bucket, and provide a login to the AWS portal to access that bucket/path in the S3 console.

## Decision Outcome

**Chosen option:** We chose **Option 3** because it addresses all of the decision drivers without creating additional overhead for the DevOps team. We knew that we could use AWS Transfer for SFTP to reduce overhead. SFTP is also something that non-technical users can access securely through native integration with their operating system (Except for Windows, which has other SFTP client alternatives) or through an interface like [FileZilla](https://filezilla-project.org/).

AWS Transfer for SFTP is also a [HIPAA-Compliant AWS service](https://docs.aws.amazon.com/pdfs/whitepapers/latest/architecting-hipaa-security-and-compliance-on-aws/architecting-hipaa-security-and-compliance-on-aws.pdf), meaning that we can configure this service to safely transmit PHI in any account with a signed BAA with AWS.

We also intend to setup an [AWS Transfer Family Custom Identity Provider](https://docs.aws.amazon.com/transfer/latest/userguide/gateway-api-tutorial.html) as defined in the AWS Documentation for the Transfer Family. This will allow us to setup individual users and manage their home directories in the service.

### Option 1 Tradeoffs

We decided not to use Option 1 defined above for the following reasons:

1. It would mean more work administrativly for our team to create, harden, and manage an EC2 instance
1. Any errors with S3 Fuse or the instance itself might present an error to the end user that would decrease confidence in our system.
1. Providing an instance with a public IP address would increase our attack surface for our account, even if the instance was properly hardened and in a seperate VPC.

### Option 2 Tradeoffs

Option 2 was our preferred approach for our end users, as the web portal is easier for non-technical staff to use than command-line and some sites may not allow a graphical application to be installed.

However, this approach requires a significant amount of infrastrucure in addition to the transfer server and authentication mechanism, including an ECS service with several tasks, an ALB, and Cognito User Pools. This would create a lot of overhead to make it PHI compliant and reviewable to the public.

We decided not to choose this approach for the reasons above. We may choose to revisit this if a future service is made available to simplify deployment and management of a HIPAA compliant web portal, or we recieve additional funding for development on this project.

### Option 3 Tradeoffs

Option 3 is a solution we felt comfortable using, as it allows our users to use a variety of SFTP clients to upload files while providing a familiar authentication mechanism. (Username and Password)

This does have a drawback of leaving the investigation and installation of an SFTP client up to the end user, or each site specifically, but the infrastructure that client can connect to will be secured.

The option to use AWS Transfer family will also allow us to trigger workflows for each file uploaded, also fitting our need for running additional workflows and processing.

### Option 4 Tradeoffs

Option 4 would fit our requirement for user-friendly upload mechanism, but would require addtional overhead to manage seperate roles and prefixes for each user.

Each user would need a seperate policy pointing to a specific path in the bucket in order to keep each user's files seperate.

## What is the AWS Transfer Family?

The [AWS Transfer Family](https://aws.amazon.com/aws-transfer-family/) is a service in AWS that offers a fully-managed FTP, SFTP, FTPS, or AS2 endpoint that connects directly to either an S3 bucket or an EFS volume. That being said, at the time of this commit, only the SFTP server is PHI Compliant, and the others should not be used to transfer identifiable data.

Authorized users of the SFTP can be managed within the Transfer Family service itself using that user's SSH keys, through a directory such as ADFS, or using a custom authentication mechanism like a Lambda function that stores user credentials in AWS Secrets Manager.

Once data has been uploaded using a Transfer Family endpoint, it can trigger a workflow that can copy, tag, delete and/or call a custom Lambda function to run custom processing on that file.

### Managing users and directories in the Transfer Family service

When using the AWS Transfer Family service with a custom identity provider as described in the AWS Documentation, users are enumerated by the name given in their corresponding entry in Secrets Manager, where their user profiles are also defined.

User Profiles need to be named with the pattern `<Transfer_Family_server_ID>/<UserName>` in AWS Secrets Manager, and have the following parameters defined and stored as an `Other` type of secret:

1. **Password**: The user's password
1. **Role**: The ARN of the IAM role that they will assume while connecting to SFTP
1. **HomeDirectoryDetails**: A map of what a user will see as their home directory and where that directory will map to in the S3 bucket. In this map, `${transfer:UserName}` can be used to substitute the name of the user that is connected to the SFTP endpoint.

```json
{
    "Password":"<User's Password>",
    "Role":"<ARN for IAM role to assume when transferring>",
    "HomeDirectoryDetails":"[
        {
            "Entry": "/",                                            # The user will see this as their home directory when logging into the SFTP server.
            "Target": "/<Bucket Name>/<Prefix>/${transfer:UserName}" # The path for their directory in the SFTP server.
        }
    ]"}
```

## Consequences

- D3b DevOps will add terraform configuration for the AWS Transfer for SFTP using an S3 backend, as well as IAM roles, secrets manager entries for users, and the Lambda with API gateway described in the [AWS Storage Blog](https://aws.amazon.com/blogs/storage/enable-password-authentication-for-aws-transfer-family-using-aws-secrets-manager-updated/) article.
- D3b DevOps will provide a mechanism to add/remove users and manage their upload paths.
- D3b DevOps will work with Imaging and Bioinformatics units to setup appropriate test scenarios with internal and external users and work through any issues with the workflow.
- D3b DevOps will provide documentation for how to access in this repository once provided the proper credentials.
- D3b Imaging/Bioinformatics teams will provide users and their desired upload paths, as well as adding/removing users as necessary.
- At a later date, a second ADR may be necessary for evaluating Transfer Family Workflows as a way to process data after it's been uploaded and how to implement them.

## Links

- [AWS Transfer Family](https://aws.amazon.com/aws-transfer-family/)
- [AWS Transfer Family Custom Identity Provider](https://docs.aws.amazon.com/transfer/latest/userguide/gateway-api-tutorial.html)
- [AWS Storage Blog Article](https://aws.amazon.com/blogs/storage/enable-password-authentication-for-aws-transfer-family-using-aws-secrets-manager-updated/)
- [FileZilla](https://filezilla-project.org/)
