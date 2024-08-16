#!/bin/bash

# Log file location
LOG_FILE="apps_install.log"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to handle errors
handle_error() {
    log "Error occurred. Exiting."
    exit 1
}

# Ensure script stops on error
set -e
trap 'handle_error' ERR

log "Starting software installation..."

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    log "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log "Homebrew installation complete."
else
    log "Homebrew is already installed."
fi

log "Updating Homebrew..."
brew update

# Download and install Docker Desktop
DOCKER_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
DOCKER_DMG="$HOME/Downloads/Docker.dmg"

log "Downloading Docker Desktop..."
if [ ! -f "$DOCKER_DMG" ]; then
    curl -L "$DOCKER_URL" -o "$DOCKER_DMG"
else
    log "Docker DMG already exists. Skipping download."
fi

log "Mounting Docker DMG..."
hdiutil attach "$DOCKER_DMG" -nobrowse -quiet

log "Copying Docker.app to Applications..."
cp -r /Volumes/Docker/Docker.app /Applications/

log "Unmounting Docker DMG..."
hdiutil detach /Volumes/Docker -quiet

log "Cleaning up Docker DMG..."
rm "$DOCKER_DMG"

log "Docker Desktop installation complete."

# Install Homebrew packages
BREW_PACKAGES=(
    zsh-autocomplete
    zsh-autosuggestions
    docker-compose
)

BREW_CASKS=(
    xquartz
    zoom
    openvpn-connect
    iterm2
    visual-studio-code
    grammarly-desktop
    shottr
    alt-tab
    raycast
    licecap
    slack
    firefox
)

log "Installing Brew packages..."
for package in "${BREW_PACKAGES[@]}"; do
    if brew list "$package" &>/dev/null; then
        log "$package is already installed. Skipping."
    else
        brew install "$package"
    fi
done

log "Installing Brew cask applications..."
for cask in "${BREW_CASKS[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        log "$cask is already installed. Skipping."
    else
        brew install --cask "$cask"
    fi
done

log "Software installation complete."
