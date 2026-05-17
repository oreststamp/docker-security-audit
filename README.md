# Docker Security Audit

A Bash script that automatically audits Docker images for security issues.

## What It Does

- Checks if the container runs as root
- Lists exposed ports
- Reports image creation date
- Scans for HIGH and CRITICAL CVEs using Trivy

## Usage

```bash
bash audit.sh <image-name>
```

## Example

```bash
bash audit.sh nginx:1.21
```

## Skills Demonstrated

- Bash scripting
- Docker image inspection
- Container security (CVE scanning with Trivy)
- DevSecOps practices
