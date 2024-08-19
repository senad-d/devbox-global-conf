# devbox-global-conf

**devbox-global-conf** repository is for frash machine setup for devops.

## Table of contents

- [Structure](#structure)
- [Prerequisites](#prerequisites)
- [Usage](#usage)

## Structure

devbox-global-conf is a bash script organized into functions:

- `detect_os` - Function to detect the operating system
- `install_software` - Function to install software
- `log_message` - Function to log messages
- `handle_error` - Function to handle errors

## Prerequisites

- [Xcode](https://developer.apple.com/xcode/) - For new MacOS

## Usage

To install `Devbox` run:

```shell
git clone https://github.com/senad-d/devbox-global-conf.git

# Linux
bash install.sh

# MacOS
zsh install.sh
```

