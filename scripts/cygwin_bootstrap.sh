#!/usr/bin/env bash
#
# Cygwin bootstrap helper (idempotent, diagnostic-first)
#
# Purpose:
# - Provide a safe, idempotent diagnostic and lightweight bootstrap helper for
#   getting a Symfony/Twig + Node development environment usable from Cygwin.
# - This script DOES NOT try to fully install Windows packages for you.
#   Instead it:
#     * detects what's already available (PHP, Composer, Node, Docker, symfony CLI)
#     * attempts a safe Composer installer if PHP exists but Composer is missing
#     * installs symfony CLI into ~/.symfony (same installer used by Linux/macOS)
#     * offers to use Docker if Docker Desktop is available (recommended)
#     * gives clear next-step instructions when Cygwin is not a good fit
#
# Notes / caveats:
# - Cygwin is not the ideal environment for modern PHP/Node/Symfony stacks. WSL2
#   or Docker Desktop with WSL2 integration is strongly recommended.
# - Do NOT run this as an automated replacement for system installs. Read prompts.
#
# Usage (from a Cygwin shell):
#   bash scripts/cygwin_bootstrap.sh
#
set -euo pipefail

# helpers
info() { printf "\e[34m[INFO]\e[0m %s\n" "$*"; }
warn() { printf "\e[33m[WARN]\e[0m %s\n" "$*"; }
err()  { printf "\e[31m[ERROR]\e[0m %s\n" "$*"; }

# Detect environment
UNAME_S="$(uname -s 2>/dev/null || echo unknown)"
if ! echo "$UNAME_S" | grep -qi cygwin; then
  warn "This script is targeted at Cygwin environments, but uname reports: $UNAME_S"
  warn "You can continue, but results may be unpredictable. If possible prefer WSL2 or Docker."
fi

# Basic diagnostics
info "Gathering environment diagnostics..."
echo "---- System ----"
uname -a || true
echo "---- Windows PATH (as seen by cmd) ----"
cmd.exe /c "echo %PATH%" 2>/dev/null || echo "(cmd.exe not available)"

# Check for tools
check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    printf "%-12s: %s\n" "$1" "$($1 --version 2>/dev/null | sed -n '1p' || true)"
    return 0
  else
    printf "%-12s: %s\n" "$1" "not found"
    return 1
  fi
}

info "Checking for common developer tools (php, composer, symfony, node, npm, docker)..."
check_cmd php || true
if command -v php >/dev/null 2>&1; then
  php -v | sed -n '1,2p'
fi
check_cmd composer || true
check_cmd symfony || true
check_cmd node || true
check_cmd npm || true
check_cmd docker || true
check_cmd docker-compose || true

echo
info "Summary diagnostics complete."

# If Docker is present - recommend using the Docker-based prototype
if command -v docker >/dev/null 2>&1; then
  info "Docker is available. Using Docker Desktop (recommended) will avoid many Cygwin issues."
  read -r -p "Would you like to (1) attempt Docker-based dev run now, (2) continue with Cygwin-local bootstrap, or (3) only show next steps? [1/2/3] " ACTION
  ACTION="${ACTION:-3}"
  if [ "$ACTION" = "1" ]; then
    if [ ! -f docker-compose.yml ]; then
      warn "No docker-compose.yml found in current directory. Please cd to the repo root where docker-compose.yml exists."
      info "I won't run Docker automatically. Instead, run: docker-compose up --build"
    else
      info "Running: docker-compose up --build"
      # Invoke docker-compose directly; let the user stop it with Ctrl+C
      docker-compose up --build
      exit 0
    fi
  elif [ "$ACTION" = "2" ]; then
    info "Proceeding with Cygwin-local checks/installs."
  else
    info "Skipping automated actions. See the printed recommendations below for next steps."
  fi
else
  warn "Docker not found. If you can install Docker Desktop (with WSL2 integration) it's recommended."
fi

