# Application Health Checker (Uptime Monitor)

[![Docker](https://img.shields.io/badge/Docker-Supported-blue.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![Linux](https://img.shields.io/badge/Platform-Linux%20%7C%20WSL-lightgrey.svg?logo=linux&logoColor=white)](https://www.kernel.org/)
[![Shell](https://img.shields.io/badge/Language-POSIX%20Shell%20%2F%20Bash-orange.svg?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An automated, lightweight Application Health Checker written in POSIX Shell and `curl`. It accurately checks the uptime and responsiveness of applications and web APIs by evaluating HTTP status codes, network latency, and connection availability in real time.

---

## Dashboard Preview

<!-- Upload your screenshot to docs/dashboard.png to display it here -->
![Application Health Checker Preview](docs/dashboard.png)

---

## Features

- **Accurate Status Evaluation:**
  - **`UP`**: HTTP status codes `200–399` (Service is functioning and responding properly).
  - **`DOWN`**: HTTP status codes `4xx` (Client errors), `5xx` (Server errors), DNS failures, or connection timeouts.
- **Production-Ready Redirect Handling:** Uses `curl -L` to follow redirects (`301`, `302`), ensuring accurate health status for production domains.
- **Latency Monitoring:** Measures and logs round-trip response time per endpoint in seconds.
- **Timeout Protection:** Configurable timeout limits (`TIMEOUT=5s`) to prevent requests from hanging indefinitely.
- **Color-Coded Terminal UI:** Visual status table with clear indicators (Green for `UP`, Red for `DOWN`).
- **Persistent Incident Logging:** Logs all check results and failure incidents with timestamps to `/var/log/app_health.log`.
- **Dual Execution Modes:** Runs directly on bare-metal Linux / WSL or inside a minimal Alpine Linux Docker container.

---

## Monitored Endpoints (Included Test Suite)

| Endpoint | Target Checked | Expected Status | Description |
| :--- | :--- | :--- | :--- |
| `https://www.dev-cv.in` | Live Website | **`UP`** (`200 OK`) | Production personal domain |
| `https://www.dev-cv.in/non-existing-page-test` | Missing Route | **`DOWN`** (`404 Not Found`) | 4xx client-error testing |
| `https://httpbin.org/status/200` | Mock API | **`UP`** (`200 OK`) | Successful API response test |
| `https://httpbin.org/status/500` | Mock Server | **`DOWN`** (`500 Server Error`) | 5xx server-error handling |
| `https://invalid-broken-domain-test.com` | Dead Host | **`DOWN`** (`N/A`) | DNS resolution / timeout failure |

---

## Method 1: Running with Docker (Recommended)

Run the health checker in an isolated Alpine container without installing extra dependencies on your host.

### 1. Build the Docker Image
```bash
docker build -t app-health-checker .

2. Run the Container

docker run --rm -it app-health-checker

Note: Press Ctrl + C at any time to stop the checker.

Method 2: Running Directly on Native Linux / WSL (Without Docker)

You can run app_checker.sh directly on any Linux distribution or Windows
Subsystem for Linux (WSL).

1. Prerequisites

Ensure curl is installed:

  - Ubuntu / Debian: sudo apt update && sudo apt install -y curl
  - RHEL / CentOS / Fedora: sudo dnf install -y curl
  - Alpine Linux: apk add --no-cache curl

2. Setup and Execution

# Clone the repository
git clone https://github.com/ChandraprakashAnandakumar/application-health-checker.git
cd application-health-checker

# Make script executable
chmod +x app_checker.sh

# Run the live health checker
./app_checker.sh

Example Console Output

========================================================================================
                   APPLICATION HEALTH CHECKER (UPTIME MONITOR)                          
                   Timestamp: 2026-11-01 07:15:20 | Timeout: 5s                
========================================================================================
APPLICATION URL                                | STATUS   | CODE   | RESPONSE TIME
-----------------------------------------------+----------+--------+--------------
https://www.dev-cv.in                          | UP       | 200    | 0.421s    
https://www.dev-cv.in/non-existing-page-test   | DOWN     | 404    | 0.380s    
https://httpbin.org/status/200                 | UP       | 200    | 0.312s    
https://httpbin.org/status/500                 | DOWN     | 500    | 0.295s    
https://invalid-broken-domain-test.com         | DOWN     | N/A    | 5.00s     
========================================================================================
Logs saved to: /var/log/app_health.log
Next refresh in 5s. Press [Ctrl+C] to exit.

Log Output

All status checks and alerts are appended to /var/log/app_health.log:

[2026-11-01 07:15:20] [UP] URL: https://www.dev-cv.in | Code: 200 | Latency: 0.421s
[2026-11-01 07:15:20] [DOWN] URL: https://www.dev-cv.in/non-existing-page-test | Code: 404 | Latency: 0.380s
[2026-11-01 07:15:20] [DOWN] URL: https://invalid-broken-domain-test.com | Code: N/A (Connection Failed) | Latency: 5.00s

Project Structure

application-health-checker/
├── docs/
│   
├── Dockerfile           # Alpine container image configuration
├── app_checker.sh       # Main POSIX Shell health monitor script
├── .gitignore           # Ignored system files and logs
└── README.md            # Project documentation



### How to update it directly on GitHub:
1. Go to your repository: `https://github.com/ChandraprakashAnandakumar/application-health-checker`
2. Click on the **`README.md`** file.
3. Click the ✏️ **Edit this file** (pencil icon) on the top right.
4. Select all (`Ctrl + A`), delete, and paste the code above.
5. Click the green **Commit changes...** button at the top right.
