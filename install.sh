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
    sudo apt-get install -y curl code
    sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sudo sh <(curl -L https://nixos.org/nix/install) --daemon
    sudo curl -fsSL https://get.jetify.com/devbox | bash
    sudo echo 'eval "$(devbox global shellenv --init-hook)"' >> ~/.zshrc
    sudo echo 'eval "$(devbox global shellenv)"' >> ~/.zshrc
    sudo echo 'export PATH=$PATH:/Users/devbox/bin' >> ~/.zshrc
    sudo sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    p10k configure
}

# Function to install software on Linux (Debian)
install_on_linux_debian() {
    echo "Installing on Linux-Debian..."
    sudo apt-get update
    sudo apt-get install -y curl code
    sudo sh <(curl -L https://nixos.org/nix/install) --daemon
    sudo curl -fsSL https://get.jetify.com/devbox | bash
    sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sudo sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    sudo echo 'eval "$(devbox global shellenv --init-hook)"' >> ~/.zshrc
    sudo echo 'eval "$(devbox global shellenv)"' >> ~/.zshrc
    sudo echo 'export PATH=$PATH:/Users/devbox/bin' >> ~/.zshrc
    p10k configure
}

# Function to install software on MacOS
install_on_macos() {
    echo "Installing on MacOS..."
    
    brew update
    brew install curl iterm2
    brew install --cask visual-studio-code
    sudo sh <(curl -L https://nixos.org/nix/install)
    sudo curl -fsSL https://get.jetify.com/devbox | bash
    sudo echo 'eval "$(devbox global shellenv --init-hook)"' >> ~/.zshrc
    sudo echo 'export PATH=$PATH:/Users/devbox/bin' >> ~/.zshrc
    sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended --keep-zshrc
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sudo sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    p10k configure
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
