#!/bin/bash

# Log file location
LOG_FILE="devbox_install.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %T") - $1" | tee -a "$LOG_FILE"
}

# Function to handle errors
handle_error() {
    log_message "Error occurred. Exiting."
    exit 1
}

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

# Function to install software
install_software() {
    local os_type=$1
    
    log_message "Starting installation on $os_type..."

    # Update package list if necessary
    if [[ "$os_type" == "WSL2" || "$os_type" == "Linux-Debian" ]]; then
        sudo apt-get update || handle_error
        sudo apt-get install -y curl || handle_error
    fi

    # Install Devbox
    curl -fsSL https://get.jetify.com/devbox | bash || handle_error
    log_message "Devbox installed successfully."

    # Update shell environment
    local shell_config
    if [[ "$os_type" == "MacOS" ]]; then
        shell_config="$HOME/.zshrc"
    else
        shell_config="$HOME/.bashrc"
    fi

    echo 'eval "$(devbox global shellenv --init-hook)"' >> "$shell_config"
    echo 'export PATH=$PATH:/Users/devbox/bin' >> "$shell_config"
    log_message "Shell environment updated for $os_type."
    
    # Pull global Devbox configuration
    devbox global pull https://github.com/senad-d/devbox-global-conf.git || handle_error
    log_message "Global Devbox configuration pulled successfully."

    eval "$(devbox global shellenv)"

    # Install additional software using Nix
    log_message "Installing additional software using Nix..."

    if [[ "$os_type" == "MacOS" ]]; then
        nix-env -iA nixpkgs.xquartz \
                    nixpkgs.iterm2 \
                    nixpkgs.oh-my-zsh \
                    nixpkgs.zsh-powerlevel10k \
                    nixpkgs.zsh-autocomplete \
                    nixpkgs.zsh-autosuggestions \
                    nixpkgs.zsh-syntax-highlighting \
                    nixpkgs.zsh-fzf-history-search \
                    nixpkgs.git \
                    nixpkgs.alt-tab-macos || handle_error
        echo 'source ~/.nix-profile/share/oh-my-zsh/oh-my-zsh.sh' >> "$shell_config"
        echo 'source ~/.nix-profile/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh' >> "$shell_config"
        echo 'source ~/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> "$shell_config"
        echo 'source ~/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> "$shell_config"
        echo 'source ~/.nix-profile/share/zsh-fzf-history-search/zsh-fzf-history-search.zsh' >> "$shell_config"
        # Download and install Docker Desktop
        DOCKER_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
        DOCKER_DMG="$HOME/Downloads/Docker.dmg"
        
        log_message "Downloading Docker Desktop..."
        if [ ! -f "$DOCKER_DMG" ]; then
            curl -L "$DOCKER_URL" -o "$DOCKER_DMG"
        else
            log "Docker DMG already exists. Skipping download."
        fi
        
        log_message "Mounting Docker DMG..."
        hdiutil attach "$DOCKER_DMG" -nobrowse -quiet
        
        log_message "Copying Docker.app to Applications..."
        cp -r /Volumes/Docker/Docker.app /Applications/
        
        log_message "Unmounting Docker DMG..."
        hdiutil detach /Volumes/Docker -quiet
        
        log_message "Cleaning up Docker DMG..."
        rm "$DOCKER_DMG"
        
        log_message "Docker Desktop installation complete."    
    elif [[ "$os_type" == "WSL2" || "$os_type" == "Linux-Debian" ]]; then
        nix-env -iA nixpkgs.git \
                    nixpkgs.vscode \
                    nixpkgs.openvpn \
                    nixpkgs.slack \
                    nixpkgs.firefox || handle_error
    fi

    log_message "Additional software installed successfully."

    source "$shell_config"
}

# Main script execution
os_type=$(detect_os)

case "$os_type" in
    "WSL2" | "Linux-Debian" | "MacOS")
        install_software "$os_type"
        ;;
    *)
        log_message "Unsupported operating system detected. Exiting."
        exit 1
        ;;
esac

log_message "Installation complete!"

