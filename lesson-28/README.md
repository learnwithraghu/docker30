# Lesson 28: Docker Performance Optimization

## 🎯 Learning Objectives
- Optimize Docker builds
- Reduce image sizes
- Improve build speed
- Optimize runtime performance

## 📚 Key Terminologies & Real-World Use Cases

### Performance Optimization

**What it is:** Techniques to make Docker builds faster, images smaller, and runtime more efficient.

**Real-World Analogy:**
Think of optimization like **streamlining a car**:
- **Smaller images** = Lighter car (faster pulls)
- **Layer caching** = Reuse parts (efficient builds)
- **Multi-stage builds** = Remove unnecessary parts
- **Minimal base images** = Start with less weight

**Why we need it:**
- **Faster Builds**: Save developer time
- **Faster Deployments**: Smaller images = faster pulls
- **Lower Costs**: Less storage, less bandwidth
- **Better Performance**: Optimized containers run faster
- **Resource Efficiency**: Use fewer resources

**Real-World Use Case:** Production deployment. Without optimization: 5-minute builds, 2GB images, 3-minute pulls. With optimization: 30-second builds, 150MB images, 10-second pulls. 10x improvement! Saves time, money, and improves user experience!

### Optimization Strategies

**1. Minimal Base Images**
- **What:** Use Alpine, distroless, or scratch
- **Impact:** 10-20x smaller images
- **Why:** Fewer packages = smaller size

**2. Multi-Stage Builds**
- **What:** Remove build tools from final image
- **Impact:** 80-90% size reduction
- **Why:** Only runtime in final image

**3. Layer Caching**
- **What:** Order Dockerfile for best caching
- **Impact:** 5-10x faster builds
- **Why:** Reuse unchanged layers

**4. .dockerignore**
- **What:** Exclude unnecessary files
- **Impact:** Faster builds, smaller context
- **Why:** Less data to send to Docker

**Real-World Use Case:** Node.js app. Without optimization: 900MB image, 5-minute builds. With optimization: 150MB image, 30-second builds. 6x smaller, 10x faster!

## 🚀 Hands-On Tutorial

### Part 1: Minimal Base Images

#### Step 1: Compare Image Sizes

**Why:** See the difference.

```bash
# Large base image
docker pull ubuntu:latest
docker images ubuntu

# Minimal base image
docker pull alpine:latest
docker images alpine
```

**Expected Output:**
```
ubuntu    latest    70MB
alpine    latest    5MB
```

**What you see:** Alpine is 14x smaller!

#### Step 2: Use Alpine

**Why:** Smaller images = faster pulls.

```dockerfile
# ❌ Bad: Large base image
FROM ubuntu:latest
RUN apt-get update && apt-get install -y python3

# ✅ Good: Minimal base image
FROM python:3.9-alpine
```

**What it does:**
- Alpine: Minimal Linux (5MB vs 70MB)
- Fewer packages = smaller attack surface
- Faster pulls and deployments

### Part 2: Multi-Stage Builds

#### Step 1: Compare Single vs Multi-Stage

**Why:** See size difference.

**Single-stage Dockerfile:**
```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
CMD ["node", "dist/server.js"]
```

**Multi-stage Dockerfile:**
```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/server.js"]
```

#### Step 2: Build and Compare

**Why:** See actual size difference.

```bash
# Build single-stage
docker build -f Dockerfile.single -t app-single .

# Build multi-stage
docker build -f Dockerfile.multi -t app-multi .

# Compare sizes
docker images | grep app
```

**Expected Output:**
```
app-single    900MB
app-multi     150MB
```

**🎉 Success!** 83% size reduction!

### Part 3: Layer Caching Optimization

#### Step 1: Optimize Dockerfile Order

**Why:** Better caching = faster builds.

```dockerfile
# ❌ Bad: Code copied first
FROM node:18-alpine
COPY . .
RUN npm install

# ✅ Good: Dependencies first
FROM node:18-alpine
COPY package*.json ./
RUN npm install
COPY . .
```

**What it does:**
- Dependencies change rarely
- Code changes frequently
- Dependencies layer stays cached
- Only code layer rebuilds

#### Step 2: Combine RUN Commands

**Why:** Fewer layers = faster builds.

```dockerfile
# ❌ Bad: Multiple layers
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y pip

# ✅ Good: Single layer
RUN apt-get update && \
    apt-get install -y python3 pip && \
    apt-get clean
```

**What it does:**
- One layer instead of three
- Faster builds
- Smaller image

### Part 4: BuildKit Optimization

#### Step 1: Enable BuildKit

**Why:** Better caching and performance.

```bash
export DOCKER_BUILDKIT=1
docker build -t optimized-app .
```

**What BuildKit does:**
- Better caching
- Parallel builds
- More efficient
- Faster builds

#### Step 2: Use Build Cache

**Why:** Reuse layers between builds.

```bash
# Build with cache mount
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t myapp:latest .
```

**What it does:**
- Caches layers
- Faster subsequent builds
- Reuses unchanged layers

### Part 5: .dockerignore Optimization

#### Step 1: Create .dockerignore

**Why:** Exclude unnecessary files.

Create `.dockerignore`:
```
node_modules
npm-debug.log
.git
.env
*.md
dist
coverage
```

#### Step 2: Measure Impact

**Why:** See build context reduction.

```bash
# Without .dockerignore
du -sh .  # 500MB

# With .dockerignore
du -sh .  # 5MB (after excluding files)
```

**What it does:**
- Reduces build context
- Faster uploads to Docker daemon
- Smaller images

## 🎓 Key Takeaways

1. **Minimal base images** reduce size (Alpine, distroless)
2. **Multi-stage builds** remove build tools (80-90% reduction)
3. **Layer caching** speeds up builds (order matters!)
4. **.dockerignore** reduces context size
5. **Combine RUN** commands (fewer layers)
6. **BuildKit** improves performance
7. **Measure** to verify improvements

## 🔄 Next Steps

- Optimize your Dockerfiles
- Measure improvements
- Move to Lesson 29 for monitoring

## 💡 Interview Questions

1. **How do you reduce image size?**
   - Use minimal base images (Alpine)
   - Multi-stage builds
   - Remove unnecessary files

2. **What improves build speed?**
   - Layer caching (order Dockerfile correctly)
   - .dockerignore (smaller context)
   - BuildKit (better caching)

3. **Why combine RUN commands?**
   - Fewer layers = faster builds
   - Smaller image size

4. **What is BuildKit?**
   - Enhanced build engine
   - Better caching, parallel builds
   - Faster and more efficient

5. **How do you measure optimization?**
   - Compare image sizes
   - Measure build times
   - Check pull times

6. **What's the typical size reduction with multi-stage builds?**
   - Often 80-90% (e.g., 900MB → 150MB)

7. **Why use .dockerignore?**
   - Reduces build context size
   - Faster builds
   - Prevents including unnecessary files