echo
# Composer installation (safe attempt) if php present and composer missing
if command -v php >/dev/null 2>&1 && ! command -v composer >/dev/null 2>&1; then
  info "PHP is present but Composer is missing. Attempting a safe, local Composer install."

  # Choose a user-local composer path to avoid requiring admin rights
  COMPOSER_LOCAL_BIN="${HOME}/.local/bin"
  COMPOSER_LOCAL_BIN_WIN="$(cygpath -w "$COMPOSER_LOCAL_BIN" 2>/dev/null || true)"
  mkdir -p "$COMPOSER_LOCAL_BIN"

  if [ -w "$COMPOSER_LOCAL_BIN" ] || [ ! -e "$COMPOSER_LOCAL_BIN" ]; then
    info "Downloading composer.phar to ~/.local/bin/composer.phar ..."
    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php || { err "Failed to download composer installer"; }
    php /tmp/composer-setup.php --install-dir="$COMPOSER_LOCAL_BIN" --filename=composer.phar >/dev/null 2>&1 || { err "composer installer failed"; }
    rm -f /tmp/composer-setup.php

    # Create a tiny wrapper script to run composer with php
    cat > "${COMPOSER_LOCAL_BIN}/composer" <<'BASH'
#!/usr/bin/env bash
php "$(dirname "$0")/composer.phar" "$@"
BASH
    chmod +x "${COMPOSER_LOCAL_BIN}/composer"
    info "Composer installed to ${COMPOSER_LOCAL_BIN}/composer"
    if ! echo "$PATH" | grep -q "$COMPOSER_LOCAL_BIN"; then
      warn "Add ${COMPOSER_LOCAL_BIN} to your PATH in ~/.bashrc or ~/.profile, e.g.:"
      echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
  else
    warn "Cannot write to ${COMPOSER_LOCAL_BIN}. You may need to run this script with appropriate permissions or install Composer on Windows and add it to PATH."
  fi
else
  if ! command -v php >/dev/null 2>&1; then
    warn "PHP not found. To run PHP tools you can either:"
    echo "  * Install Windows-native PHP and add to PATH (https://windows.php.net/), or"
    echo "  * Use Docker Desktop / WSL2 (recommended)."
  else
    info "Composer already installed."
  fi
fi

echo
# Symfony CLI: try to install to ~/.symfony (same installer used on Linux)
if ! command -v symfony >/dev/null 2>&1; then
  info "symfony CLI not found. Attempting user-local installer into ~/.symfony/bin (this usually works on Cygwin)."
  SYMFONY_BIN_DIR="${HOME}/.symfony/bin"
  mkdir -p "${HOME}/.symfony"
  # The official installer is a POSIX shell script that places a binary in ~/.symfony/bin
  if curl -fsS https://get.symfony.com/cli/installer -o /tmp/symfony-installer.sh; then
    bash /tmp/symfony-installer.sh || warn "symfony installer returned non-zero; you may still have a usable binary in ${SYMFONY_BIN_DIR}"
    rm -f /tmp/symfony-installer.sh
    if [ -f "${SYMFONY_BIN_DIR}/symfony" ]; then
      ln -sf "${SYMFONY_BIN_DIR}/symfony" "${HOME}/.local/bin/symfony" 2>/dev/null || true
      info "symfony CLI installed to ${SYMFONY_BIN_DIR}/symfony"
      if ! echo "$PATH" | grep -q "${HOME}/.local/bin"; then
        warn "Consider adding ${HOME}/.local/bin to your PATH (e.g. in ~/.bashrc)."
      fi
    else
      warn "symfony CLI installer did not produce the binary in ${SYMFONY_BIN_DIR}. You can download the Windows binary or use WSL2/Docker."
    fi
  else
    warn "Unable to download symfony installer. Install symfony CLI on Windows and ensure it is in your PATH."
  fi
else
  info "symfony CLI already installed: $(symfony -v 2>/dev/null | sed -n '1p' || true)"
