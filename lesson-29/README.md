# Lesson 29: Docker Monitoring and Observability

## 🎯 Learning Objectives
- Monitor Docker containers
- Use monitoring tools
- Collect metrics
- Set up logging
- Practice observability

## 📚 Key Terminologies & Real-World Use Cases

### Monitoring and Observability

**What it is:** Tracking container health, performance, and behavior to ensure applications run correctly and identify issues quickly.

**Real-World Analogy:**
Think of monitoring like a **car dashboard**:
- **Metrics** = Speed, fuel, temperature (CPU, memory, disk)
- **Logs** = Event recorder (application logs)
- **Traces** = GPS tracking (request flow)
- **Alerts** = Warning lights (notifications)

**Why we need it:**
- **Proactive Detection**: Find issues before users notice
- **Performance Optimization**: Identify bottlenecks
- **Capacity Planning**: Plan resource needs
- **Troubleshooting**: Understand what went wrong
- **Compliance**: Meet monitoring requirements

**Real-World Use Case:** Production application suddenly slow. Without monitoring: Users complain, no idea why. With monitoring: See CPU spike, memory leak, identify problematic container, fix issue in minutes. Monitoring saves the day!

### Monitoring Tools

**1. Docker Stats**
- **What:** Built-in container monitoring
- **Use case:** Quick health checks
- **Why:** No setup required

**2. Prometheus**
- **What:** Metrics collection and storage
- **Use case:** Long-term metrics
- **Why:** Industry standard

**3. Grafana**
- **What:** Visualization and dashboards
- **Use case:** Visualize metrics
- **Why:** Beautiful dashboards

**4. cAdvisor**
- **What:** Container Advisor - collects container metrics
- **Use case:** Container-specific metrics
- **Why:** Detailed container insights

**Real-World Use Case:** Production cluster with 50 containers. Prometheus collects metrics, Grafana visualizes, alerts fire on high CPU. Team notified instantly, issue resolved before users affected. Full observability!

## 🚀 Hands-On Tutorial

### Part 1: Docker Stats

#### Step 1: Real-Time Monitoring

**Why:** Quick view of container health.

```bash
docker stats
```

**What it shows:**
- CPU usage
- Memory usage
- Network I/O
- Block I/O
- Updates in real-time

**Expected Output:**
```
CONTAINER   CPU %   MEM USAGE / LIMIT   MEM %   NET I/O
web1        0.50%   50MiB / 512MiB      9.77%   1.2kB / 648B
db1         2.30%   200MiB / 1GiB       19.53%   2.1kB / 1.5kB
```

#### Step 2: Monitor Specific Container

**Why:** Focus on one container.

```bash
docker stats web1 --no-stream
```

**What it does:**
- Shows stats once (no continuous update)
- Useful for scripts
- Specific container only

#### Step 3: Custom Format

**Why:** Get specific metrics.

```bash
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

**What it shows:**
- Only CPU and memory
- Customized output
- Useful for automation

### Part 2: Prometheus + cAdvisor

#### Step 1: Set Up Monitoring Stack

**Why:** Professional monitoring solution.

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

**What it does:**
- cAdvisor: Collects container metrics
- Prometheus: Stores and queries metrics
- Accessible via web UI

#### Step 2: Configure Prometheus

**Why:** Tell Prometheus where to get metrics.

Create `prometheus.yml`:
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
```

**What it does:**
- Scrapes metrics from cAdvisor
- Every 15 seconds
- Stores in Prometheus

#### Step 3: Start Monitoring

**Why:** Start monitoring stack.

```bash
docker-compose up
```

**What happens:**
- cAdvisor collects metrics
- Prometheus stores them
- Access at http://localhost:9090

### Part 3: Log Aggregation

#### Step 1: View Container Logs

**Why:** Application logs are crucial.

```bash
docker logs web1
```

**What it shows:**
- All stdout/stderr output
- Application logs
- Useful for debugging

#### Step 2: Follow Logs

**Why:** Real-time log monitoring.

```bash
docker logs -f web1
```

**What it does:**
- Follows logs in real-time
- Like `tail -f`
- Essential for production

#### Step 3: Filter Logs

**Why:** Find specific entries.

```bash
docker logs web1 2>&1 | grep ERROR
docker logs web1 --since 10m
```

**What it does:**
- Filters for errors
- Shows last 10 minutes
- Useful for troubleshooting

### Part 4: Resource Monitoring

#### Step 1: Check Disk Usage

**Why:** Monitor storage.

```bash
docker system df
```

**What it shows:**
- Images size
- Containers size
- Volumes size
- Build cache size

**Expected Output:**
```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          5         3         2.5GB     1.2GB (48%)
Containers      10        5         500MB      200MB (40%)
Volumes         3         2         1GB        500MB (50%)
```

#### Step 2: Monitor Network

**Why:** Track network usage.

```bash
docker stats --format "table {{.Container}}\t{{.NetIO}}"
```

**What it shows:**
- Network input/output
- Bandwidth usage
- Useful for capacity planning

## 🎓 Key Takeaways

1. **docker stats** for real-time monitoring
2. **docker logs** for log viewing
3. **Prometheus** for metrics collection
4. **Grafana** for visualization
5. **cAdvisor** for container metrics
6. **Set up alerts** for issues
7. **Monitor** CPU, memory, network, disk

## 🔄 Next Steps

- Set up monitoring for your apps
- Configure alerts
- Move to Lesson 30 for troubleshooting

## 💡 Interview Questions

1. **How do you monitor Docker containers?**
   - `docker stats` (built-in)
   - Prometheus + cAdvisor (advanced)
   - Cloud monitoring tools

2. **What metrics should you monitor?**
   - CPU usage
   - Memory usage
   - Network I/O
   - Disk I/O
   - Container health

3. **How do you aggregate logs?**
   - ELK stack (Elasticsearch, Logstash, Kibana)
   - Fluentd
   - Cloud logging services

4. **What is cAdvisor?**
   - Container Advisor
   - Collects container metrics
   - Exposes Prometheus metrics

5. **Why is monitoring important?**
   - Detect issues early
   - Optimize performance
   - Plan capacity
   - Troubleshoot problems

6. **How do you set up alerts?**
   - Prometheus Alertmanager
   - Grafana alerts
   - Cloud monitoring alerts

7. **What's the difference between metrics and logs?**
   - Metrics: Numerical data (CPU, memory)
   - Logs: Text events (application output)
