# Lesson 04: Dockerfile Basics

## 🎯 Learning Objectives
- Understand what a Dockerfile is and why it's important
- Learn essential Dockerfile instructions
- Build your first Docker image from a Dockerfile
- Understand best practices

## 📚 Key Terminologies & Real-World Use Cases

### What is a Dockerfile?

**What it is:** A text file with step-by-step instructions to build a Docker image. It's like a recipe that tells Docker how to package your application.

**Real-World Analogy:**
Think of a Dockerfile like an **IKEA furniture manual**:
- Step 1: Start with this base (screw in the legs)
- Step 2: Add this component (attach the tabletop)
- Step 3: Install this (add the drawer)
- Each instruction creates a new layer in the image

**Why we need it:**
- **Reproducibility**: Same Dockerfile = same image every time
- **Version Control**: Track changes to your application environment
- **Automation**: Build images automatically in CI/CD pipelines
- **Documentation**: Dockerfile documents how your app is built

**Real-World Use Case:** Your team needs to deploy a Python app. Instead of manually installing Python, pip, and dependencies on each server, you write a Dockerfile. Now anyone can build the exact same environment with one command: `docker build`.

### Essential Dockerfile Instructions

**FROM** - Base image to start from
- Example: `FROM python:3.9-slim`
- **Why:** Every image needs a starting point (base OS + runtime)

**WORKDIR** - Set working directory
- Example: `WORKDIR /app`
- **Why:** Sets where commands run and files are copied

**COPY** - Copy files into image
- Example: `COPY app.py .`
- **Why:** Adds your application code to the image

**RUN** - Execute commands during build
- Example: `RUN pip install -r requirements.txt`
- **Why:** Installs dependencies, configures system

**EXPOSE** - Document which ports app uses
- Example: `EXPOSE 5000`
- **Why:** Documents which ports the application listens on

**CMD** - Default command to run
- Example: `CMD ["python", "app.py"]`
- **Why:** Defines what runs when container starts

### Image Layers

**What they are:** Each Dockerfile instruction creates a new layer. Layers are cached and can be shared between images.

**Why layers matter:**
- **Caching**: Unchanged layers are reused (faster builds)
- **Efficiency**: Only changed layers need to be rebuilt
- **Sharing**: Multiple images can share base layers

**Real-World Use Case:** You update your application code. Docker only rebuilds the top layer (your code), reusing cached dependency and OS layers. Build time: 30 seconds instead of 5 minutes!

## 🚀 Hands-On: Build Your First Image

All files are already prepared for you! Let's navigate to the Python app example and build your first Docker image.

### Step 1: Navigate to the Python App

**Why:** We'll use the pre-configured Python Flask application to learn Dockerfile basics.

```bash
cd python-app
```

**What's in this folder:**
- `app.py` - A simple Flask web application
- `requirements.txt` - Python dependencies
- `Dockerfile` - Instructions to build the Docker image

### Step 2: Examine the Dockerfile

**Why:** Understanding the Dockerfile helps you learn how images are built.

Let's look at the Dockerfile:
```bash
cat Dockerfile
```

**What each line does:**
- `FROM python:3.9-slim` - Start with Python base image
- `WORKDIR /app` - Set working directory
- `COPY requirements.txt .` - Copy dependency file
- `RUN pip install...` - Install dependencies
- `COPY app.py .` - Copy application code
- `EXPOSE 5000` - Document port
- `CMD ["python", "app.py"]` - Run command

### Step 3: Build the Image

**Why:** Convert Dockerfile into a runnable image.

```bash
docker build -t python-app:latest .
```

**What happens:**
- Docker reads Dockerfile
- Executes each instruction
- Creates layers
- Tags image as `python-app:latest`
- `.` is the build context (current directory)

**Expected Output:**
```
Step 1/7 : FROM python:3.9-slim
...
Successfully built abc123def456
Successfully tagged python-app:latest
```

### Step 4: Run the Container

**Why:** Test that the image works.

```bash
docker run -p 5001:5000 --name my-python-app python-app
```

**What each flag does:**
- `-p 5000:5000` - Map host port 5000 to container port 5000
- `--name my-python-app` - Give container a friendly name

**What happens:**
- Creates container from image
- Maps host port 5000 to container port 5000
- Runs the Flask app
- Access at http://localhost:5000

**Test it:**
```bash
curl http://localhost:5000
# Or open browser to http://localhost:5000
```

**Clean up when done:**
```bash
docker stop my-python-app
docker rm my-python-app
```

**⚠️ Common Errors & Solutions**

**Error 1: Container Name Already in Use**

If you get this error:
```
docker: Error response from daemon: Conflict. The container name "/my-python-app" is already in use by container "699d45a714a8...". You have to remove (or rename) that container to be able to reuse that name.
```

**Solution - Choose one:**

**Quick Fix (Recommended):** Remove the existing container and run again
```bash
docker rm -f my-python-app  # -f forces removal even if running
docker run -p 5000:5000 --name my-python-app python-app
```

