# Lesson 20: Docker Tagging and Versioning

## 🎯 Learning Objectives
- Tag Docker images
- Understand versioning strategies
- Use semantic versioning
- Tag for different environments
- Practice image management

## 📚 Key Terminologies & Real-World Use Cases

### Image Tagging

**What it is:** Labels that identify different versions of Docker images. Tags are human-readable identifiers pointing to specific image versions.

**Real-World Analogy:**
Think of tags like **version labels on software**:
- `v1.0.0` = Major release
- `v1.0.1` = Bug fix
- `latest` = Most recent
- `dev` = Development version

**Why we need it:**
- **Version Control**: Track different versions of your application
- **Rollback**: Easily revert to previous versions
- **Testing**: Test specific versions before production
- **Deployment**: Deploy specific versions to different environments
- **Collaboration**: Team members know which version to use

**Real-World Use Case:** You deploy v1.0.0 to production. Bug discovered. You fix it and create v1.0.1. Deploy v1.0.1. If issues occur, rollback to v1.0.0 instantly. Tags make version management easy!

### Tagging Strategies

**1. Semantic Versioning**
- **Format:** vMAJOR.MINOR.PATCH (e.g., v1.2.3)
- **Use case:** Production releases
- **Why:** Clear version meaning, industry standard

**2. Environment Tags**
- **Format:** dev, staging, prod
- **Use case:** Different environments
- **Why:** Easy to identify environment-specific images

**3. Git-based Tags**
- **Format:** Git commit hash or tag
- **Use case:** CI/CD pipelines
- **Why:** Traceability to source code

**4. Date Tags**
- **Format:** 2024-01-15, 20240115
- **Use case:** Daily builds
- **Why:** Easy to identify build date

**Real-World Use Case:** CI/CD pipeline builds image on every commit. Tags with git commit hash: `my-app:abc123`. If production issue occurs, you know exactly which code version. Perfect traceability!

## 🚀 Hands-On Tutorial

### Part 1: Basic Tagging

#### Step 1: Build an Image

**Why:** Need an image to tag.

```bash
docker build -t my-app:latest .
```

**What happens:**
- Builds image
- Tags it as `my-app:latest`
- `latest` is default tag if not specified

#### Step 2: Create Version Tag

**Why:** Tag with specific version.

```bash
docker tag my-app:latest my-app:v1.0.0
```

**What `docker tag` does:**
- Creates new tag pointing to same image
- One image can have multiple tags
- No extra storage (tags are just pointers)

#### Step 3: Verify Tags

**Why:** See all tags for the image.

```bash
docker images my-app
```

**Expected Output:**
```
REPOSITORY   TAG       IMAGE ID       CREATED
my-app       latest    abc123...      2 min ago
my-app       v1.0.0    abc123...      2 min ago
```

**What you see:**
- Both tags point to same image ID
- Multiple tags, one image

### Part 2: Semantic Versioning

#### Step 1: Tag with Multiple Version Levels

**Why:** Support different update strategies.

```bash
# Tag with full version
docker tag my-app:latest my-app:v1.0.0

# Tag with minor version
docker tag my-app:latest my-app:v1.0

# Tag with major version
docker tag my-app:latest my-app:v1

# Keep latest
docker tag my-app:latest my-app:latest
```

**What this enables:**
- `v1.0.0`: Specific version (never changes)
- `v1.0`: Latest patch of v1.0
- `v1`: Latest v1.x version
- `latest`: Most recent version

**Real-World:** Consumer can choose update strategy:
- `v1.0.0`: Never updates (stability)
- `v1.0`: Gets patches (security updates)
- `v1`: Gets minor updates (features)
- `latest`: Gets all updates (cutting edge)

#### Step 2: Verify Multiple Tags

**Why:** See all version tags.

```bash
docker images my-app
```

**Expected Output:**
```
REPOSITORY   TAG       IMAGE ID
my-app       latest    abc123...
my-app       v1        abc123...
my-app       v1.0      abc123...
my-app       v1.0.0    abc123...
```

### Part 3: Environment Tags

#### Step 1: Tag for Development

**Why:** Different tags for different environments.

```bash
docker tag my-app:latest my-app:dev
```

#### Step 2: Tag for Staging

**Why:** Separate staging version.

```bash
docker tag my-app:latest my-app:staging
```

#### Step 3: Tag for Production

**Why:** Production-specific tag.

```bash
docker tag my-app:latest my-app:prod
docker tag my-app:latest my-app:production
```

**What this enables:**
- Deploy `my-app:dev` to development
- Deploy `my-app:staging` to staging
- Deploy `my-app:prod` to production
- Clear separation

### Part 4: Git-based Tagging

#### Step 1: Tag with Git Commit

**Why:** Traceability to source code.

```bash
# Get git commit hash
GIT_COMMIT=$(git rev-parse --short HEAD)

# Tag with commit hash
docker tag my-app:latest my-app:$GIT_COMMIT
```

**What it does:**
- Tags image with git commit hash
- Links Docker image to source code version
- Perfect for CI/CD

#### Step 2: Tag with Git Tag

**Why:** Use git tags for Docker tags.

```bash
# Get git tag
GIT_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "latest")

# Tag with git tag
docker tag my-app:latest my-app:$GIT_TAG
```

**What it does:**
- Uses git tag as Docker tag
- Synchronizes versioning
- Common in CI/CD pipelines

### Part 5: Best Practices

#### Step 1: Never Use 'latest' in Production

**Why:** `latest` changes, breaks reproducibility.

```bash
# Bad: Using latest in production
docker run my-app:latest

# Good: Use specific version
docker run my-app:v1.0.0
```

**Why it matters:**
- `latest` changes over time
- Production needs reproducibility
- Specific versions are predictable

#### Step 2: Tag Before Push

**Why:** Tag with full registry path before pushing.

```bash
# Tag for registry
docker tag my-app:v1.0.0 registry.example.com/my-app:v1.0.0

# Push tagged image
docker push registry.example.com/my-app:v1.0.0
```

**What it does:**
- Tags with full registry path
- Required for pushing to registries
- Enables distribution

## 🎓 Key Takeaways

1. **docker tag** creates new tags (pointers to images)
2. **Multiple tags** can point to same image
3. **Semantic versioning** recommended (v1.0.0)
4. **latest tag** should point to stable version
5. **Environment tags** for different stages (dev, staging, prod)
6. **Never use latest** in production (use specific versions)
7. **Git-based tags** for CI/CD traceability

## 🔄 Next Steps

- Implement tagging strategy
- Automate tagging in CI/CD
- Move to Lesson 21 for advanced Compose

## 💡 Interview Questions

1. **How do you tag an image?**
   - `docker tag <source> <target>`

2. **What is semantic versioning?**
   - MAJOR.MINOR.PATCH (e.g., v1.2.3)
   - MAJOR: Breaking changes
   - MINOR: New features (backward compatible)
   - PATCH: Bug fixes

3. **Should you use 'latest' tag in production?**
   - Not recommended, use specific versions for reproducibility

4. **How do you tag for different environments?**
   - Use environment-specific tags (dev, staging, prod)

5. **Can one image have multiple tags?**
   - Yes! Tags are just pointers to images

6. **What's the difference between tag and image?**
   - Image: Actual image data
   - Tag: Human-readable label pointing to image
   - One image can have many tags

7. **Why use git-based tagging?**
   - Traceability to source code
   - Perfect for CI/CD pipelines
   - Links Docker image to git commit
