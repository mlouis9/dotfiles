#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Starting Neovim and dotfiles setup..."

# --- Configuration ---
NVIM_VERSION="v0.9.5" # Use the AppImage version that worked
NVIM_APPIMAGE_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage"
NVIM_APPIMAGE_PATH="$HOME/nvim.appimage"
LOCAL_BIN_PATH="$HOME/.local/bin"
NVIM_SYMLINK_PATH="$LOCAL_BIN_PATH/nvim"
DOTFILES_DIR="$HOME/dotfiles" # Assumes repo is cloned here

# --- Helper Functions ---
ensure_dir_exists() {
  if [ ! -d "$1" ]; then
    echo "Creating directory: $1"
    mkdir -p "$1"
  fi
}

add_to_path_if_needed() {
  local dir_to_add=$1
  local profile_file=$2
  if [[ ":$PATH:" != *":$dir_to_add:"* ]]; then
    echo "Adding $dir_to_add to PATH in $profile_file"
    echo '' >> "$profile_file" # Add a newline for safety
    echo "# Added by dotfiles bootstrap script" >> "$profile_file"
    echo "export PATH=\"$dir_to_add:\$PATH\"" >> "$profile_file"
    # Export for the current session too
    export PATH="$dir_to_add:$PATH"
    echo "Please run 'source $profile_file' or restart your shell to apply PATH changes permanently."
  else
    echo "$dir_to_add is already in PATH."
  fi
}

# Detect shell profile file (.bashrc or .zshrc)
if [ -n "$BASH_VERSION" ]; then
    PROFILE_FILE="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    PROFILE_FILE="$HOME/.zshrc"
else
    PROFILE_FILE="$HOME/.profile" # Fallback
    echo "Warning: Could not detect Bash or Zsh, using $PROFILE_FILE. You may need to adjust manually."
fi


# --- 1. Install Neovim AppImage ---
echo "Checking Neovim installation..."
if command -v nvim &> /dev/null && [ "$(readlink -f $(which nvim))" == "$NVIM_SYMLINK_PATH" ] && nvim --version | grep -q "${NVIM_VERSION}"; then
  echo "Neovim ${NVIM_VERSION} AppImage already installed correctly."
else
  echo "Installing Neovim ${NVIM_VERSION} AppImage..."
  # Download
  if [ ! -f "$NVIM_APPIMAGE_PATH" ]; then
     echo "Downloading Neovim AppImage from $NVIM_APPIMAGE_URL..."
     if command -v curl &> /dev/null; then
       curl -L "$NVIM_APPIMAGE_URL" -o "$NVIM_APPIMAGE_PATH"
     elif command -v wget &> /dev/null; then
       wget "$NVIM_APPIMAGE_URL" -O "$NVIM_APPIMAGE_PATH"
     else
       echo "Error: curl or wget not found. Cannot download Neovim."
       exit 1
     fi
  else
     echo "Neovim AppImage already downloaded."
  fi

  # Make executable
  echo "Making AppImage executable..."
  chmod u+x "$NVIM_APPIMAGE_PATH"

  # Ensure ~/.local/bin exists
  ensure_dir_exists "$LOCAL_BIN_PATH"

  # Create symlink
  echo "Creating symlink at $NVIM_SYMLINK_PATH..."
  # Remove old link if it exists and points elsewhere or is broken
  if [ -L "$NVIM_SYMLINK_PATH" ] || [ -e "$NVIM_SYMLINK_PATH" ]; then
     rm -f "$NVIM_SYMLINK_PATH"
  fi
  ln -s "$NVIM_APPIMAGE_PATH" "$NVIM_SYMLINK_PATH"

  echo "Neovim installation/update complete."
fi

# --- 2. Ensure ~/.local/bin is in PATH ---
echo "Checking PATH..."
add_to_path_if_needed "$LOCAL_BIN_PATH" "$PROFILE_FILE"

# --- 3. Install Stow (Attempt if missing) ---
echo "Checking Stow installation..."
if ! command -v stow &> /dev/null; then
  echo "Stow not found. Attempting to install via Conda (if available)..."
  if command -v conda &> /dev/null; then
    conda install -y -c conda-forge stow || echo "Conda install failed. Please install Stow manually (e.g., build from source)."
  else
    echo "Conda not found. Please install Stow manually."
    echo "Build instructions: Download from https://www.gnu.org/software/stow/, extract, then run:"
    echo "./configure --prefix=\$HOME/.local && make && make install"
    echo "Then ensure $HOME/.local/bin is in your PATH."
    # Optionally exit here if stow is critical
    # exit 1
  fi
else
  echo "Stow is already installed."
fi


# --- 4. Stow Dotfiles ---
echo "Stowing Neovim configuration..."
if ! command -v stow &> /dev/null; then
   echo "Stow command not found after install attempt. Cannot stow dotfiles. Please install stow manually and re-run stow command."
   exit 1
fi

if [ -d "$DOTFILES_DIR/nvim" ]; then
  cd "$DOTFILES_DIR"
  # Remove existing symlink/directory first if it's already there but not a stow link
  if [ -e "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
     echo "Backing up existing non-stow Neovim config to ~/.config/nvim.backup..."
     mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup"
  fi
  stow nvim
  echo "Neovim configuration stowed."
else
  echo "Warning: nvim package directory not found in $DOTFILES_DIR. Skipping stow."
fi

# --- 5. Install Node.js via nvm (if nvm is installed) ---
echo "Checking Node.js/nvm installation..."
if [ -s "$HOME/.nvm/nvm.sh" ]; then
   echo "nvm found. Sourcing nvm and installing/checking Node.js v22..."
   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Source nvm

   # Install Node v22 if not already installed
   if ! nvm version 22 &> /dev/null; then
     nvm install 22
   fi
   nvm alias default 22
   nvm use default
   echo "Node.js version set to $(node --version)"
else
   echo "nvm not found. Skipping Node.js setup via nvm."
   echo "Please install nvm manually if needed for plugins:"
   echo 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash'
fi


echo "✅ Setup script finished!"
echo "You may need to run 'source $PROFILE_FILE' or restart your shell."
echo "Launch Neovim ('nvim') to finish plugin installation."
