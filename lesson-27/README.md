# Lesson 27: Docker CI/CD Integration

## 🎯 Learning Objectives
- Integrate Docker with CI/CD
- Build images in pipelines
- Push to registries
- Automate deployments
- Practice with GitHub Actions

## 📚 Key Terminologies & Real-World Use Cases

### CI/CD with Docker

**What it is:** Automating the process of building, testing, and deploying Docker images using Continuous Integration and Continuous Deployment pipelines.

**Real-World Analogy:**
Think of CI/CD like an **automated assembly line**:
- **CI (Continuous Integration)**: Test and build automatically
- **CD (Continuous Deployment)**: Deploy automatically
- **Docker**: Packages everything consistently
- **Pipeline**: Automated workflow

**Why we need it:**
- **Consistency**: Same build process every time
- **Speed**: Automated, no manual steps
- **Quality**: Tests run automatically
- **Reliability**: Reduces human error
- **Traceability**: Every deployment tracked

**Real-World Use Case:** Developer pushes code. CI/CD automatically: builds Docker image, runs tests, scans for vulnerabilities, pushes to registry, deploys to staging. If tests pass, auto-deploys to production. Zero manual intervention. Fast, reliable, consistent!

### CI/CD Pipeline

**1. Source**
- **What:** Code commit triggers pipeline
- **Why:** Start automation on code changes

**2. Build**
- **What:** Docker build creates image
- **Why:** Package application consistently

**3. Test**
- **What:** Run tests in containers
- **Why:** Verify application works

**4. Push**
- **What:** Push image to registry
- **Why:** Store for deployment

**5. Deploy**
- **What:** Deploy to environment
- **Why:** Make application available

**Real-World Use Case:** Every commit triggers build. Image tagged with commit SHA. Tests run. If pass, image pushed to registry. Auto-deploy to staging. Manual approval for production. Full automation!

## 🚀 Hands-On Tutorial

### Part 1: GitHub Actions

#### Step 1: Create Workflow File

**Why:** Define CI/CD pipeline in code.

Create `.github/workflows/docker.yml`:
```yaml
name: Docker Build and Push

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: username/myapp:${{ github.sha }},username/myapp:latest
```

**What it does:**
- Triggers on push to main
- Sets up buildx
- Logs into Docker Hub
- Builds and pushes image
- Tags with commit SHA and latest

#### Step 2: Configure Secrets

**Why:** Store credentials securely.

In GitHub repository:
1. Go to Settings → Secrets → Actions
2. Add `DOCKER_USERNAME`
3. Add `DOCKER_PASSWORD`

**What it does:**
- Secrets stored securely
- Not visible in logs
- Used in workflow

#### Step 3: Push and Watch

**Why:** Trigger pipeline.

```bash
git add .github/workflows/docker.yml
git commit -m "Add CI/CD pipeline"
git push
```

**What happens:**
- GitHub Actions runs workflow
- Builds Docker image
- Pushes to registry
- Check Actions tab for status

### Part 2: Enhanced Pipeline

#### Step 1: Add Testing

**Why:** Run tests before pushing.

Update workflow:
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Run tests
        run: docker run myapp:${{ github.sha }} npm test
      
      - name: Push to registry
        if: success()
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push myapp:${{ github.sha }}
```

**What it does:**
- Builds image
- Runs tests
- Only pushes if tests pass
- Quality gate!

#### Step 2: Multi-Arch Build

**Why:** Build for multiple architectures.

```yaml
- name: Build and push multi-arch
  uses: docker/build-push-action@v4
  with:
    context: .
    platforms: linux/amd64,linux/arm64
    push: true
    tags: username/myapp:${{ github.sha }}
```

**What it does:**
- Builds for both architectures
- Creates manifest list
- One image works everywhere

### Part 3: GitLab CI

#### Step 1: Create GitLab CI Config

**Why:** Alternative CI/CD platform.

Create `.gitlab-ci.yml`:
```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - docker build -t myapp:$CI_COMMIT_SHA .
    - docker push myapp:$CI_COMMIT_SHA

test:
  stage: test
  script:
    - docker run myapp:$CI_COMMIT_SHA npm test

deploy:
  stage: deploy
  script:
    - docker pull myapp:$CI_COMMIT_SHA
    - docker tag myapp:$CI_COMMIT_SHA myapp:latest
    - docker-compose up
  only:
    - main
```

**What it does:**
- Builds on every commit
- Tests before deploy
- Deploys only on main branch

### Part 4: Best Practices

#### Step 1: Tag Strategy

**Why:** Proper versioning.

```yaml
tags: |
  username/myapp:${{ github.sha }}
  username/myapp:${{ github.ref_name }}
  username/myapp:latest
```

**What it does:**
- Commit SHA: Specific version
- Branch name: Environment
- Latest: Most recent

#### Step 2: Cache Layers

**Why:** Faster builds.

```yaml
- name: Build with cache
  uses: docker/build-push-action@v4
  with:
    cache-from: type=registry,ref=username/myapp:buildcache
    cache-to: type=registry,ref=username/myapp:buildcache,mode=max
```

**What it does:**
- Caches layers between builds
- Faster subsequent builds
- Saves time and resources

## 🎓 Key Takeaways

1. **Automate builds** on every commit
2. **Run tests** in containers
3. **Push to registry** automatically
4. **Deploy** to environments
5. **Tag images** with commit SHA
6. **Use secrets** for credentials
7. **Multi-arch** builds for compatibility

## 🔄 Next Steps

- Set up CI/CD for your projects
- Automate deployments
- Move to Lesson 28 for performance

## 💡 Interview Questions

1. **What is CI/CD?**
   - Continuous Integration and Continuous Deployment
   - Automated build, test, and deploy

2. **How do you build Docker images in CI/CD?**
   - Use `docker build` in pipeline steps
   - Or use Docker actions (GitHub Actions)

3. **Why use Docker in CI/CD?**
   - Consistent environments
   - Reproducible builds
   - Isolated test environments

4. **How do you handle secrets in CI/CD?**
   - Use CI/CD platform secrets management
   - Never hardcode credentials

5. **What should you tag images with?**
   - Commit SHA (specific version)
   - Branch name (environment)
   - Version tags (semantic versioning)

6. **How do you ensure quality in CI/CD?**
   - Run tests before pushing
   - Use quality gates
   - Only deploy if tests pass

7. **What is multi-arch in CI/CD?**
   - Build for multiple architectures in pipeline
   - One image works on all platforms
