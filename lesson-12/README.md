# Lesson 12: Docker Image Layers and Caching

## 🎯 Learning Objectives
- Understand Docker image layers
- Learn how layer caching works
- Optimize Dockerfile for better caching
- Inspect image layers

## 📚 Key Terminologies & Real-World Use Cases

### Image Layers

**What they are:** Each Dockerfile instruction creates a new read-only layer. Layers are stacked on top of each other to form the final image.

**Real-World Analogy:**
Think of Docker layers like **onion layers**:
- Each instruction creates a new layer
- Layers are stacked on top of each other
- If you change one layer, only that layer and above need to be rebuilt
- Unchanged layers are cached and reused

**Why layers matter:**
- **Caching**: Unchanged layers are reused (faster builds)
- **Efficiency**: Only changed layers need to be rebuilt
- **Sharing**: Multiple images can share base layers (saves disk space)
- **Incremental Updates**: Small changes = fast rebuilds

**Real-World Use Case:** You update your application code. Docker only rebuilds the top layer (your code), reusing cached dependency and OS layers. Build time: 30 seconds instead of 5 minutes! This is why layer order matters.

### Layer Caching Strategy

**Why order matters:**
- **Stable layers first**: Base OS, dependencies (change rarely)
- **Changing layers last**: Application code (changes frequently)
- **Result**: Code changes don't invalidate dependency cache

**Real-World Use Case:** Your Node.js app's package.json rarely changes, but code changes daily. Put `COPY package.json` before `COPY .` - when code changes, npm install layer stays cached. Saves minutes on every build!

### .dockerignore

**What it is:** Like .gitignore, excludes files from build context.

**Why we need it:**
- **Faster builds**: Smaller build context = faster uploads
- **Smaller images**: Excludes unnecessary files
- **Security**: Prevents accidentally including secrets

**Real-World Use Case:** Your project has 500MB of node_modules and test files. Without .dockerignore, Docker sends all 500MB to build. With .dockerignore, only sends 5MB of source code. Build time: 2 minutes → 10 seconds!

## 🚀 Hands-On Tutorial

### Part 1: Understanding Layers

#### Step 1: Build an Image

**Why:** Create an image to inspect its layers.

```bash
# Create a simple Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
CMD ["python", "app.py"]
EOF

# Build the image
docker build -t layer-demo .
```

#### Step 2: Inspect Layers

**Why:** See how many layers were created.

```bash
docker history layer-demo
```

**What it shows:**
- Each layer with its size
- Commands that created each layer
- Layer IDs

**Expected Output:**
```
IMAGE          CREATED        SIZE    CREATED BY
abc123...      2 min ago      5MB     CMD ["python" "app.py"]
def456...      2 min ago      1MB     COPY app.py .
ghi789...      2 min ago      50MB    RUN pip install...
jkl012...      2 min ago      1MB     COPY requirements.txt .
mno345...      2 min ago      100MB   FROM python:3.9-slim
```

### Part 2: Layer Caching in Action

#### Step 1: First Build

**Why:** See all layers being built.

```bash
docker build -t cache-demo .
```

**What happens:** All layers are built (no cache yet).

#### Step 2: Modify Application Code

**Why:** Change only the code layer.

```bash
echo "# Updated" >> app.py
```

#### Step 3: Second Build

**Why:** See caching in action - only changed layers rebuild.

```bash
docker build -t cache-demo .
```

**What you'll see:**
- `FROM`, `COPY requirements.txt`, `RUN pip install` → **Using cache** ✅
- `COPY app.py` → **Rebuilt** (changed)
- `CMD` → **Rebuilt** (depends on changed layer)

**Expected Output:**
```
Step 1/5 : FROM python:3.9-slim
 ---> Using cache
Step 2/5 : COPY requirements.txt .
 ---> Using cache
Step 3/5 : RUN pip install -r requirements.txt
 ---> Using cache
Step 4/5 : COPY app.py .
 ---> 123abc...
Step 5/5 : CMD ["python", "app.py"]
 ---> 456def...
```

**🎉 Success!** Caching worked - only changed layers rebuilt!

### Part 3: Optimizing Dockerfile

#### Step 1: Bad Dockerfile (Inefficient)

**Why:** See what NOT to do.

```dockerfile
FROM node:18
RUN npm install express
RUN npm install lodash
RUN npm install axios
COPY . .
```

**Problems:**
- Multiple RUN commands = multiple layers
- Dependencies installed before code (wrong order)
- Code changes invalidate dependency cache

#### Step 2: Good Dockerfile (Optimized)

**Why:** See best practices.

```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["node", "server.js"]
```

**Why it's better:**
- Dependencies copied first (stable)
- Single RUN command (fewer layers)
- Code copied last (changes frequently)
- Code changes don't invalidate npm install cache

#### Step 3: Use .dockerignore

**Why:** Exclude unnecessary files from build.

Create `.dockerignore`:
```
node_modules
npm-debug.log
.git
.env
*.md
.DS_Store
```

**What it does:**
- Excludes files from build context
- Faster builds (less data to send)
- Smaller images (no unnecessary files)

#### Step 4: Build and Compare

**Why:** See the difference.

```bash
# Build with .dockerignore
docker build -t optimized-app .

# Check build context size
du -sh .
```

**Result:** Smaller build context = faster builds!

## 🎓 Key Takeaways

1. **Layers are cached** for faster builds
2. **Order matters** - put stable files first (dependencies before code)
3. **Combine RUN commands** to reduce layers
4. **Use .dockerignore** to exclude files
5. **Inspect layers** with `docker history`
6. **Cache invalidation** happens when layer changes
7. **Optimized Dockerfiles** can reduce build time by 80%+

## 💡 Interview Questions

1. **How does Docker layer caching work?**
   - Unchanged layers are reused from cache
   - Only changed layers and subsequent layers are rebuilt

2. **Why should you copy package.json before source code?**
   - Dependencies change less frequently, so that layer stays cached
   - Code changes don't invalidate dependency installation cache

3. **How do you inspect image layers?**
   - `docker history <image>`

4. **What is .dockerignore?**
   - Excludes files from build context (like .gitignore)
   - Reduces build time and image size

5. **How do you disable cache during build?**
   - `docker build --no-cache`

6. **What happens when you change a layer?**
   - That layer and all subsequent layers are rebuilt
   - Previous layers remain cached
