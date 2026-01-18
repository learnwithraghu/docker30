# Quick Start Guide - AWS ECR

## Prerequisites

1. **AWS Account** with ECR permissions
2. **AWS CLI installed**: `aws --version`
3. **AWS CLI configured**: `aws configure`
4. **Docker installed**: `docker --version`

## Quick Setup (5 minutes)

### Step 1: Configure Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your AWS details
# Get your AWS Account ID:
aws sts get-caller-identity --query Account --output text
```

### Step 2: Load Environment Variables

```bash
export $(cat .env | grep -v '^#' | xargs)
```

### Step 3: Authenticate with ECR

```bash
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

### Step 4: Create Repository (if needed)

```bash
aws ecr create-repository \
  --repository-name $ECR_REPOSITORY_NAME \
  --region $AWS_REGION \
  --image-scanning-configuration scanOnPush=true
```

### Step 5: Build, Tag, and Push

```bash
# Build
docker build -t $IMAGE_NAME:$IMAGE_TAG .

# Tag for ECR
ECR_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY_NAME
docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

# Push
docker push $ECR_URI:$IMAGE_TAG
```

### Step 6: Verify

```bash
# List images in ECR
aws ecr list-images --repository-name $ECR_REPOSITORY_NAME --region $AWS_REGION

# Pull the image
docker pull $ECR_URI:$IMAGE_TAG
```

## Troubleshooting

**Error: "Unable to locate credentials"**
- Run `aws configure` to set up credentials
- Or set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables

**Error: "RepositoryNotFoundException"**
- Create the repository first (Step 4)
- Or check the repository name in `.env`

**Error: "AccessDenied"**
- Your IAM user/role needs ECR permissions
- Required permissions: `ecr:GetAuthorizationToken`, `ecr:*` (or specific ECR actions)

**Error: "Login token expired"**
- ECR tokens expire after 12 hours
- Re-run the authentication command (Step 3)
