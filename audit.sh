#!/bin/bash

# ─── Colors ───────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ─── Helper functions ─────────────────────────────────
pass() { echo -e "${GREEN}  ✓ PASS${NC} - $1"; }
fail() { echo -e "${RED}  ✗ FAIL${NC} - $1"; }
warn() { echo -e "${YELLOW}  ⚠ WARN${NC} - $1"; }
info() { echo -e "${BLUE}  ℹ INFO${NC} - $1"; }

# ─── Check Docker is running ──────────────────────────
check_docker_running() {
    echo ""
    echo "[ Checking Docker ]"
    docker info > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        fail "Docker is not running. Start Docker and try again."
        exit 1
    fi
    pass "Docker is running"
}

# ─── Check if image exists ────────────────────────────
check_image_exists() {
    echo ""
    echo "[ Checking Image: $IMAGE ]"
    docker image inspect $IMAGE > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        fail "Image '$IMAGE' not found locally"
        exit 1
    fi
    pass "Image found locally"
}

# ─── Check if container runs as root ──────────────────
check_root_user() {
    echo ""
    echo "[ Checking User ]"
    USER=$(docker inspect $IMAGE \
        --format='{{.Config.User}}')
    if [ -z "$USER" ] || [ "$USER" = "root" ]; then
        fail "Container runs as root - this is a security risk"
    else
        pass "Container runs as non-root user: $USER"
    fi
}

# ─── Check exposed ports ──────────────────────────────
check_exposed_ports() {
    echo ""
    echo "[ Checking Exposed Ports ]"
    PORTS=$(docker inspect $IMAGE \
        --format='{{range $port, $_ := .Config.ExposedPorts}}{{$port}} {{end}}')
    if [ -z "$PORTS" ]; then
        info "No ports exposed"
    else
        warn "Exposed ports: $PORTS"
        warn "Make sure only required ports are exposed"
    fi
}

# ─── Check image age ──────────────────────────────────
check_image_age() {
    echo ""
    echo "[ Checking Image Age ]"
    CREATED=$(docker inspect $IMAGE \
        --format='{{.Created}}' | cut -c1-10)
    info "Image created on: $CREATED"
    warn "Always verify base images are recently updated"
}

# ─── Run Trivy CVE scan ───────────────────────────────
check_cves() {
    echo ""
    echo "[ Running CVE Scan with Trivy ]"
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy:latest image \
        --severity HIGH,CRITICAL \
        --quiet $IMAGE 2>/dev/null
    if [ $? -eq 0 ]; then
        pass "Trivy scan completed"
    else
        fail "Trivy scan encountered an error"
    fi
}

# ─── Main ─────────────────────────────────────────────
echo "======================================"
echo "   Docker Security Audit Script"
echo "   Target: $1"
echo "======================================"

IMAGE=$1

if [ -z "$IMAGE" ]; then
    echo "Usage: bash audit.sh <image-name>"
    echo "Example: bash audit.sh secubox:v1"
    exit 1
fi

check_docker_running
check_image_exists
check_root_user
check_exposed_ports
check_image_age
check_cves

echo ""
echo "======================================"
echo "   Audit Complete"
echo "======================================"