fi

echo
# Node & yarn
if command -v node >/dev/null 2>&1; then
  info "Node is installed: $(node -v)"
  if ! command -v yarn >/dev/null 2>&1; then
    if command -v npm >/dev/null 2>&1; then
      info "Installing yarn globally via npm (may use Windows permissions)..."
      npm install --global yarn || warn "npm global install may have failed. Consider installing Yarn using the Windows installer or via npm as administrator."
      if command -v yarn >/dev/null 2>&1; then
        info "yarn installed: $(yarn -v)"
      fi
    else
      warn "npm not found; cannot install yarn. Consider installing Node.js with npm on Windows and ensure Cygwin can call it."
    fi
  else
    info "yarn already present: $(yarn -v)"
  fi
else
  warn "Node not found. Install Node.js on Windows and ensure it's on PATH if you intend to run frontend tooling from Cygwin."
fi

echo
# Docker compose note
if command -v docker >/dev/null 2>&1 && ! command -v docker-compose >/dev/null 2>&1; then
  warn "docker-compose not found. Newer Docker uses 'docker compose' (no hyphen). Try: docker compose up --build"
fi

echo
# Final summary and next steps
cat <<SUMMARY

Bootstrap summary & recommended next steps:

  * If Docker Desktop is available: prefer using the Docker-based dev flow (docker-compose up --build).
    - This avoids many Cygwin path/permission issues and closely mirrors production.

  * If you want a native (Windows) install path, consider installing:
    - PHP for Windows: https://windows.php.net/
    - Composer for Windows: https://getcomposer.org/download/
    - Symfony CLI for Windows: https://symfony.com/download
    - Node.js LTS (includes npm): https://nodejs.org/
    - Then ensure the installed binaries are available in your Windows PATH and visible to Cygwin.

  * If you prefer WSL2: it's the recommended route. See Microsoft docs:
    - https://docs.microsoft.com/windows/wsl/install

  * Files/commands created by this script (if any, user-local):
    - Composer (if installed): ~/.local/bin/composer (wrapper around composer.phar)
    - symfony (if installed): ~/.symfony/bin/symfony (installer default)
    - Please add ~/.local/bin and ~/.symfony/bin to your PATH in ~/.bashrc if needed.

Helpful quick commands:
  * To add ~/.local/bin to PATH (add to ~/.bashrc):
      echo 'export PATH="$HOME/.local/bin:$HOME/.symfony/bin:$PATH"' >> ~/.bashrc
      source ~/.bashrc

  * To run the Docker-based Twig prototype (if docker-compose.yml exists):
      docker-compose up --build

  * To create a minimal Symfony project (after Composer & symfony CLI installed):
      composer create-project symfony/skeleton xlmfish-site
      cd xlmfish-site
      composer require webapp
      symfony server:start

Security reminders:
  - Do NOT commit private keys or secrets into git.
  - For production signing use hardware wallets / KMS, not local dev machines.

SUMMARY

info "Cygwin bootstrap script finished. If you'd like, I can:"
echo "  - (A) Generate a devcontainer.json for use with VS Code Remote Containers"
echo "  - (B) Produce a minimal Symfony scaffold (controller + Twig templates) to paste into your project"
echo "  - (C) Create a Docker dev-compose workflow you can run from Cygwin/Docker"
read -r -p "Reply with A, B, C, or press Enter to finish: " CHOICE || true

if [ "${CHOICE:-}" = "A" ]; then
  info "You chose A. Ask me and I'll produce a devcontainer.json in the repo."
elif [ "${CHOICE:-}" = "B" ]; then
  info "You chose B. Ask me and I'll produce Symfony scaffold files you can paste into your repo."
elif [ "${CHOICE:-}" = "C" ]; then
  info "You chose C. Ask me and I'll produce a Docker dev-compose workflow for the repo."
else
  info "No follow-up requested. Exiting."
fi

exit 0