**Alternative 1:** Use a different container name
```bash
docker run -p 5000:5000 --name my-python-app-2 python-app
```

**Alternative 2:** Use `--rm` flag (container auto-removes when stopped)
```bash
docker run -p 5000:5000 --rm --name my-python-app python-app
```

**Check what containers exist:**
```bash
docker ps -a  # Shows all containers (running and stopped)
```

**Error 2: Port Already in Use**

If you get:
```
Error: bind: address already in use
```

**Solution:** Either stop the container using the port, or use a different host port
```bash
# Find what's using port 5000
docker ps

# Stop the container using port 5000
docker stop <container-id-or-name>

# OR use a different host port
docker run -p 5001:5000 --name my-python-app python-app
# Now access at http://localhost:5001
```

### Step 5: Best Practices

**Why:** Follow best practices for efficient, secure images.

**1. Order matters (for caching):**
```dockerfile
# ✅ Good: Dependencies first (change less)
COPY requirements.txt .
RUN pip install -r requirements.txt
# Code last (changes frequently)
COPY app.py .
```

**2. Use .dockerignore:**
Create a `.dockerignore` file to exclude unnecessary files:
```
node_modules
.git
.env
*.md
__pycache__
*.pyc
```

**3. Minimize layers:**
```dockerfile
# ❌ Bad: Multiple layers
RUN apt-get update
RUN apt-get install -y python

# ✅ Good: Single layer
RUN apt-get update && apt-get install -y python
```

## 🎓 Key Takeaways

1. **Dockerfile** is a recipe for building images
2. Each instruction creates a **new layer**
3. **Order matters** - put frequently changing files last (better caching)
4. Use **.dockerignore** to exclude unnecessary files
5. **Minimize layers** by combining RUN commands
6. Use **specific tags** for base images (not `latest`)

## 🎯 Try More Examples

Want to practice with different technologies? Check out the `examples/` folder:
- `examples/node-app/` - Node.js Express application
- `examples/nginx-app/` - Static HTML with nginx

Navigate to any example folder and follow the same steps:
```bash
cd ../examples/node-app
docker build -t node-app:latest .
docker run -d -p 3000:3000 --name my-node-app node-app
```

## 💡 Interview Questions

1. **What is a Dockerfile?**
   - A text file with instructions to build a Docker image

2. **What's the difference between CMD and ENTRYPOINT?**
   - CMD: Default command, can be overridden
   - ENTRYPOINT: Always executed, arguments can be appended

3. **Why should you copy package.json before copying code?**
   - Docker caches layers. If code changes but dependencies don't, Docker can reuse the cached layer with installed dependencies.

4. **What is .dockerignore?**
   - Like .gitignore, excludes files from build context

5. **How do you optimize Dockerfile build time?**
   - Order instructions by change frequency
   - Use layer caching
   - Minimize layers
   - Use .dockerignore

6. **What does EXPOSE do?**
   - Documents which ports the application uses (doesn't actually publish ports)
   - Actual port mapping happens with `-p` flag in `docker run`

## 🔧 Troubleshooting Guide

### Problem: Container Name Conflict

**Error Message:**
```
docker: Error response from daemon: Conflict. The container name "/my-python-app" is already in use by container "699d45a714a8...". You have to remove (or rename) that container to be able to reuse that name.
```

**What it means:** A container with the same name already exists (either running or stopped).

**Solutions:**

1. **Remove the existing container (Recommended):**
   ```bash
   docker rm -f my-python-app
   docker run -p 5000:5000 --name my-python-app python-app
   ```

2. **Use a different name:**
   ```bash
   docker run -p 5000:5000 --name my-python-app-v2 python-app
   ```

3. **List and manage containers:**
   ```bash
   docker ps -a                    # See all containers
   docker stop my-python-app       # Stop a running container
   docker rm my-python-app         # Remove a stopped container
   docker rm -f my-python-app      # Force remove (stop + remove)
   ```

### Problem: Port Already in Use

**Error Message:**
```
Error: bind: address already in use
```

**What it means:** Another process (or container) is already using the port you're trying to map.

**Solutions:**

1. **Find and stop the container using the port:**
   ```bash
   docker ps                        # Find running containers
   docker stop <container-id>      # Stop the container
   ```

2. **Use a different host port:**
   ```bash
   docker run -p 5001:5000 --name my-python-app python-app
   # Access at http://localhost:5001 instead
   ```

### Problem: Permission Denied

**Error Message:**
```
permission denied while trying to connect to the Docker daemon socket
```

**What it means:** Your user doesn't have permission to access Docker.

**Solution (Linux/Mac):**
```bash
# Add your user to docker group (Linux)
sudo usermod -aG docker $USER
# Log out and log back in

# Or use sudo (not recommended for production)
sudo docker run -p 5000:5000 --name my-python-app python-app
```
