#!/bin/bash

# Function to detect the operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version; then
            echo "WSL2"
        elif [ -f /etc/debian_version ]; then
            echo "Linux-Debian"
        else
            echo "Other-Linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "MacOS"
    else
        echo "Unsupported OS"
    fi
}

# Function to install software on Windows/WSL2
install_on_wsl2() {
    echo "Installing on WSL2..."
    
    sudo apt-get update
    sudo apt-get install -y curl
    sudo sh <(curl -L https://nixos.org/nix/install) --daemon
    sudo curl -fsSL https://get.jetify.com/devbox | bash
    sudo echo 'eval "$(devbox global shellenv --init-hook)"' >> ~/.bashrc
    sudo echo 'eval "$(devbox global shellenv)"' >> ~/.bashrc
    sudo echo 'export PATH=$PATH:/Users/devbox/bin' >> ~/.bashrc
    devbox global pull https://github.com/senad-d/devbox-global-conf.git
}

# Function to install software on Linux (Debian)
install_on_linux_debian() {
    echo "Installing on Linux-Debian..."
    
    sudo apt-get update
    sudo apt-get install -y curl
    sudo sh <(curl -L https://nixos.org/nix/install) --daemon
    sudo curl -fsSL https://get.jetify.com/devbox | bash
    sudo echo 'eval "$(devbox global shellenv --init-hook)"' >> ~/.bashrc
    sudo echo 'eval "$(devbox global shellenv)"' >> ~/.bashrc
    sudo echo 'export PATH=$PATH:/Users/devbox/bin' >> ~/.bashrc
    devbox global pull https://github.com/senad-d/devbox-global-conf.git
}

# Function to install software on MacOS
install_on_macos() {
    echo "Installing on MacOS..."
    
    curl -fsSL https://get.jetify.com/devbox | bash
    echo 'eval "$(devbox global shellenv --init-hook)"' >> ~/.zshrc
    echo 'eval "$(devbox global shellenv)"' >> ~/.zshrc
    echo 'export PATH=$PATH:/Users/devbox/bin' >> ~/.zshrc
    devbox global pull https://github.com/senad-d/devbox-global-conf.git
}

# Main script execution
os_type=$(detect_os)

case "$os_type" in
    "WSL2")
        install_on_wsl2
        ;;
    "Linux-Debian")
        install_on_linux_debian
        ;;
    "MacOS")
        install_on_macos
        ;;
    *)
        echo "Unsupported operating system detected. Exiting."
        exit 1
        ;;
esac

echo "Installation complete!"
