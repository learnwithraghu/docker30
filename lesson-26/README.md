# Lesson 26: Docker Multi-Architecture Builds

## 🎯 Learning Objectives
- Understand multi-arch builds
- Build for different architectures
- Use buildx for multi-arch
- Create manifest lists
- Support ARM, x86, etc.

## 📚 Key Terminologies & Real-World Use Cases

### Multi-Architecture Builds

**What they are:** Building Docker images that work on multiple CPU architectures (ARM, x86, etc.) from a single image tag.

**Real-World Analogy:**
Think of multi-arch like **universal adapters**:
- One image works on different devices
- Mac M1 (ARM), Intel (x86), Linux (various)
- Same image, different architecture
- Docker automatically selects correct version

**Why we need it:**
- **Device Diversity**: Different devices use different CPUs
- **Apple Silicon**: M1/M2 Macs use ARM
- **Cloud Providers**: Mix of ARM and x86 instances
- **Edge Devices**: Raspberry Pi, IoT devices use ARM
- **Single Image**: One tag works everywhere

**Real-World Use Case:** You build an image on Intel Mac. Developer with M1 Mac can't run it. With multi-arch build, same image tag works on both! Deploy to AWS - some instances ARM, some x86. One image works on all. Perfect compatibility!

### Architectures

**1. linux/amd64**
- **What:** Intel/AMD 64-bit
- **Use case:** Most servers, Intel Macs
- **Why:** Most common architecture

**2. linux/arm64**
- **What:** ARM 64-bit
- **Use case:** Apple Silicon (M1/M2), modern ARM servers
- **Why:** Growing in popularity

**3. linux/arm/v7**
- **What:** ARM 32-bit
- **Use case:** Raspberry Pi, older ARM devices
- **Why:** Legacy ARM support

**4. linux/ppc64le**
- **What:** PowerPC 64-bit
- **Use case:** IBM Power systems
- **Why:** Enterprise servers

**Real-World Use Case:** Application deployed to AWS Graviton (ARM) and regular instances (x86). Build multi-arch image - works on both automatically. Cost savings (ARM cheaper) + compatibility!

## 🚀 Hands-On Tutorial

### Part 1: Enable Buildx

#### Step 1: Create Buildx Builder

**Why:** Buildx enables multi-arch builds.

```bash
docker buildx create --name multiarch --use
```

**What happens:**
- Creates new buildx builder named "multiarch"
- Sets it as default (`--use`)
- Buildx supports advanced build features

#### Step 2: Inspect Builder

**Why:** See builder capabilities.

```bash
docker buildx inspect
```

**What it shows:**
- Builder name and status
- Supported platforms
- Current platform

#### Step 3: List Builders

**Why:** See all available builders.

```bash
docker buildx ls
```

**Expected Output:**
```
NAME/NODE       DRIVER/ENDPOINT   STATUS   PLATFORMS
multiarch *     docker-container  running  linux/amd64, linux/arm64
```

**What you see:** Builder supports multiple platforms

### Part 2: Build for Multiple Architectures

#### Step 1: Build Multi-Arch Image

**Why:** Create image that works on multiple architectures.

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myapp:latest \
  --push .
```

**What each option does:**
- `--platform linux/amd64,linux/arm64`: Build for both architectures
- `-t myapp:latest`: Tag the image
- `--push`: Push to registry (required for multi-arch)
- `.`: Build context

**What happens:**
- Builds image for both architectures
- Creates manifest list (combines both)
- Pushes to registry
- Docker automatically selects correct architecture

#### Step 2: Build and Load (Local)

**Why:** Test locally without pushing.

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myapp:latest \
  --load .
```

**Note:** `--load` only works for single platform. For multi-arch, must use `--push`.

#### Step 3: Inspect Manifest

**Why:** See all architectures in image.

```bash
docker buildx imagetools inspect myapp:latest
```

**Expected Output:**
```
Manifests:
  Name:   myapp:latest
  MediaType: application/vnd.docker.distribution.manifest.list.v2+json
  Platform:
    - linux/amd64
    - linux/arm64
```

**What you see:** Image supports both architectures

### Part 3: Multi-Arch Dockerfile

#### Step 1: Platform-Aware Dockerfile

**Why:** Handle architecture-specific builds.

Create `Dockerfile`:
```dockerfile
FROM --platform=$BUILDPLATFORM node:18-alpine AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM
WORKDIR /app
COPY . .
RUN npm install && npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/server.js"]
```

**What each variable does:**
- `$BUILDPLATFORM`: Platform where build runs
- `$TARGETPLATFORM`: Platform where image runs
- Allows architecture-specific optimizations

#### Step 2: Build with Platform Variables

**Why:** Use platform info in build.

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg TARGETPLATFORM \
  -t myapp:latest \
  --push .
```

**What happens:**
- Buildx sets platform variables automatically
- Can use in Dockerfile for conditional logic
- Enables architecture-specific builds

### Part 4: Verify Multi-Arch Support

#### Step 1: Check Image Platforms

**Why:** Confirm image supports multiple architectures.

```bash
docker buildx imagetools inspect myapp:latest
```

**What it shows:**
- All supported platforms
- Manifest list details
- Architecture-specific digests

#### Step 2: Pull on Different Architecture

**Why:** Test automatic platform selection.

```bash
# On ARM machine
docker pull myapp:latest
docker run myapp:latest

# On x86 machine
docker pull myapp:latest
docker run myapp:latest
```

**What happens:**
- Docker automatically selects correct architecture
- No manual selection needed
- Works seamlessly!

## 🎓 Key Takeaways

1. **buildx** enables multi-arch builds
2. **--platform** specifies architectures
3. **--push** required for multi-arch (can't use --load)
4. **Manifest lists** combine architectures
5. **Automatic selection** by Docker
6. **Essential** for modern deployments
7. **Platform variables** for architecture-specific builds

## 🔄 Next Steps

- Build for your target platforms
- Push multi-arch images to registry
- Move to Lesson 27 for CI/CD

## 💡 Interview Questions

1. **What is multi-architecture build?**
   - Building images for multiple CPU architectures (ARM, x86, etc.)

2. **How do you build for multiple architectures?**
   - Use `docker buildx build --platform linux/amd64,linux/arm64`

3. **What is buildx?**
   - Extended build capabilities for Docker
   - Enables multi-arch and advanced features

4. **Why use multi-arch builds?**
   - Support different devices (ARM, x86)
   - Apple Silicon compatibility
   - Cloud provider diversity

5. **What is a manifest list?**
   - Combines multiple architecture images into one
   - Docker automatically selects correct architecture

6. **Can you use --load with multi-arch?**
   - No, must use --push to registry
   - --load only works for single platform

7. **What are platform variables?**
   - $BUILDPLATFORM, $TARGETPLATFORM
   - Available in Dockerfile for architecture-specific logic