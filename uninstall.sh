#!/bin/bash

# --- Configuration ---
INSTALL_DIR="/opt/burpsuite-pro"
BINARY_PATH="/usr/bin/burpsuitepro"
DESKTOP_ENTRY="/usr/share/applications/burpsuite.desktop"

echo "Starting Burp Suite Professional Uninstallation..."

# --- Phase 1: Remove Executables & Desktop Entries ---
echo "[*] Removing global binary and desktop entry..."

# Remove the wrapper script
if [[ -f "$BINARY_PATH" ]]; then
    sudo rm -v "$BINARY_PATH"
else
    echo "[?] Binary $BINARY_PATH not found."
fi

# Remove the .desktop file
if [[ -f "$DESKTOP_ENTRY" ]]; then
    sudo rm -v "$DESKTOP_ENTRY"
else
    echo "[?] Desktop entry $DESKTOP_ENTRY not found."
fi

# --- Phase 2: Remove Core Files ---
echo "[*] Removing installation directory: $INSTALL_DIR"
if [[ -d "$INSTALL_DIR" ]]; then
    sudo rm -rfv "$INSTALL_DIR"
else
    echo "[?] Installation directory $INSTALL_DIR not found."
fi

# --- Phase 3: Optional Cleanup (Java) ---
# Note: We usually DON'T uninstall Java automatically because
# other apps might depend on it.
echo "[!] Note: OpenJDK 22 has NOT been removed to avoid breaking other apps."
echo "[!] To remove it manually, use: sudo pacman -Rns jdk22-openjdk"

echo "[SUCCESS] Burp Suite Professional has been completely uninstalled."
