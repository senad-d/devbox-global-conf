#!/bin/bash

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
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
    iterm2
    visual-studio-code
    grammarly-desktop
    shottr
    alt-tab
    openvpn-connect
    raycast
    licecap
    xquartz
    slack
    zoom
    firefox
)

log "Updating Homebrew..."
brew update

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
