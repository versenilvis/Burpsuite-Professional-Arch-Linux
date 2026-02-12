#!/bin/bash

INSTALL_DIR="/opt/burpsuite-pro"
VERSION="2026"
JAR_FILE="burpsuite_pro_v$VERSION.jar"

echo "Starting Burp Suite Professional Installation & Cleanup..."

# Check if existing binaries exist and remove them to avoid conflicts
for cmd in burpsuite burpsuite-pro burpsuitepro; do
    if command -v $cmd &>/dev/null; then
        echo "[*] Found existing $cmd. Removing for clean installation..."
        sudo rm -f $(which $cmd)
    fi
done

# check if yay exists
if ! command -v yay &>/dev/null; then
    echo "[*] yay not found. Installing base-devel and yay..."
    sudo pacman -S --needed base-devel git wget --noconfirm
    git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm
fi

# Check if OpenJDK 22 is already set as default
if java -version 2>&1 | grep -q "22\."; then
    echo "[+] Java 22 is already installed and set as default."
else
    echo "[*] Java 22 not detected or not default. Installing/Setting up..."
    yay -S jdk22-openjdk --noconfirm
    sudo archlinux-java set java-22-openjdk
fi

# Verify if the JAR file already exists in the current repo to skip download
echo "[*] Checking for local resources..."
if [[ -f "$JAR_FILE" ]]; then
    echo "[+] $JAR_FILE found in current directory. Skipping download."
else
    echo "[*] $JAR_FILE not found. Downloading from source..."
    wget -O $JAR_FILE https://github.com/xiv3r/Burpsuite-Professional/releases/download/burpsuite-pro/$JAR_FILE
fi

# Final check for essential files before moving to /opt
if [[ ! -f "loader.jar" || ! -f "burp_suite.ico" || ! -f "burpsuite_pro.ico" ]]; then
    echo "[-] Error: loader.jar or burp_suite.ico or burpsuite_pro.ico missing in current directory."
    exit 1
fi

sudo mkdir -p $INSTALL_DIR
sudo cp $JAR_FILE loader.jar burpsuite_pro.ico $INSTALL_DIR/

# Create a global binary in /usr/bin for easy access from terminal
echo "[*] Creating global executable wrapper: /usr/bin/burpsuitepro"
sudo bash -c "cat > /usr/bin/burpsuitepro <<EOF
#!/bin/bash
java --add-opens=java.desktop/javax.swing=ALL-UNNAMED \
--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED \
-javaagent:$INSTALL_DIR/loader.jar -noverify -jar $INSTALL_DIR/$JAR_FILE &
EOF"

sudo chmod +x /usr/bin/burpsuitepro

# create desktop app
echo "[*] Creating Desktop Entry..."
sudo bash -c "cat > /usr/share/applications/burpsuite.desktop <<EOF
[Desktop Entry]
Name=Burp Suite Pro
Comment=Web Application Security Testing
Exec=/usr/bin/burpsuitepro
Icon=$INSTALL_DIR/burpsuite_pro.ico
StartupWMClass=burp-StartBurp
Terminal=false
Type=Application
Categories=Development;Security;
Keywords=pentest;security;network;
EOF"

# Start the Keygen/Loader in the background to assist activation
echo "[*] Launching Key Loader for activation..."
(java -jar $INSTALL_DIR/loader.jar) &

echo "[SUCCESS] Burp Suite Pro $VERSION is ready!"
/usr/bin/burpsuitepro
