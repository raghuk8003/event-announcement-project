# 🚀 Event Announcement Project

A serverless architecture to register new events and subscribe users via email using **AWS services** and automated entirely with **Terraform (IaC)**.

> ✅ All resources were deployed using Terraform and destroyed after verification to avoid billing surprises.

## 🔗 Live Preview (Now Inactive)
The website was hosted on S3 with static web hosting and public access. All backend logic used Lambda and API Gateway.  
🧪 Tested and confirmed via SNS email subscriptions and API endpoints.

---

## 🧩 Phased Breakdown

### 📌 Phase 1: Static Website Deployment on S3
- Created an S3 bucket for hosting the event registration form.
- Enabled static website hosting and set public access policies.

### 📌 Phase 2: Lambda & API Gateway Setup
- Created two Lambda functions:
  - `EventRegistrationLambda`: Handles new event POSTs.
  - `SubscriptionLambda`: Handles email subscriptions to SNS.
- Connected these Lambda functions with API Gateway using `AWS_PROXY`.

### 📌 Phase 3: IAM Roles & SNS Integration
- Created an `IAM Role` (`lambda_exec_role`) with:
  - `AmazonS3FullAccess`
  - `AWSLambdaBasicExecutionRole`
  - `Custom LambdaSNSPublish` policy
- Created SNS Topic: `event-announcement-topic`
- Email subscriptions confirmed via SNS.

### 📌 Phase 4: End-to-End Validation
- Used Postman/cURL to POST requests to API Gateway endpoints.
- Verified:
  - Emails received and confirmed.
  - Events successfully registered.
  - Function execution logs from CloudWatch.

---

## 📦 Tech Stack

- **AWS**: Lambda, S3, API Gateway, SNS, IAM, CloudWatch
- **IaC**: Terraform (HashiCorp Configuration Language)
- **Languages**: Python (Lambda), HCL (Terraform)

---

## 📁 Explore the Code

The project also contains complete Terraform configuration files to spin up the architecture from scratch.

👉 [Explore the code on GitHub](https://github.com/Azharshaikh11/event-announcement-project)

---

## 🧹 Cleanup

✅ Successfully ran `terraform destroy` to delete all cloud resources after project completion.

---

## 👨‍💻 Built by Azhar Shaikh

Feel free to ⭐ the repo or fork for your own AWS-based event management system!
