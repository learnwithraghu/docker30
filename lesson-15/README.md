# Lesson 15: Docker Logs and Debugging

## 🎯 Learning Objectives
- View container logs
- Follow logs in real-time
- Understand log drivers
- Debug container issues

## 📚 Key Terminologies & Real-World Use Cases

### Container Logs

**What they are:** All output from containers (stdout and stderr) captured by Docker. Essential for debugging and monitoring.

**Real-World Analogy:**
Think of container logs like **flight recorder data**:
- Records everything the application does
- Helps diagnose problems after they occur
- Can be streamed in real-time
- Essential for debugging

**Why we need them:**
- **Debugging**: See what went wrong when container fails
- **Monitoring**: Track application behavior over time
- **Troubleshooting**: Understand why application isn't working
- **Auditing**: Track what happened for compliance
- **Performance**: Identify bottlenecks and issues

**Real-World Use Case:** Production application suddenly stops responding. You check logs: `OutOfMemoryError`. Without logs, you'd have no idea what happened. With logs, you immediately see the issue and can fix it (increase memory limit).

### Log Drivers

**What they are:** Different ways Docker can store and handle logs.

**Types:**
1. **json-file** (default): Logs stored in JSON files on host
2. **syslog**: Send to syslog daemon
3. **journald**: Systemd journal (Linux)
4. **gelf**: Graylog Extended Log Format
5. **fluentd**: Fluentd logging driver

**Why different drivers:**
- **json-file**: Simple, works everywhere
- **syslog/journald**: Integrate with system logging
- **gelf/fluentd**: Centralized log aggregation (ELK stack, Splunk)

**Real-World Use Case:** Company has 100 containers across 10 servers. Using json-file, logs are scattered. Using fluentd driver, all logs go to centralized ELK stack. One place to search, analyze, and alert on all logs!

## 🚀 Hands-On Tutorial

### Part 1: Basic Log Viewing

#### Step 1: Start a Container

**Why:** Need a running container to view logs.

```bash
docker run --name log-demo nginx:alpine
```

#### Step 2: View All Logs

**Why:** See what the container has logged.

```bash
docker logs log-demo
```

**What it shows:**
- All stdout and stderr output
- Complete log history
- Useful for seeing what happened

**Expected Output:**
```
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
...
```

#### Step 3: View Last N Lines

**Why:** When logs are long, see only recent entries.

```bash
docker logs --tail 10 log-demo
```

**What it does:**
- Shows last 10 lines
- Useful for recent activity
- Faster than viewing all logs

#### Step 4: View with Timestamps

**Why:** Timestamps help correlate events and debug timing issues.

```bash
docker logs -t log-demo | head -5
```

**What `-t` does:**
- Adds timestamp to each line
- Shows when each event occurred
- Critical for debugging

**Expected Output:**
```
2024-01-15T10:30:45.123456789Z /docker-entrypoint.sh: ...
2024-01-15T10:30:45.234567890Z /docker-entrypoint.sh: ...
```

### Part 2: Real-Time Log Monitoring

#### Step 1: Follow Logs

**Why:** See logs as they're generated (like `tail -f`).

```bash
docker logs -f log-demo
```

**What `-f` does:**
- Follows logs in real-time
- Shows new entries as they appear
- Press `Ctrl+C` to stop
- Essential for production monitoring

**Real-World:** Production issue occurs. You run `docker logs -f app` and watch logs in real-time to see what's happening.

#### Step 2: Filter by Time

**Why:** See logs from specific time period.

```bash
# Logs from last 10 minutes
docker logs --since 10m log-demo

# Logs since specific time
docker logs --since 2024-01-15T10:00:00 log-demo

# Logs until specific time
docker logs --until 2024-01-15T12:00:00 log-demo
```

**What it does:**
- Filters logs by time
- Useful for finding issues at specific times
- Reduces log volume to relevant entries

### Part 3: Log Drivers

#### Step 1: View Default Log Driver

**Why:** See current log configuration.

```bash
docker inspect log-demo --format '{{.HostConfig.LogConfig.Type}}'
```

**Expected Output:**
```
json-file
```

#### Step 2: Run with Custom Log Driver

**Why:** Configure log size limits and rotation.

```bash
docker run \
  --log-driver json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  --name log-limited nginx:alpine
```

**What each option does:**
- `max-size=10m`: Each log file max 10MB
- `max-file=3`: Keep 3 log files (rotates when full)
- Prevents logs from filling disk

**Real-World Use Case:** Container generates 1GB of logs per day. Without limits, disk fills up. With max-size and max-file, only keeps 30MB (3 files × 10MB). Disk stays healthy!

#### Step 3: Check Log Files

**Why:** See where logs are stored.

```bash
docker inspect log-limited --format '{{.LogPath}}'
```

**What it shows:** Path to log file on host system

### Part 4: Debugging with Logs

#### Step 1: Generate Some Logs

**Why:** Create log entries to work with.

```bash
# Make some requests to generate logs
curl http://localhost:8080 2>/dev/null
curl http://localhost:8080 2>/dev/null
```

#### Step 2: Search Logs

**Why:** Find specific entries in logs.

```bash
docker logs log-demo | grep "GET"
docker logs log-demo | grep -i error
```

**What it does:**
- Filters logs for specific patterns
- Useful for finding errors or specific events
- Can combine with other filters

#### Step 3: Clean Up

```bash
docker stop log-demo log-limited
docker rm log-demo log-limited
```

## 🎓 Key Takeaways

1. **docker logs** to view container output
2. **-f flag** to follow logs in real-time
3. **-t flag** for timestamps
4. **--since/--until** for time filtering
5. **Log drivers** control where logs go
6. **Log limits** prevent disk filling (max-size, max-file)
7. **Logs persist** after container stops (until removed)

## 💡 Interview Questions

1. **How do you view container logs?**
   - `docker logs <container-id>`

2. **How do you follow logs in real-time?**
   - `docker logs -f <container-id>`

3. **What is the default log driver?**
   - json-file

4. **How do you limit log size?**
   - Use `--log-opt max-size` and `max-file`

5. **Do logs persist after container removal?**
   - No, unless using external log driver

6. **How do you view logs with timestamps?**
   - `docker logs -t <container-id>`

7. **How do you filter logs by time?**
   - `docker logs --since 10m <container-id>`
   - `docker logs --until <time> <container-id>`
