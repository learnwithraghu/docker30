# Lesson 06: Docker Volumes and Data Persistence

## 🎯 Learning Objectives
- Understand why volumes are needed
- Learn about different volume types
- Create and manage volumes
- Practice data persistence

## 📚 Key Terminologies & Real-World Use Cases

### Why Volumes?

**What they are:** Persistent storage that survives container removal. Containers are ephemeral - when removed, all data inside is lost.

**Real-World Analogy:**
Think of a container like a **hotel room**. When you check out (container stops), everything in the room is cleaned (data is lost). Volumes are like a **storage locker** - your data stays safe even after you check out.

**Why we need them:**
- **Data Persistence**: Data survives container removal
- **Database Storage**: Databases need persistent storage for data
- **Shared Data**: Multiple containers can share the same volume
- **Backup & Recovery**: Volumes can be backed up independently

**Real-World Use Case:** You run a MySQL database in a container. Without volumes, if the container crashes or is updated, all your data is lost! With volumes, database data persists in the volume, safe from container lifecycle.

### Types of Volumes

**1. Named Volumes (Managed by Docker)**
- **What:** Docker-managed storage, stored in Docker's directory
- **Best for:** Databases, application data, production
- **Why:** Portable, managed by Docker, works across different hosts

**2. Bind Mounts (Host Filesystem)**
- **What:** Direct mapping to host directory
- **Best for:** Development, configuration files, logs
- **Why:** Edit files on host, see changes immediately in container

**3. tmpfs Mounts (In-Memory)**
- **What:** Stored in RAM, lost on reboot
- **Best for:** Temporary data, sensitive information
- **Why:** Fast, automatically cleaned up

**Real-World Use Case:** Developer uses bind mounts during development (edit code, see changes instantly). Production uses named volumes (data managed by Docker, portable across servers).

## 🚀 Hands-On Tutorial

### Part 1: Named Volumes - Data Persistence

#### Step 1: Create a Volume

**Why:** Create persistent storage that survives containers.

```bash
docker volume create demo-data
```

**What happens:** Docker creates a managed volume. This volume exists independently of any container.

#### Step 2: Write Data in Container

**Why:** Store data in the volume, then remove container to prove data persists.

```bash
docker run --rm \
  -v demo-data:/data \
  ubuntu:latest \
  sh -c "echo 'This data persists!' > /data/persistent.txt"
```

**What `-v demo-data:/data` does:**
- Mounts volume `demo-data` to `/data` in container
- Data written to `/data` is stored in the volume
- `--rm` removes container when it exits

#### Step 3: Verify Data Persists

**Why:** Create a NEW container and read data - proves volume survived.

```bash
docker run --rm \
  -v demo-data:/data \
  ubuntu:latest \
  cat /data/persistent.txt
```

**Expected Output:**
```
This data persists!
```

**🎉 Success!** Data survived container removal!

#### Step 4: Clean Up

```bash
docker volume rm demo-data
```

### Part 2: Bind Mounts - Development Workflow

#### Step 1: Create Project

**Why:** Bind mounts let you edit files on host, see changes in container.

```bash
mkdir dev-project
cd dev-project
echo "print('Hello from Docker!')" > app.py
```

#### Step 2: Run with Bind Mount

**Why:** Mount host directory into container for live editing.

```bash
docker run -it --rm \
  -v $(pwd):/app \
  -w /app \
  python:3.9-slim \
  python app.py
```

**What `-v $(pwd):/app` does:**
- `$(pwd)` = current directory on host
- `/app` = mount point in container
- Changes on host are immediately visible in container

#### Step 3: Edit and Re-run

**Why:** Demonstrate instant feedback - edit on host, run in container.

```bash
# Edit file on host
echo "print('Updated!')" >> app.py

# Run again - changes are visible
docker run -it --rm \
  -v $(pwd):/app \
  -w /app \
  python:3.9-slim \
  python app.py
```

**Expected Output:**
```
Hello from Docker!
Updated!
```

### Part 3: Shared Volumes - Multiple Containers

#### Step 1: Create Shared Volume

**Why:** Multiple containers can share the same volume.

```bash
docker volume create shared-data
```

#### Step 2: Container 1 Writes Data

```bash
docker run --rm \
  -v shared-data:/shared \
  ubuntu:latest \
  sh -c "echo 'File from Container 1' > /shared/file1.txt"
```

#### Step 3: Container 2 Writes Data

```bash
docker run --rm \
  -v shared-data:/shared \
  ubuntu:latest \
  sh -c "echo 'File from Container 2' > /shared/file2.txt"
```

#### Step 4: Container 3 Reads All Data

```bash
docker run --rm \
  -v shared-data:/shared \
  ubuntu:latest \
  sh -c "ls -la /shared && cat /shared/*.txt"
```

**Expected Output:**
```
file1.txt
file2.txt
File from Container 1
File from Container 2
```

**🎉 Success!** Multiple containers shared data!

#### Step 5: Clean Up

```bash
docker volume rm shared-data
cd .. && rm -rf dev-project
```

## 🎓 Key Takeaways

1. **Volumes persist data** beyond container lifecycle
2. **Named volumes** are managed by Docker (best for production)
3. **Bind mounts** map host directories (best for development)
4. **Multiple containers** can share the same volume
5. Use `docker volume create` to create named volumes
6. Use `-v` or `--mount` to attach volumes
7. **Always backup volumes** before removing containers

## 💡 Interview Questions

1. **What is a Docker volume?**
   - Persistent storage mechanism that survives container removal

2. **What's the difference between named volumes and bind mounts?**
   - Named volumes: Managed by Docker, stored in Docker directory
   - Bind mounts: Direct access to host filesystem

3. **How do you share data between containers?**
   - Use the same named volume in multiple containers

4. **What happens to data in a volume when a container is removed?**
   - Data persists! Volumes are independent of containers

5. **How do you backup a Docker volume?**
   - Use `docker run` with volume mount to copy data out

6. **When would you use bind mounts vs named volumes?**
   - Bind mounts: Development (edit files on host)
   - Named volumes: Production (Docker-managed, portable)
