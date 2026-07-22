#!/usr/bin/env bash
# Script: check-connectivity.sh
# Purpose: Verify TCP port connectivity to a remote service using netcat.

set -u

readonly DEFAULT_PORT=50008
readonly TIMEOUT_SECONDS=3

usage() {
    echo "Usage: $0 <host_ip_or_fqdn> [port]"
    echo "Example: $0 dev-dpm-vm 50008"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if ! command -v nc >/dev/null 2>&1; then
    echo "ERROR: netcat (nc) is required but was not found in PATH."
    exit 127
fi

target_host="${1:-}"
target_port="${2:-$DEFAULT_PORT}"

if [[ -z "$target_host" ]]; then
    echo "ERROR: target host argument is required."
    usage
    exit 2
fi

echo "====================================================================="
echo "TCP Service Connectivity Check"
echo "Source: $(hostname)"
echo "Target: ${target_host}:${target_port}"
echo "====================================================================="

if nc -z -w "$TIMEOUT_SECONDS" "$target_host" "$target_port"; then
    echo "SUCCESS: ${target_host}:${target_port} is reachable."
    echo
    echo "Example SAP NetWeaver Java Engine workflow using nc:"
    echo "  (echo 'user'; sleep 1; echo 'pass'; sleep 1; echo 'deploy patch.sca') | nc ${target_host} ${target_port}"
    exit 0
fi

echo "FAILED: ${target_host}:${target_port} is unreachable or timed out."
echo "Check network routing, ACLs, firewall rules, and target service status."
exit 1
