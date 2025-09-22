# Create a Serverless Web App on AWS: Greetings

## Introduction

This tutorial guides you through creating a serverless web application on AWS that displays "Hello World" greetings in different languages. The application uses AWS S3 for hosting the front-end, AWS Lambda and API Gateway for backend processing and DynamoDB to store the greetings. We'll walk through each step, ensuring you verify the functionality at each stage.

## Architecture Overview

The application follows this flow:

- **Frontend**: Static HTML hosted on S3
- **API**: API Gateway triggers Lambda functions
- **Backend**: Lambda functions process requests
- **Database**: DynamoDB stores greeting data

## Method

1. Develop a simple web page
2. Set up S3 for static website hosting
3. Create a basic Lambda function
4. Create API Gateway as a trigger
5. Develop the web page to show the Lambda response
6. Enable CORS
7. Add a DynamoDB table
8. Update the Lambda function to read from the DynamoDB table
9. Add IAM permissions

## Prerequisites

- An AWS account. If you don't have one, [sign up here](https://aws.amazon.com/)
- Basic familiarity with the AWS Management Console, AWS CLI, Python, HTML, and JavaScript

---

## Step 1: Develop a Simple Web Page

Create an `index.html` file with the following content:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Hello World!</title>
  </head>
  <body>
    <h1>Hello, World!</h1>
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
3. **Bucket name**: `greetings<date><time>` (The bucket name must be unique)
4. Click "Create bucket"

### Upload the Web Page

Upload the `index.html` file to your S3 bucket.

### Enable Static Website Hosting

1. Go to the **Properties** tab
2. Enable "Static website hosting" in the bucket properties
3. **Index document**: `index.html`
4. Press "Save changes"

### Configure Public Access

1. Go to the **Permissions** tab
2. Uncheck "Block public access" in the bucket permissions
3. Press "Save changes"

### Add Bucket Policy

