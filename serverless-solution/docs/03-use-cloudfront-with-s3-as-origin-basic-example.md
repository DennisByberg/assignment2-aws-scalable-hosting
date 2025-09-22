# Use CloudFront with S3 as Origin: Basic Example

## Introduction

This tutorial will walk you through setting up a new S3 bucket hosting a simple `index.html` page and integrating it with Amazon CloudFront for secure and optimized content delivery. By the end of this guide, you'll have a CloudFront distribution configured with an S3 origin and secured with HTTPS.

## Architecture Overview

The application follows this flow:

- **S3 Bucket**: Stores static HTML content
- **CloudFront**: CDN that caches and delivers content globally
- **OAC (Origin Access Control)**: Secures S3 bucket access
- **HTTPS**: Enforces secure connections

## Prerequisites

- An active AWS account

---

## Step 1: Develop a Simple Web Page

### Create an HTML File

Create an `index.html` file with the following content:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My CloudFront Example</title>
  </head>
  <body>
    <h1>Welcome to my CloudFront-secured website!</h1>
  </body>
</html>
```

### ✅ Verify

Use your web browser and go to `file://<path>/index.html`

---

## Step 2: Set Up S3 for Static Website Hosting

### Create an S3 Bucket

1. Navigate to the S3 service in the AWS Management Console
2. Click "Create bucket"
3. **Bucket name**: `cloudfrontdemo<date><time>` (The bucket name must be unique)
4. Click "Create bucket"

### Upload the Web Page

Upload the `index.html` file to your S3 bucket.

---

## Step 3: Create a CloudFront Distribution

### Set Up CloudFront

1. Navigate to the **CloudFront** service in the AWS Management Console
2. Click **Create Distribution**

#### Configuration Settings

- **Origin Domain**: Select your S3 bucket from the dropdown
- **Origin access**: Select **Origin access control settings**
- Press the button **Create new OAC**
- In the popup keep default values and press **Create**
- **Viewer protocol policy**: Select **Redirect HTTP to HTTPS**
- **WAF**: Select **Do not enable security protections**
- **Default root object**: Enter `index.html`
- Click **Create Distribution**

⏳ **Wait** for the status to change from **Deploying** to **Deployed**. This may take a few minutes.

### Adjust S3 Bucket Policy for CloudFront Access

1. In the yellow banner click **Copy Policy**
2. Follow the link in the banner to get to your S3 Bucket
3. Navigate to the **Permissions** tab
4. Edit the **Bucket Policy**
5. Paste in the policy
6. **Save Changes**

---

## Step 4: Verify Your CloudFront Distribution

### Test the Distribution

1. Once deployed, copy the **Domain Name** of your CloudFront distribution (e.g., `d123abc456.cloudfront.net`)
2. Open this domain in your web browser. You should see your `index.html` page served securely via CloudFront
3. **Try to use HTTP as well. What happens?**

### Expected Behavior

- ✅ **HTTPS**: `https://d123abc456.cloudfront.net` → Shows your page securely
- 🔄 **HTTP**: `http://d123abc456.cloudfront.net` → Automatically redirects to HTTPS

---

## Conclusion

Congratulations! You've successfully set up an S3 bucket with `index.html` as the origin for CloudFront. Your content is now served with:

- **Lower latency** through global edge locations
- **Secure HTTPS** connections
- **Scalability benefits** provided by CloudFront
- **Origin Access Control** for secure S3 access

## Benefits of This Setup

- **Performance**: Content cached at edge locations worldwide
- **Security**: HTTPS enforced, S3 bucket not publicly accessible
- **Cost Effective**: Reduced data transfer costs from S3
- **Reliability**: Built-in redundancy and failover

## Cleanup

To avoid unnecessary costs, remove these resources when done:

- **CloudFront Distribution** (disable first, then delete)
- **S3 Bucket** and contents
- **OAC (Origin Access Control)** settings

---

**Happy Secure Surfing on AWS!** 🚀
