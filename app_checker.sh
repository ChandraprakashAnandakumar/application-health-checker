#!/bin/sh

# ==================== CONFIGURATION ====================
# URLs to monitor - includes your real site and test scenarios
URLS="
https://www.dev-cv.in
https://www.dev-cv.in/non-existing-page-test
https://httpbin.org/status/200
https://httpbin.org/status/500
https://invalid-broken-domain-test.com
"

TIMEOUT=5                  # Max wait time in seconds
INTERVAL=5                 # Check interval in seconds
LOG_FILE="/var/log/app_health.log"

# ANSI Colors
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_GREEN="\033[92m"
C_RED="\033[91m"
C_CYAN="\033[96m"

log_event() {
    local status="$1"
    local url="$2"
    local code="$3"
    local latency="$4"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$status] URL: $url | Code: $code | Latency: ${latency}s" >> "$LOG_FILE"
}

trap 'echo -e "\nApplication Health Checker stopped."; exit 0' SIGINT SIGTERM

while true; do
    clear
    echo "========================================================================================"
    echo "                   APPLICATION HEALTH CHECKER (UPTIME MONITOR)                          "
    echo "                   Timestamp: $(date '+%Y-%m-%d %H:%M:%S') | Timeout: ${TIMEOUT}s                "
    echo "========================================================================================"
    printf "%-46s | %-8s | %-6s | %-12s\n" "APPLICATION URL" "STATUS" "CODE" "RESPONSE TIME"
    echo "-----------------------------------------------+----------+--------+--------------"

    for url in $URLS; do
        # -s: silent
        # -L: follow redirects (crucial for live production websites)
        # -o /dev/null: discard response body
        # -w: extract HTTP status code and total elapsed time
        # -m: timeout limit
        response=$(curl -s -L -o /dev/null -w "%{http_code} %{time_total}" -m "$TIMEOUT" "$url" 2>/dev/null)

        http_code=$(echo "$response" | awk '{print $1}')
        time_total=$(echo "$response" | awk '{print $2}')

        # Case 1: Connection failure / DNS error / Timeout
        if [ -z "$http_code" ] || [ "$http_code" = "000" ]; then
            http_code="N/A"
            time_total="${TIMEOUT}.00"
            status_text="DOWN"
            status_color="${C_RED}${C_BOLD}${status_text}${C_RESET}"
            log_event "DOWN" "$url" "$http_code (Connection Failed)" "$time_total"

        # Case 2: HTTP 200 - 399 (Application is Healthy / UP)
        elif [ "$http_code" -ge 200 ] && [ "$http_code" -lt 400 ]; then
            status_text="UP"
            status_color="${C_GREEN}${C_BOLD}${status_text}${C_RESET}  "
            log_event "UP" "$url" "$http_code" "$time_total"

        # Case 3: HTTP 4xx, 5xx (Application is Down / Returning Errors)
        else
            status_text="DOWN"
            status_color="${C_RED}${C_BOLD}${status_text}${C_RESET}"
            log_event "DOWN" "$url" "$http_code" "$time_total"
        fi

        # Output row using standard printf compatible with Alpine BusyBox sh
        printf "%-46s | " "$url"
        echo -en "${status_color}     | "
        printf "%-6s | %-10ss\n" "$http_code" "$time_total"
    done

    echo "========================================================================================"
    echo "Logs saved to: $LOG_FILE"
    echo "Next refresh in ${INTERVAL}s. Press [Ctrl+C] to exit."
    sleep "$INTERVAL"
done