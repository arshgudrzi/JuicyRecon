JuicyRecon
Overview

JuicyRecon is a simple, automated tool designed for pentesters and security enthusiasts. It recursively downloads a website using wget, then scans the downloaded content for sensitive keywords (like API keys, passwords, tokens, etc.). It also integrates with SubReconX by processing its subdomain output to check additional targets for "juicy" information.
Features

  Recursive Download: Automatically downloads the target website and its pages using wget.
  Keyword Search: Scans the downloaded files for critical sensitive keywords (e.g., apikey, secret, password, etc.).
  Subdomain Integration: Optionally processes a list of subdomains (from SubReconX) and downloads them concurrently.
  Automated Logging: Stores all sensitive keyword findings in a single log file for easy review.
  Concurrent Processing: Uses parallel downloads with a limit to efficiently process multiple subdomains.

Requirements

Ensure you have the following tools installed:

    wget
    grep
    xargs

You can install these on Debian/Ubuntu systems with:

    sudo apt install wget grep xargs -y

Usage

  Make the script executable:

    chmod +x web_scraper_enum.sh

Run the script:

    ./web_scraper_enum.sh

  Follow the prompts:
      Enter the target URL (e.g., https://example.com).
      Enter an output folder name (or press Enter to use the default).
      Optionally, provide a file containing subdomains from SubReconX.

The script will then:

  Download the website recursively.
  Search for sensitive keywords in the downloaded content.
  If provided, download subdomains concurrently and include their content in the keyword search.

All results are stored in the output directory, with sensitive keyword findings saved in a file named sensitive_info.txt.
Example Output

[+] Downloading website: https://example.com
[+] Website downloaded to example_com_download
[+] Searching for sensitive keywords...
[+] Processing subdomains from subdomains.txt
[+] Downloading subdomain: sub.example.com
[+] Subdomain scraping completed.
[+] All tasks completed. Check 'example_com_download' for content and 'sensitive_info.txt' for keyword results.

Disclaimer

This tool is intended for ethical security research and penetration testing purposes only. Do not use JuicyRecon against systems you do not own or have explicit permission to test. The author is not responsible for any misuse of this tool.
