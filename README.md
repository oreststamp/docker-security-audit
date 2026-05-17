
# Docker Security Audit Pipeline

A DevSecOps project that automatically audits Docker images 
for security vulnerabilities using Bash, Trivy, and GitHub Actions.

## What It Does

- Builds a Docker image from source on every push
- Scans it for CRITICAL CVEs using Trivy
- Fails the pipeline if critical vulnerabilities are found
- Audits nginx:1.21 vs nginx:latest to compare security posture
- Checks for non-root user, exposed ports, and image age

## Pipeline

push code → build image → scan for CVEs → fail if critical found

## Tools Used

- Docker
- Trivy (Aqua Security)
- GitHub Actions
- Bash

## Usage

Run the audit script manually on any local image:

```bash
bash audit.sh <image-name>
```

## Example Output
[ Checking User ]
✓ PASS - Container runs as non-root user: appuser
[ Running CVE Scan with Trivy ]
Total: 17 (HIGH: 14, CRITICAL: 3)