⚠️ **Change the bucket name in the policy below!**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicAccessGetObject",
      "Principal": "*",
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::<bucket_name>/*"]
    }
  ]
}
```

Press "Save changes"

### ✅ Verify

Access the bucket URL (provided in the static website hosting settings) to ensure your web page loads.

---

## Step 3: Create a Basic Lambda Function

### Create a Lambda Function

1. Navigate to the Lambda service in the AWS Management Console
2. Click "Create function" and choose "Author from scratch"
3. **Function name**: `Greetings`
4. **Runtime**: Python
5. Expand "Change default execution role" and note the role created (`Greetings-role-<number>`)

### Lambda Function Code

```python
import json

def lambda_handler(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
```

### ✅ Verify

1. Use the "Test" feature in the Lambda console
2. Press "Test"
3. **Test event action**: Create new event
4. **Event name**: Test
5. Press "Save"
6. Press "Test" (again)

**Expected Response:**

```json
{
  "statusCode": 200,
  "body": "\"Hello from Lambda!\""
}
```

---

## Step 4: Create API Gateway as a Trigger

### Create an API Gateway

1. Press "+ Add trigger" in the Function Overview Diagram
2. Choose the API Gateway service
3. Create a new REST API
4. **Security**: Open
5. Press "Add"

### ✅ Verify

1. Navigate to the API Gateway service and select the newly created API
2. Go to the **Test** tab
3. **Method**: GET
4. Press "Test"
5. Check the Status and Response body

---

## Step 5: Develop the Web Page to Show the Lambda Response

### Update the HTML

Replace your `index.html` with:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Hello World!</title>
  </head>
  <body>
    <h1>Hello, World!</h1>

    <p id="greeting">Loading...</p>
    <script>
      async function fetchGreeting() {
        const response = await fetch('https://<API_URL>');
        const responseBody = await response.text();
        document.getElementById('greeting').innerText = responseBody;
      }
      fetchGreeting();
    </script>
  </body>
</html>
```

### ✅ Verify

1. Run `index.html` in your browser
2. Inspect the request using the browser development tool
3. Note the CORS error that occurs

---

## Step 6: Enable CORS

### Configure CORS in API Gateway

1. Navigate to API Gateway → Resources (`/Greetings`)
2. Click on "Enable CORS"
3. Press "Save"

### Update Lambda Function

Add CORS headers to the Lambda function response:

```python
import json

def lambda_handler(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'headers': {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token",
        },
        'body': json.dumps('Hello from Lambda!')
    }
```

⚠️ **Don't forget to Deploy the change!**

### ✅ Verify

1. Run `index.html` in your browser
2. Inspect the request using the browser development tool
3. Note the error is gone
4. The response "Hello from Lambda!" should show up on the page

---

## Step 7: Add a DynamoDB Table

### Create a DynamoDB Table

1. Navigate to the DynamoDB service and click on "Create Table"
2. **Table name**: `Greetings`
3. **Primary key**: `greeting`
4. Click on "Create Table"

### Add Items

1. Select the newly created table
2. Click on "Explore table items"
3. Click on "Create item"
4. Add two new records:
   - `"Hello World"`
   - `"Hej Världen"`

### ✅ Verify

Ensure the items are added correctly in the DynamoDB console.

---

## Step 8: Update Lambda Function to Read from DynamoDB

### Update Lambda Code

```python
import json
import boto3

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Greetings')  # Replace with your DynamoDB table name

def lambda_handler(event, context):
    # Scan the DynamoDB table
    result = table.scan()
    items = result['Items']

    return {
        'statusCode': 200,
        'headers': {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token",
        },
        'body': json.dumps(items)
    }
```

Deploy the updated Lambda function.

### ✅ Verify (First Attempt)

1. Run `index.html` in your browser
2. Inspect the request using the browser development tool
3. Note the permission error that occurs

---

## Step 9: Add IAM Permissions

### Configure IAM Role

1. In the Lambda service go to the **Configuration** tab
2. Select **Permissions** in the left hand menu
3. Press the link to the role used by the lambda service
4. Click "Add permissions → Attach policies"
5. Check the "AmazonDynamoDBFullAccess" policy
6. Press "Add permissions"

### ✅ Verify

1. Run `index.html` in your browser
2. Inspect the request using the browser development tool
3. Note the error is gone
4. The response `[{"greeting": "Hello World"}, {"greeting": "Hej Världen"}]` should show up on the page

---

## Step 10: Display JSON Response as a List

### Update HTML to Show List

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Hello World!</title>
  </head>
  <body>
    <h1>Hello, World!</h1>

    <ul id="greetingsList">
      <li>Loading...</li>
    </ul>
    <script>
      async function fetchGreeting() {
        const response = await fetch('<API_URL>');
        const responseBody = await response.json();
        const greetingsList = document.getElementById('greetingsList');
        greetingsList.innerHTML = ''; // Clear the loading message
        responseBody.forEach((item) => {
          const listItem = document.createElement('li');
          listItem.textContent = item.greeting;
          greetingsList.appendChild(listItem);
        });
      }
      fetchGreeting();
    </script>
  </body>
</html>
```

### ✅ Verify

1. Run `index.html` in your browser
2. Verify that a list of greetings is shown on the page
3. Add a record in the DynamoDB table and refresh the page to see the new record presented

---

## Step 11: Upload Final Version to S3

### Upload the Finished Web Page

Upload the final `index.html` file to your S3 bucket.

### ✅ Final Verification

Access the web page hosted on S3 and verify it displays the correct greetings.

---

## Final Thoughts

This tutorial demonstrates a step-by-step approach to creating a serverless web application using AWS services. By following these steps, you should have a functional web app that displays greetings sourced from DynamoDB.

## Cleanup

Remove resources you no longer need to avoid unnecessary costs:

- **S3** bucket and contents
- **Lambda** function
- **API Gateway**
- **DynamoDB** table
- **IAM Role**

---

**Happy Serverless Developing on AWS!** 🚀
