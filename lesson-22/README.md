# Lesson 22: Docker Networking Advanced

## 🎯 Learning Objectives
- Understand advanced network drivers
- Create custom bridge networks
- Use host and macvlan networks
- Configure network isolation

## 📚 Key Terminologies & Real-World Use Cases

### Advanced Network Drivers

**What they are:** Different network types for different use cases, each with specific characteristics and capabilities.

**Real-World Analogy:**
Think of network drivers like **different types of roads**:
- **Bridge**: Private neighborhood (isolated, NAT)
- **Host**: Direct highway access (no isolation)
- **Macvlan**: Direct street address (container gets own IP)
- **Overlay**: Tunnel network (for Swarm)

**Why we need them:**
- **Bridge**: Default, isolated networks (most common)
- **Host**: High performance, direct network access
- **Macvlan**: Containers need direct network IPs
- **Overlay**: Multi-host networking (Swarm clusters)

**Real-World Use Case:** High-performance application needs maximum network speed. Use `host` network - no NAT overhead, direct access. Trade-off: no network isolation. Use when performance > isolation.

### Network Types

**1. Bridge (Default)**
- **What:** Isolated network with NAT
- **Use case:** Most applications
- **Why:** Provides isolation while allowing communication

**2. Host**
- **What:** Uses host's network directly
- **Use case:** High-performance applications
- **Why:** No NAT overhead, direct access
- **Note:** Linux only, no isolation

**3. Macvlan**
- **What:** Containers get own MAC addresses and IPs
- **Use case:** Containers need to appear as physical devices
- **Why:** Direct network access, own IP on network

**4. Overlay**
- **What:** Multi-host networking for Swarm
- **Use case:** Containers across multiple hosts
- **Why:** Enables service discovery across cluster

**Real-World Use Case:** IoT application - containers need to appear as physical devices on network. Use macvlan - each container gets own IP, appears as separate device. Perfect for device simulation!

## 🚀 Hands-On Tutorial

### Part 1: Custom Bridge Network

#### Step 1: Create Custom Bridge

**Why:** Custom networks with specific subnets for organization.

```bash
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  my-bridge
```

**What each option does:**
- `--driver bridge`: Bridge network type
- `--subnet=172.20.0.0/16`: Custom IP range
- `--gateway=172.20.0.1`: Gateway IP
- `my-bridge`: Network name

#### Step 2: Run Containers on Custom Network

**Why:** Containers on same network can communicate by name.

```bash
docker run --network my-bridge --name app1 nginx:alpine
docker run --network my-bridge --name app2 nginx:alpine
```

**What happens:**
- Both containers on `my-bridge` network
- Can communicate using names (app1, app2)
- DNS resolution works automatically

#### Step 3: Test Connectivity

**Why:** Verify containers can communicate.

```bash
docker exec app1 ping -c 3 app2
```

**Expected Output:**
```
PING app2 (172.20.0.3): 56 data bytes
64 bytes from 172.20.0.3: seq=0 ttl=64 time=0.123 ms
...
```

**🎉 Success!** Containers communicate by name!

#### Step 4: Inspect Network

**Why:** See network details and connected containers.

```bash
docker network inspect my-bridge
```

**What it shows:**
- Network configuration
- Connected containers
- IP addresses assigned
- Gateway information

### Part 2: Host Network

#### Step 1: Use Host Network

**Why:** Direct network access for high performance.

```bash
docker run --network host nginx:alpine
```

**What happens:**
- Container uses host's network directly
- No port mapping needed (uses host ports directly)
- No NAT overhead
- **Note:** Linux only, no network isolation

**Real-World:** High-performance web server. Use host network - eliminates NAT overhead, maximum speed. Trade-off: no isolation, must manage port conflicts.

### Part 3: Network Isolation

#### Step 1: Create Isolated Networks

**Why:** Separate networks for security and organization.

```bash
docker network create network-a
docker network create network-b
```

**What happens:**
- Two separate networks
- Containers on different networks can't communicate
- Provides network-level isolation

#### Step 2: Run Containers on Different Networks

**Why:** Demonstrate network isolation.

```bash
docker run --network network-a --name app-a nginx:alpine
docker run --network network-b --name app-b nginx:alpine
```

**What happens:**
- app-a on network-a
- app-b on network-b
- They cannot communicate (isolated)

#### Step 3: Connect Container to Multiple Networks

**Why:** Container can access multiple networks.

```bash
docker network connect network-b app-a
```

**What happens:**
- app-a now on both networks
- Can communicate with containers on both networks
- Useful for gateway/bridge containers

#### Step 4: Test Isolation

**Why:** Verify network isolation works.

```bash
# This will fail (different networks)
docker exec app-a ping -c 2 app-b

# After connecting, this works
docker exec app-a ping -c 2 app-b
```

### Part 4: Clean Up

```bash
docker stop app1 app2 app-a app-b
docker rm app1 app2 app-a app-b
docker network rm my-bridge network-a network-b
```

## 🎓 Key Takeaways

1. **Bridge**: Default, isolated networks (most common)
2. **Host**: Direct host network access (high performance, Linux only)
3. **Macvlan**: Containers get own IPs (appear as physical devices)
4. **Custom subnets** for organization
5. **Network isolation** for security
6. **Multiple networks** per container possible
7. **Overlay** for multi-host (Swarm)

## 🔄 Next Steps

- Practice with different network types
- Set up network isolation
- Move to Lesson 23 for secrets management

## 💡 Interview Questions

1. **What are the different network drivers?**
   - bridge, host, none, macvlan, overlay

2. **What's the difference between bridge and host?**
   - Bridge: Isolated with NAT
   - Host: Direct host network access (no isolation)

3. **What is macvlan used for?**
   - When containers need direct network access with own IPs
   - Containers appear as physical devices on network

4. **How do you create a custom subnet?**
   - `docker network create --subnet=172.20.0.0/16 <name>`

5. **Can a container be on multiple networks?**
   - Yes, use `docker network connect <network> <container>`

6. **What is overlay network?**
   - Multi-host networking for Docker Swarm
   - Enables containers across multiple hosts to communicate

7. **When would you use host network?**
   - High-performance applications where speed > isolation
   - Linux only, no port mapping needed
