# Lesson 02: Docker Installation and Setup

## 🎯 Learning Objectives
- Install Docker on different operating systems
- Verify Docker installation
- Understand Docker Desktop vs Docker Engine
- Learn essential verification commands

## 📚 Key Terminologies & Real-World Use Cases

### Docker Desktop vs Docker Engine

**Docker Desktop:**
- **What it is:** GUI application that includes Docker Engine, CLI, and Compose
- **Best for:** Development on Windows/Mac
- **Features:** Graphical interface, easy setup, integrated tools
- **Real-World Use:** Developers use this on their laptops for local development

**Docker Engine:**
- **What it is:** Command-line only Docker runtime
- **Best for:** Production servers, Linux environments
- **Features:** Lightweight, more control, no GUI overhead
- **Real-World Use:** Production servers run Docker Engine - no GUI needed, better performance

**Why the difference matters:**
- **Development:** Docker Desktop makes it easy to get started
- **Production:** Docker Engine is lighter, more secure, better for servers
- **Cost:** Docker Engine is free, Docker Desktop may require license for large companies

### System Requirements

**Why they matter:** Docker needs specific system capabilities to run containers efficiently.

- **Windows:** WSL 2, virtualization enabled
- **macOS:** Modern version (10.15+), virtualization support
- **Linux:** Modern kernel (3.10+), any distribution

**Real-World Use Case:** A developer tries to install Docker on an old Windows 7 machine. It fails because WSL 2 isn't supported. Understanding requirements prevents wasted time.

## 🚀 Hands-On: Installation & Verification

### Step 1: Install Docker

**For macOS:**
```bash
# Using Homebrew (recommended)
brew install --cask docker

# Or download from: https://www.docker.com/products/docker-desktop
```

**For Linux (Ubuntu/Debian):**
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo systemctl start docker
sudo systemctl status docker
# Log out and log back in
```

**For Windows:**
1. Enable WSL 2 in Windows Features
2. Download Docker Desktop from https://www.docker.com/products/docker-desktop
3. Run installer and restart

### Step 2: Verify Docker Version

**Why:** Confirm Docker is installed and see version information.

```bash
docker --version
```

**Expected Output:**
```
Docker version 24.0.0, build abc123
```

### Step 3: Check Docker Info

**Why:** Verify Docker daemon is running and see system information.

```bash
docker info | head -20
```

**What it shows:**
- Docker daemon status
- Number of containers and images
- System resources
- Configuration details

### Step 4: Run Hello World

**Why:** Ultimate test - if this works, Docker is fully functional.

```bash
docker run --rm hello-world
```

**What happens:**
- Downloads hello-world image (if not present)
- Creates and runs container
- Prints success message
- `--rm` automatically removes container

**Expected Output:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### Step 5: Verify Images and Containers

**Why:** See what Docker created during hello-world test.

```bash
# List images
docker images

# List containers (including stopped)
docker ps -a
```

**What you'll see:**
- `hello-world` image in the images list
- Container may or may not appear (depends on `--rm` flag)

## 🎓 Key Takeaways

1. **Docker Desktop** is easiest for development (Windows/Mac)
2. **Docker Engine** is for Linux servers and production
3. Always **verify installation** with `docker run hello-world`
4. **System requirements** must be met (WSL 2 for Windows, virtualization enabled)
5. **User permissions** matter on Linux (add user to docker group)

## 💡 Interview Questions

1. **How do you install Docker on Linux?**
   - Use package manager (apt/yum) with Docker's official repository
   - Add user to docker group to run without sudo

2. **What's the difference between Docker Desktop and Docker Engine?**
   - Desktop: GUI + Engine, for development (Windows/Mac)
   - Engine: CLI only, for servers/production (Linux)

3. **How do you verify Docker is working correctly?**
   - `docker --version` - check version
   - `docker run hello-world` - test functionality
   - `docker info` - verify daemon is running

4. **What are the system requirements for Docker?**
   - Windows: WSL 2, virtualization enabled
   - macOS: 10.15+, virtualization support
   - Linux: Kernel 3.10+, any modern distribution

5. **Why do you need to add user to docker group on Linux?**
   - Allows running Docker commands without sudo
   - Security: limits who can run Docker (requires group membership)
