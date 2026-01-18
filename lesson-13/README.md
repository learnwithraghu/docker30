# Lesson 13: Docker Registry and Image Management with AWS ECR

## 🎯 Learning Objectives
- Understand Docker registries and why we use them
- Learn about AWS ECR (Elastic Container Registry)
- Configure AWS ECR authentication
- Push and pull images to/from ECR
- Tag images properly for production

## 📚 Key Terminologies & Real-World Use Cases

### What is a Docker Registry?

**What it is:** A repository for storing and distributing Docker images. Like GitHub for code, but for Docker images.

**Real-World Analogy:**
Think of a Docker registry like an **art gallery storage warehouse**:
- **Docker Hub** = Public museum (anyone can view, some can contribute)
- **AWS ECR** = Private, secure vault (only authorized access)
- **Push** = Storing your artwork in the vault
- **Pull** = Retrieving artwork when needed
- **Tags** = Labels that identify different versions

**Why we need it:**
- **Centralized Storage**: All your images in one secure place
- **Version Control**: Keep track of different versions
- **Team Collaboration**: Share images with your team
- **CI/CD Integration**: Automate deployments
- **Security**: Private registries keep your code secure

**Real-World Use Case:** Your team builds a microservice. Instead of each developer building the image locally (inconsistent!), you push to ECR. Everyone pulls the same image - ensures consistency across dev, staging, and production!

### AWS ECR Overview

**What it is:** AWS Elastic Container Registry - fully managed Docker container registry.

**Why ECR over Docker Hub:**
- **Private by default**: More secure for production
- **AWS Integration**: Works seamlessly with ECS, EKS, Lambda
- **Cost-effective**: Pay only for storage and data transfer
- **IAM Integration**: Fine-grained access control
- **Image scanning**: Built-in vulnerability scanning

**Real-World Use Case:** Company uses AWS for infrastructure. ECR integrates with ECS/EKS - deploy images directly from ECR. No need to manage separate registry, better security with IAM, and automatic scanning catches vulnerabilities before deployment.

### Image Naming Convention

**Format:** `[registry-url]/[repository-name]/[image-name]:[tag]`

**Example:** `123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:v1.0.0`

**Breaking it down:**
- `123456789012.dkr.ecr.us-east-1.amazonaws.com` - ECR registry URL
- `my-app` - Repository name
- `v1.0.0` - Tag (version)

**Why this matters:** Proper naming ensures images are organized, versioned, and easy to find.

## 🚀 Hands-On Tutorial

### Prerequisites

**Setup:**
1. AWS Account with ECR access
2. AWS CLI installed: `aws --version`
3. AWS CLI configured: `aws configure`
4. Docker installed and running

### Step 1: Configure Environment

**Why:** Store configuration in .env file (credentials, region, repo name).

Create `.env` file:
```bash
# AWS Configuration
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012

# ECR Repository Configuration
ECR_REPOSITORY_NAME=my-docker-app
IMAGE_NAME=my-app
IMAGE_TAG=v1.0.0
```

**Get your AWS Account ID:**
```bash
aws sts get-caller-identity --query Account --output text
```

**Load variables:**
```bash
export $(cat .env | grep -v '^#' | xargs)
```

### Step 2: Authenticate Docker with ECR

**Why:** Docker needs permission to push/pull from ECR. AWS uses temporary tokens (more secure).

```bash
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

**What happens:**
- Gets temporary authentication token (valid 12 hours)
- Authenticates Docker with ECR
- Token expires, need to re-authenticate periodically

**Expected Output:**
```
Login Succeeded
```

### Step 3: Create ECR Repository

**Why:** ECR repositories are like folders - need to create before pushing.

```bash
aws ecr create-repository \
  --repository-name $ECR_REPOSITORY_NAME \
  --region $AWS_REGION \
  --image-scanning-configuration scanOnPush=true \
  --image-tag-mutability MUTABLE
```

**What each option does:**
- `scanOnPush=true`: Automatically scan for vulnerabilities
- `MUTABLE`: Allows tags to be overwritten (vs IMMUTABLE)

**Expected Output:**
```json
{
    "repository": {
        "repositoryUri": "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-docker-app",
        ...
    }
}
```

### Step 4: Build and Tag Image

**Why:** Need an image to push. Tag it with full ECR URI.

```bash
# Build image
docker build -t $IMAGE_NAME:$IMAGE_TAG .

# Create ECR URI
ECR_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY_NAME

# Tag for ECR
docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG
```

**What `docker tag` does:**
- Creates new tag pointing to same image
- Full ECR URI tells Docker where to push
- One image can have multiple tags

### Step 5: Push Image to ECR

**Why:** Upload image to ECR for storage and distribution.

```bash
docker push $ECR_URI:$IMAGE_TAG
```

**What happens:**
- Uploads image layers to ECR
- Only pushes new/changed layers (efficient!)
- First push takes longer, subsequent pushes faster

**Expected Output:**
```
The push refers to repository [...]
v1.0.0: Pushing [==================================================>]  15.36kB
v1.0.0: Pushed
```

### Step 6: Verify and Pull

**Why:** Confirm image is in ECR and can be pulled.

```bash
# List images in repository
aws ecr list-images --repository-name $ECR_REPOSITORY_NAME --region $AWS_REGION

# Pull image (simulate deployment)
docker pull $ECR_URI:$IMAGE_TAG
```

**What happens:**
- Verifies image is stored in ECR
- Pulls image (what happens in production deployments)

## 🎓 Key Takeaways

1. **ECR is AWS's managed Docker registry** - secure, scalable, integrated
2. **Authentication is temporary** - tokens expire after 12 hours
3. **Tag before push** - Docker needs full ECR URI to know where to push
4. **One image, multiple tags** - efficient storage, flexible versioning
5. **Layers are cached** - only changed layers are pushed/pulled
6. **Use semantic versioning** - makes version management clear
7. **Enable scanning** - catch vulnerabilities early
8. **Never commit .env** - keep credentials out of version control

## 💡 Interview Questions

1. **What is AWS ECR and why use it over Docker Hub?**
   - ECR is AWS's managed Docker registry
   - Private by default, better AWS integration, IAM-based security
   - Cost-effective for AWS-native workloads

2. **How do you authenticate Docker with ECR?**
   - Use `aws ecr get-login-password` to get temporary token
   - Pipe to `docker login` with AWS username
   - Token expires after 12 hours

3. **What's the difference between repository, image, and tag?**
   - Repository: Collection of images (folder)
   - Image: Specific version (identified by digest)
   - Tag: Human-readable label (v1.0.0, latest)

4. **Why tag images before pushing?**
   - Docker needs the full ECR URI to know where to push
   - Tag format: `[account].dkr.ecr.[region].amazonaws.com/[repo]:[tag]`

5. **How do you manage image versions in ECR?**
   - Use semantic versioning (v1.0.0)
   - Tag with multiple levels (v1.0.0, v1.0, v1, latest)
   - Use lifecycle policies to clean up old images
   - Never use `latest` tag in production deployments

6. **What are ECR lifecycle policies?**
   - Automatically expire old images based on rules
   - Saves storage costs
   - Reduces security risk from old vulnerable images
