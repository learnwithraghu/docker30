# Lesson 07: Docker Networking Basics

## 🎯 Learning Objectives
- Understand Docker network types
- Create and manage networks
- Connect containers to networks
- Understand container communication

## 📚 Key Terminologies & Real-World Use Cases

### Docker Networking

**What it is:** Docker provides networking so containers can communicate with each other and the outside world.

**Real-World Analogy:**
Think of Docker networks like **apartment buildings**:
- **Bridge network**: Private apartment complex (containers can talk to each other)
- **Host network**: Living directly on the street (uses host's network)
- **None network**: Living in isolation (no network access)

**Why we need it:**
- **Service Communication**: Microservices need to talk to each other
- **Isolation**: Separate networks for different applications
- **DNS Resolution**: Containers can find each other by name
- **Security**: Network isolation provides security boundaries

**Real-World Use Case:** Your application has a web server, API, and database. They all need to communicate. You put them on the same Docker network - they can talk by name (web → api → db), but are isolated from other applications.

### Network Types

**1. Bridge Network (Default)**
- **What:** Isolated network with NAT
- **Best for:** Most applications
- **Why:** Provides isolation while allowing communication

**2. Host Network**
- **What:** Uses host's network directly
- **Best for:** High-performance applications
- **Why:** No NAT overhead, direct network access

**3. None Network**
- **What:** No network interfaces
- **Best for:** Security-sensitive containers
- **Why:** Complete network isolation

**4. Custom Bridge Networks**
- **What:** User-created bridge networks
- **Best for:** Multi-container applications
- **Why:** DNS resolution by name, better isolation

**Real-World Use Case:** Default bridge network doesn't support DNS by name (must use IPs). Custom networks enable DNS - your web container can connect to `db:5432` instead of `172.18.0.5:5432`. Much easier!

## 🚀 Hands-On Tutorial

### Part 1: Custom Network with DNS

#### Step 1: Create Custom Network

**Why:** Custom networks support DNS resolution - containers can use names.

```bash
docker network create demo-network
```

**What happens:** Creates a new bridge network with DNS support.

#### Step 2: Start Containers on Network

**Why:** Connect containers to the network so they can communicate.

```bash
docker run --name server1 --network demo-network nginx:alpine
docker run --name server2 --network demo-network nginx:alpine
```

**What `--network demo-network` does:**
- Connects container to our custom network
- Both containers can now use DNS names

#### Step 3: Test Connectivity by Name

**Why:** Prove DNS resolution works - containers can use names, not IPs.

```bash
docker exec server1 ping -c 3 server2
```

**Expected Output:**
```
PING server2 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.123 ms
...
```

**🎉 Success!** DNS resolution works - used name, not IP!

#### Step 4: Inspect Network

**Why:** See which containers are connected.

```bash
docker network inspect demo-network
```

**What it shows:** All containers on the network, their IPs, and configuration.

#### Step 5: Clean Up

```bash
docker stop server1 server2
docker rm server1 server2
docker network rm demo-network
```

### Part 2: Web and Database Network

#### Step 1: Create Application Network

**Why:** Real apps need services to communicate.

```bash
docker network create app-net
```

#### Step 2: Start Database

**Why:** Database is backend service.

```bash
docker run \
  --name postgres-db \
  --network app-net \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=testdb \
  postgres:15-alpine
```

**What `--network app-net` does:**
- Connects database to network
- Other containers can reach it by name `postgres-db`

#### Step 3: Start Web Server

**Why:** Web server needs to reach database.

```bash
docker run \
  --name web-server \
  --network app-net \
  -p 8080:80 \
  nginx:alpine
```

**What happens:**
- Same network as database
- Can access database using name `postgres-db`
- Port 8080 exposed to host

#### Step 4: Test Connectivity

**Why:** Verify web server can reach database by name.

```bash
docker exec web-server ping -c 3 postgres-db
```

**Expected Output:**
```
PING postgres-db (172.18.0.2): 56 data bytes
64 bytes from 172.18.0.2: seq=0 ttl=64 time=0.123 ms
...
```

**Real-World:** In your app, web server would connect to `postgres-db:5432` (using name, not IP!)

#### Step 5: Clean Up

```bash
docker stop postgres-db web-server
docker rm postgres-db web-server
docker network rm app-net
```

## 🎓 Key Takeaways

1. **Default bridge** doesn't support DNS resolution by name
2. **Custom networks** support DNS resolution (containers can use names)
3. Containers on **same network** can communicate
4. Containers on **different networks** are isolated
5. Use `docker network create` to create custom networks
6. Use `--network` flag to connect containers
7. **One container can be on multiple networks**

## 💡 Interview Questions

1. **What are the default Docker networks?**
   - bridge, host, none

2. **How do containers communicate on a custom network?**
   - By container name (DNS resolution)

3. **What's the difference between bridge and host network?**
   - Bridge: Isolated network with NAT
   - Host: Uses host's network directly

4. **How do you create a custom network?**
   - `docker network create <network-name>`

5. **Can a container be on multiple networks?**
   - Yes! Use `docker network connect`

6. **Why use custom networks instead of default bridge?**
   - Custom networks support DNS resolution by name
   - Better isolation between applications
   - Easier service discovery
