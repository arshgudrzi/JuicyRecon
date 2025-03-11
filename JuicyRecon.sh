#!/bin/bash
# Web Scraper & Sensitive Info Finder
# Recursively downloads a website and its subdomains (if provided),
# then searches for key sensitive keywords.
#
# Dependencies: wget, grep, xargs

set -euo pipefail

# --- Configuration ---
# Define juicy keywords to search for
KEYWORDS=("apikey" "api_key" "secret" "password" "admin" "token" "access_key" "client_secret" "database" "ftp" "ssh" "jwt")
# Maximum number of concurrent downloads for subdomains
MAX_JOBS=5

# --- Helper Functions ---
log() {
    echo -e "[\033[1;32m+\033[0m] $1"
}

error() {
    echo -e "[\033[1;31m-\033[0m] $1" >&2
}

# Check if required tools exist
for tool in wget grep xargs; do
    if ! command -v "$tool" &>/dev/null; then
        error "'$tool' is required but not installed. Exiting."
        exit 1
    fi
done

# --- Input Prompts ---
read -rp "Enter the target URL (e.g., https://example.com): " TARGET_URL
if [[ -z "$TARGET_URL" ]]; then
    error "No target URL provided. Exiting."
    exit 1
fi

# Auto-generate an output folder name based on the domain (strip protocol and non-alphanum)
domain_clean=$(echo "$TARGET_URL" | sed -E 's~https?://~~; s/[^a-zA-Z0-9.-]//g')
DEFAULT_OUTPUT_DIR="${domain_clean}_download"
read -rp "Enter output folder name (default: $DEFAULT_OUTPUT_DIR): " OUTPUT_DIR
OUTPUT_DIR=${OUTPUT_DIR:-$DEFAULT_OUTPUT_DIR}

read -rp "Enter subdomains file from SubReconX (leave empty to skip): " SUBDOMAINS_FILE

# Create output directories
mkdir -p "$OUTPUT_DIR"
SUBDOMAIN_DIR="$OUTPUT_DIR/subdomains"
mkdir -p "$SUBDOMAIN_DIR"

# --- Main Processing ---

# 1. Recursively download the main website
log "Downloading website: $TARGET_URL"
wget -r -P "$OUTPUT_DIR" "$TARGET_URL" \
    --no-check-certificate --adjust-extension --convert-links --quiet

log "Website downloaded to $OUTPUT_DIR"

# 2. Search for sensitive keywords in the main website download
SEARCH_RESULTS="$OUTPUT_DIR/sensitive_info.txt"
log "Searching for sensitive keywords..."
> "$SEARCH_RESULTS"  # clear previous results if any
for keyword in "${KEYWORDS[@]}"; do
    # Append findings with keyword header
    echo "---- Results for \"$keyword\" ----" >> "$SEARCH_RESULTS"
    grep -Ri --color=always "$keyword" "$OUTPUT_DIR" >> "$SEARCH_RESULTS" || true
done
log "Keyword search completed. Results logged in $SEARCH_RESULTS"

# 3. If subdomains file provided, download each subdomain concurrently
if [[ -n "$SUBDOMAINS_FILE" && -f "$SUBDOMAINS_FILE" ]]; then
    log "Processing subdomains from $SUBDOMAINS_FILE"
    JOBS=0
    while IFS= read -r subdomain; do
        subdomain=$(echo "$subdomain" | xargs) # trim
        [[ -z "$subdomain" ]] && continue
        (
            log "Downloading subdomain: $subdomain"
            wget -r -P "$SUBDOMAIN_DIR" "$subdomain" \
                --no-check-certificate --adjust-extension --convert-links --quiet
            # Search for keywords in this subdomain's files and append to the same log
            for keyword in "${KEYWORDS[@]}"; do
                echo "---- [$subdomain] Results for \"$keyword\" ----" >> "$SEARCH_RESULTS"
                grep -Ri "$keyword" "$SUBDOMAIN_DIR" >> "$SEARCH_RESULTS" || true
            done
        ) &
        ((JOBS++))
        # Control maximum number of background jobs
        if (( JOBS % MAX_JOBS == 0 )); then
            wait
        fi
    done < "$SUBDOMAINS_FILE"
    wait
    log "Subdomain scraping completed."
else
    log "No subdomains file provided or file not found; skipping subdomain downloads."
fi

log "All tasks completed. Check '$OUTPUT_DIR' for downloaded content and '$SEARCH_RESULTS' for keyword results."
