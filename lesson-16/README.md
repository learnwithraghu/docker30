# Lesson 16: Docker Build Context and .dockerignore

## 🎯 Learning Objectives
- Understand build context
- Use .dockerignore effectively
- Optimize build performance
- Reduce image size

## 📚 Key Terminologies & Real-World Use Cases

### Build Context

**What it is:** The directory and files sent to Docker daemon when building an image. Everything in the build context directory is sent to Docker.

**Real-World Analogy:**
Think of build context like **packing for a trip**:
- You pack everything in your suitcase (build context)
- But you don't need everything (use .dockerignore)
- Smaller suitcase = faster packing (faster builds)
- Only pack what you need (only necessary files)

**Why it matters:**
- **Build Speed**: Smaller context = faster uploads to Docker daemon
- **Image Size**: Unnecessary files increase image size
- **Security**: Prevents accidentally including secrets
- **Efficiency**: Only send what's needed

**Real-World Use Case:** Your project has 500MB of node_modules, test files, and documentation. Without .dockerignore, Docker sends all 500MB to build. With .dockerignore, only sends 5MB of source code. Build time: 2 minutes → 10 seconds!

### .dockerignore

**What it is:** Like .gitignore, but for Docker builds. Excludes files and directories from build context.

**Why we need it:**
- **Faster builds**: Less data to transfer to Docker daemon
- **Smaller images**: Excludes unnecessary files from image
- **Security**: Prevents including secrets, credentials
- **Cleaner builds**: Only includes what's needed

**Real-World Use Case:** Developer accidentally includes .env file with database passwords. Without .dockerignore, secrets end up in image layers (security risk!). With .dockerignore, .env is excluded. Security maintained!

## 🚀 Hands-On Tutorial

### Part 1: Understanding Build Context

#### Step 1: Check Current Directory Size

**Why:** See how much data would be sent to Docker.

```bash
du -sh .
```

**What it shows:** Total size of current directory (build context)

#### Step 2: Build Without .dockerignore

**Why:** See what gets sent to Docker daemon.

```bash
docker build --progress=plain -t context-demo . 2>&1 | grep "Sending build context"
```

**What you'll see:** Size of build context being sent

**Expected Output:**
```
Sending build context 500.5MB
```

### Part 2: Creating .dockerignore

#### Step 1: Create .dockerignore

**Why:** Exclude unnecessary files from build context.

Create `.dockerignore`:
```
# Dependencies (install in container)
node_modules/
vendor/
__pycache__/

# Build outputs
dist/
build/
*.o
*.a

# Version control
.git/
.gitignore

# IDE files
.vscode/
.idea/
*.swp

# Environment files
.env
.env.local
.env.*.local

# Documentation
*.md
docs/

# Tests
test/
tests/
*.test.js
coverage/

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/
```

**What it does:**
- Excludes files matching these patterns
- Reduces build context size
- Prevents secrets from being included

#### Step 2: Check Size After .dockerignore

**Why:** See the difference.

```bash
# Check what would be included
du -sh .

# Build again
docker build --progress=plain -t context-demo . 2>&1 | grep "Sending build context"
```

**Expected Output:**
```
Sending build context 5.2MB
```

**🎉 Success!** Build context reduced from 500MB to 5MB!

### Part 3: Language-Specific .dockerignore

#### Step 1: Python .dockerignore

**Why:** Python projects have specific files to exclude.

Create `.dockerignore` for Python:
```
__pycache__/
*.py[cod]
*.pyo
*.pyd
.Python
env/
venv/
.venv
*.egg-info/
dist/
build/
.pytest_cache/
.coverage
```

#### Step 2: Node.js .dockerignore

**Why:** Node.js projects have different files.

Create `.dockerignore` for Node.js:
```
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.yarn
dist/
build/
coverage/
*.log
```

### Part 4: Verify What's Included

#### Step 1: Check Build Context

**Why:** See what files Docker actually uses.

```bash
# Build with verbose output
docker build --progress=plain -t context-demo . 2>&1 | head -20
```

**What it shows:** Files being sent to Docker daemon

#### Step 2: Test Build

**Why:** Ensure build still works with .dockerignore.

```bash
docker build -t context-demo .
```

**What to verify:**
- Build succeeds
- Only necessary files included
- Dependencies installed in container (not copied)

## 🎓 Key Takeaways

1. **Build context** is everything in the directory sent to Docker
2. **.dockerignore** excludes files (like .gitignore)
3. **Smaller context** = faster builds
4. **Exclude dependencies** (install in container, don't copy)
5. **Never include secrets** in build context
6. **Check context size** before building
7. **Language-specific** .dockerignore patterns

## 🔄 Next Steps

- Create .dockerignore for your projects
- Measure build time improvements
- Move to Lesson 17 to learn about restart policies

## 💡 Interview Questions

1. **What is Docker build context?**
   - Directory sent to Docker daemon for building

2. **What is .dockerignore?**
   - File that excludes files from build context

3. **Why use .dockerignore?**
   - Faster builds, smaller images, security

4. **Should you include node_modules in build?**
   - No, install in container (exclude with .dockerignore)

5. **How do you check build context size?**
   - `du -sh .` or `docker build --progress=plain`

6. **What happens if you include .env in build context?**
   - Secrets end up in image layers (security risk!)
   - Always exclude with .dockerignore
