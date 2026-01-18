# Lesson 09: Multi-Stage Dockerfiles

## 🎯 Learning Objectives
- Understand why multi-stage builds are important
- Learn multi-stage Dockerfile syntax
- Reduce image size significantly
- Build optimized production images

## 📚 Key Terminologies & Real-World Use Cases

### What are Multi-Stage Builds?

**What they are:** Using multiple `FROM` statements in a Dockerfile to create smaller final images by separating build environment from runtime environment.

**Real-World Analogy:**
Think of building a car:
- **Stage 1 (Build)**: Factory with all tools, materials, and workers (compilers, build tools)
- **Stage 2 (Production)**: Final car with only essential parts (just the runtime)

You don't ship the entire factory with the car - only what's needed to run it!

**Why we need them:**
- **Smaller Images**: Only runtime dependencies in final image (90% size reduction!)
- **Security**: Build tools not in production image (smaller attack surface)
- **Faster Deployments**: Smaller images = faster pulls and deployments
- **Cleaner**: No build artifacts, source code, or dev dependencies in production

**Real-World Use Case:** Your Node.js app needs npm, webpack, babel, and other build tools to compile. Single-stage build: 900MB image. Multi-stage build: 150MB image (only runtime). Saves bandwidth, storage, and deployment time!

### How Multi-Stage Works

**Stage 1 (Builder):**
- Has all build tools (compilers, package managers)
- Compiles/builds your application
- Creates artifacts (compiled code, binaries)

**Stage 2 (Production):**
- Minimal base image (just runtime)
- Copies only artifacts from Stage 1
- No build tools, no source code, no dev dependencies

**Real-World Use Case:** Go application. Stage 1: Full Go compiler (500MB). Stage 2: Just the compiled binary (5MB). Final image: 5MB instead of 500MB!

## 🚀 Hands-On Tutorial

### Part 1: Single-Stage vs Multi-Stage

#### Step 1: Single-Stage Build (Inefficient)

**Why:** See the problem - build tools end up in final image.

Create `Dockerfile.single`:
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**Problem:** Final image includes:
- npm (not needed at runtime)
- Source code (not needed)
- Dev dependencies (not needed)
- Build tools (not needed)

**Size:** ~900MB

#### Step 2: Multi-Stage Build (Optimized)

**Why:** Separate build from runtime - only runtime in final image.

Create `Dockerfile`:
```dockerfile
# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**What each stage does:**
- **Stage 1 (builder)**: Installs dependencies, builds app
- **Stage 2 (production)**: Only copies built files, no build tools

**Size:** ~150MB (83% smaller!)

#### Step 3: Build and Compare

**Why:** See the size difference.

```bash
# Build single-stage
docker build -f Dockerfile.single -t app-single .

# Build multi-stage
docker build -t app-multi .

# Compare sizes
docker images | grep app
```

**Expected Output:**
```
app-single    latest    abc123    900MB
app-multi     latest    def456    150MB
```

**🎉 Success!** Multi-stage is 83% smaller!

### Part 2: Go Application Example

#### Step 1: Create Multi-Stage Dockerfile

**Why:** Go apps benefit greatly from multi-stage builds.

Create `Dockerfile`:
```dockerfile
# Stage 1: Build
FROM golang:1.21-alpine AS builder
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o app .

# Stage 2: Production
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /build/app .
CMD ["./app"]
```

**What happens:**
- **Stage 1**: Full Go compiler builds the binary
- **Stage 2**: Minimal Alpine Linux, just the binary
- Final image: ~10MB (vs 500MB with full Go image)

#### Step 2: Build the Image

**Why:** Create optimized production image.

```bash
docker build -t go-app:latest .
```

**What you get:** Tiny production image with just the compiled binary.

## 🎓 Key Takeaways

1. Use **multiple FROM statements** for different stages
2. **Name stages** with `AS <name>` for clarity
3. **Copy artifacts** from previous stages with `--from`
4. Final image only contains **runtime dependencies**
5. **Dramatically reduces** image size (often 80-90%)
6. **More secure** (no build tools in production)
7. **Faster deployments** (smaller images = faster pulls)

## 💡 Interview Questions

1. **What is a multi-stage build?**
   - Using multiple FROM statements to create smaller final images

2. **Why use multi-stage builds?**
   - Reduce image size, improve security, faster deployments

3. **How do you copy files from a previous stage?**
   - `COPY --from=<stage-name> <src> <dest>`

4. **What's the difference between single and multi-stage builds?**
   - Single: All build tools in final image
   - Multi: Only runtime in final image

5. **Can you have more than 2 stages?**
   - Yes! As many as needed (e.g., test stage, build stage, production stage)

6. **What's the typical size reduction with multi-stage builds?**
   - Often 80-90% smaller (e.g., 900MB → 150MB)
