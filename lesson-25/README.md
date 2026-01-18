# Lesson 25: Docker Security Best Practices

## 🎯 Learning Objectives
- Understand Docker security concerns
- Implement security best practices
- Use non-root users
- Scan images for vulnerabilities
- Secure container deployments

## 📚 Key Terminologies & Real-World Use Cases

### Docker Security

**What it is:** Practices and techniques to secure Docker containers and images, protecting against vulnerabilities and attacks.

**Real-World Analogy:**
Think of Docker security like **home security**:
- **Non-root user** = Don't give everyone master key
- **Minimal base images** = Fewer entry points
- **Image scanning** = Security inspection
- **Secrets management** = Safe for valuables
- **Network isolation** = Locked doors

**Why we need it:**
- **Shared Kernel**: Containers share host kernel (attack surface)
- **Image Vulnerabilities**: Base images may have vulnerabilities
- **Privilege Escalation**: Root containers can be dangerous
- **Data Leakage**: Secrets in images or logs
- **Compliance**: Security requirements must be met

**Real-World Use Case:** Production application compromised. Attacker gains root access in container. Without security practices, they could escape to host. With non-root user, minimal image, and limited capabilities - damage is contained. Security saves the day!

### Security Best Practices

**1. Use Non-Root Users**
- **Why:** Reduces risk if container is compromised
- **How:** Create user in Dockerfile, switch with USER

**2. Minimal Base Images**
- **Why:** Smaller attack surface, fewer vulnerabilities
- **How:** Use Alpine, distroless, or scratch

**3. Scan Images**
- **Why:** Find vulnerabilities before deployment
- **How:** Use Docker Scout, Trivy, or Snyk

**4. Don't Store Secrets**
- **Why:** Secrets in images can be extracted
- **How:** Use secrets management

**5. Limit Capabilities**
- **Why:** Containers don't need all Linux capabilities
- **How:** Use `--cap-drop` and `--cap-add`

**Real-World Use Case:** Application needs to bind to port 80 (requires root). Instead of running as root, use `--cap-add NET_BIND_SERVICE` - container can bind to port 80 without full root privileges. Principle of least privilege!

## 🚀 Hands-On Tutorial

### Part 1: Non-Root User

#### Step 1: Create Secure Dockerfile

**Why:** Run container as non-root user.

Create `Dockerfile`:
```dockerfile
FROM node:18-alpine

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy files with correct ownership
COPY --chown=appuser:appuser package*.json ./
RUN npm ci --only=production

COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

EXPOSE 3000
CMD ["node", "server.js"]
```

**What each part does:**
- Creates user `appuser` (UID 1000)
- Sets file ownership
- Switches to non-root user
- Container runs as non-root

#### Step 2: Build and Verify

**Why:** Confirm container runs as non-root.

```bash
docker build -t secure-app .
docker run --name secure-demo secure-app
docker exec secure-demo whoami
```

**Expected Output:**
```
appuser
```

**What you see:** Container runs as `appuser`, not `root`

### Part 2: Minimal Base Images

#### Step 1: Compare Image Sizes

**Why:** Smaller images = smaller attack surface.

```bash
# Large base image
docker pull ubuntu:latest
docker images ubuntu

# Minimal base image
docker pull alpine:latest
docker images alpine
```

**What you see:**
- Ubuntu: ~70MB
- Alpine: ~5MB
- **14x smaller!** Fewer packages = fewer vulnerabilities

#### Step 2: Use Alpine

**Why:** Alpine is minimal and secure.

```dockerfile
# ❌ Bad: Large base image
FROM ubuntu:latest

# ✅ Good: Minimal base image
FROM alpine:latest

# Or use distroless (even more minimal)
FROM gcr.io/distroless/nodejs:18
```

**What it does:**
- Alpine: Minimal Linux distribution
- Distroless: No shell, no package manager (maximum security)

### Part 3: Image Scanning

#### Step 1: Scan with Docker Scout

**Why:** Find vulnerabilities before deployment.

```bash
# Scan image (if Docker Scout available)
docker scout cves secure-app
```

**What it shows:**
- List of vulnerabilities
- Severity levels (Critical, High, Medium, Low)
- Fix recommendations

#### Step 2: Scan with Trivy

**Why:** Alternative scanning tool.

```bash
# Install Trivy (if available)
# trivy image secure-app
```

**What it shows:**
- Vulnerability database
- CVE details
- Fix versions

**Real-World:** Scan before every deployment. Found critical vulnerability in base image. Update base image, rebuild, redeploy. Vulnerability fixed before production!

### Part 4: Limit Capabilities

#### Step 1: Drop All Capabilities

**Why:** Start with no capabilities, add only what's needed.

```bash
docker run \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --name limited nginx:alpine
```

**What it does:**
- `--cap-drop ALL`: Removes all capabilities
- `--cap-add NET_BIND_SERVICE`: Adds only what's needed
- Principle of least privilege

#### Step 2: Read-Only Filesystem

**Why:** Prevent writes to container filesystem.

```bash
docker run \
  --read-only \
  --tmpfs /tmp \
  --name readonly nginx:alpine
```

**What it does:**
- `--read-only`: Makes root filesystem read-only
- `--tmpfs /tmp`: Allows writes to /tmp only
- Prevents malicious writes

### Part 5: Security Checklist

#### Step 1: Review Security Practices

**Why:** Ensure all practices are followed.

**Security Checklist:**
- [ ] Use non-root user
- [ ] Minimal base image (Alpine, distroless)
- [ ] Scan images for vulnerabilities
- [ ] No secrets in images
- [ ] Limit capabilities
- [ ] Read-only filesystem where possible
- [ ] Network isolation
- [ ] Resource limits
- [ ] Regular updates
- [ ] Use secrets management

#### Step 2: Secure Dockerfile Template

**Why:** Template for secure images.

```dockerfile
FROM alpine:latest

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy with correct ownership
COPY --chown=appuser:appuser . .

# Switch to non-root
USER appuser

# Health check
HEALTHCHECK --interval=30s CMD healthcheck.sh

# Run as non-root
CMD ["app"]
```

## 🎓 Key Takeaways

1. **Always use non-root** users
2. **Minimal images** reduce attack surface (Alpine, distroless)
3. **Scan images** regularly for vulnerabilities
4. **Never store secrets** in images
5. **Limit capabilities** (principle of least privilege)
6. **Read-only filesystem** where possible
7. **Network isolation** for security
8. **Keep images updated**

## 🔄 Next Steps

- Implement security in your images
- Set up image scanning in CI/CD
- Move to Lesson 26 for multi-arch builds

## 💡 Interview Questions

1. **Why use non-root users?**
   - Reduces risk if container is compromised
   - Principle of least privilege

2. **What are minimal base images?**
   - Small images with only essential packages
   - Examples: Alpine, distroless, scratch
   - Smaller attack surface

3. **How do you scan images for vulnerabilities?**
   - Use Docker Scout, Trivy, or Snyk
   - Scan before every deployment

4. **Should you store secrets in images?**
   - No! Use secrets management
   - Secrets in images can be extracted

5. **What is read-only filesystem?**
   - Prevents writes to container filesystem
   - Security: Can't modify system files
   - Use `--read-only` flag

6. **What are Linux capabilities?**
   - Fine-grained permissions
   - Drop all, add only what's needed
   - More secure than full root

7. **Why use network isolation?**
   - Containers on different networks can't communicate
   - Reduces attack surface
   - Defense in depth
