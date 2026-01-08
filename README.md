# Donut Flavors - AWS DevOps Project

**IS 590R DevOps - Chapter 8 Group Project**

A Flask-based CRUD web application for managing donut flavors, deployed on AWS using Infrastructure as Code (Terraform) with a complete CI/CD pipeline.

## Project Features & Points Breakdown

| Feature | Points | Status |
|---------|--------|--------|
| CodePipeline + CodeDeploy + GitHub + EC2 + RDS + VPC | 23.25 | Included |
| Infrastructure as Code (Terraform) including RDS | 1.0 | Included |
| Non-Node Application (Python/Flask) | 1.0 | Included |
| Auto Scaling Group | 0.5 | Included |
| Load Balancer via IaC | 0.5 | Included |
| **Total** | **26.25** | **Max 25** |

## Architecture Overview

```
                    ┌─────────────────┐
                    │    Internet     │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Internet Gateway│
                    └────────┬────────┘
                             │
              ┌──────────────▼──────────────┐
              │     Application Load        │
              │        Balancer             │
              │      (Public Subnets)       │
              └──────────────┬──────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
    ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
    │   EC2   │         │   EC2   │   ...   │   EC2   │
    │(Private)│         │(Private)│         │(Private)│
    └────┬────┘         └────┬────┘         └────┬────┘
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
                    ┌────────▼────────┐
                    │   RDS MySQL     │
                    │   (Private)     │
                    └─────────────────┘
```

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured (`aws configure`)
3. **Terraform** installed (v1.0+)
4. **GitHub Account** with a repository for this project
5. **SSH Key Pair** created in AWS EC2

## Quick Start

### Step 1: Clone/Push to GitHub

First, create a new GitHub repository and push this project:

```bash
cd "chapter 8 group project"
git init
git add .
git commit -m "Initial commit - Donut Flavors app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### Step 2: Create SSH Key Pair (if needed)

```bash
aws ec2 create-key-pair --key-name donut-app-key --query 'KeyMaterial' --output text > donut-app-key.pem
chmod 400 donut-app-key.pem
```

### Step 3: Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
aws_region    = "us-east-1"
key_name      = "donut-app-key"
db_password   = "YourSecurePassword123!"
github_owner  = "your-github-username"
github_repo   = "your-repo-name"
github_branch = "main"
github_token  = "ghp_your_github_token"
```

### Step 4: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes (type 'yes' when prompted)
terraform apply
```

### Step 5: Activate GitHub Connection

After Terraform creates the resources:

1. Go to AWS Console → Developer Tools → Connections
2. Find the pending connection for your project
3. Click "Update pending connection"
4. Authorize AWS to access your GitHub account
5. Select your repository

### Step 6: Trigger Initial Deployment

Push any change to your GitHub repo to trigger the pipeline:

```bash
git commit --allow-empty -m "Trigger pipeline"
git push
```

### Step 7: Access Your Application

After deployment completes (~5-10 minutes):

```bash
# Get the ALB URL
terraform output alb_url
```

Open the URL in your browser to see the Donut Flavors app!

## Project Structure

```
chapter 8 group project/
├── app/                          # Flask Application
│   ├── app.py                    # Main application code
│   ├── requirements.txt          # Python dependencies
│   └── templates/                # HTML templates
│       ├── base.html
│       ├── index.html
│       ├── add.html
│       ├── edit.html
│       └── view.html
├── terraform/                    # Infrastructure as Code
│   ├── provider.tf               # AWS provider config
│   ├── variables.tf              # Input variables
│   ├── vpc.tf                    # VPC, subnets, gateways
│   ├── security_groups.tf        # Security groups
│   ├── rds.tf                    # MySQL database
│   ├── ec2.tf                    # Auto Scaling Group
│   ├── alb.tf                    # Load Balancer
│   ├── codedeploy.tf             # CodeDeploy config
│   ├── codepipeline.tf           # CI/CD Pipeline
│   ├── outputs.tf                # Output values
│   ├── user_data.sh              # EC2 bootstrap script
│   └── terraform.tfvars.example  # Example variables
├── scripts/                      # CodeDeploy scripts
│   ├── before_install.sh
│   ├── after_install.sh
│   ├── start_server.sh
│   ├── stop_server.sh
│   └── validate_service.sh
├── appspec.yml                   # CodeDeploy specification
└── README.md                     # This file
```

## Infrastructure Components

### Networking (VPC)
- **VPC**: 10.0.0.0/16 CIDR block
- **Public Subnets**: For ALB and NAT Gateway (2 AZs)
- **Private Subnets**: For EC2 and RDS (2 AZs)
- **Internet Gateway**: Public internet access
- **NAT Gateway**: Private subnet internet access

### Compute (EC2)
- **Launch Template**: Amazon Linux 2023, t2.micro
- **Auto Scaling Group**: Min 2, Max 4 instances
- **CloudWatch Alarms**: CPU-based scaling

### Database (RDS)
- **Engine**: MySQL 8.0
- **Instance**: db.t3.micro
- **Storage**: 20GB GP2 (auto-scales to 100GB)
- **Multi-AZ**: Disabled (enable for production)

### Load Balancing (ALB)
- **Type**: Application Load Balancer
- **Listener**: HTTP on port 80
- **Health Check**: /health endpoint

### CI/CD Pipeline
- **CodePipeline**: Orchestrates the deployment
- **Source**: GitHub via CodeStar Connections
- **Deploy**: CodeDeploy with rolling updates

## Application Features

The Donut Flavors app provides:

- View all donuts with pricing and availability
- Add new donut flavors
- Edit existing donut details
- Delete donuts
- Toggle availability status
- Health check endpoint for ALB

## Useful Commands

```bash
# View Terraform outputs
terraform output

# SSH into an EC2 instance (via Session Manager recommended)
aws ssm start-session --target i-xxxxx

# View CodePipeline status
aws codepipeline get-pipeline-state --name donut-flavors-pipeline

# View deployment status
aws deploy list-deployments --application-name donut-flavors-app

# Tail application logs (from EC2)
sudo journalctl -u donut-app -f

# View CodeDeploy agent logs
sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
```

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

Type 'yes' when prompted. This will delete all AWS resources.

## Troubleshooting

### Pipeline Stuck at Source Stage
- Ensure GitHub connection is activated in AWS Console
- Verify repository name and branch are correct

### Deployment Failing
- Check CodeDeploy logs: `/var/log/aws/codedeploy-agent/`
- Check application logs: `journalctl -u donut-app`
- Verify security groups allow traffic

### Database Connection Issues
- Ensure RDS security group allows EC2 security group
- Check environment variables in `/home/ec2-user/app/.env`
- Verify RDS endpoint in Terraform outputs

### Health Check Failing
- Verify application is running: `systemctl status donut-app`
- Check if port 5000 is open
- Test locally: `curl http://localhost:5000/health`

## Cost Estimate

Running this infrastructure 24/7:
- EC2 (2x t2.micro): ~$17/month
- RDS (db.t3.micro): ~$15/month
- ALB: ~$20/month
- NAT Gateway: ~$35/month
- **Total**: ~$87/month

**Tip**: Destroy resources when not in use for demos/grading to save costs.

## License

This project is for educational purposes (IS 590R DevOps course).
