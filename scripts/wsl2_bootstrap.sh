#!/usr/bin/env bash
# Bootstrap for WSL2 Ubuntu: installs PHP, Composer, Symfony CLI, Node, and common tools.
# Usage: paste into WSL2 shell and run: sudo bash ./scripts/wsl2_bootstrap.sh
set -euo pipefail

# Basic checks
echo "Bootstrap starting on: $(lsb_release -d -s || echo 'unknown distro')"
echo "Ensure you're running this in WSL2 (not legacy Cygwin)."

# Make sure apt is updated
sudo apt-get update -y
sudo apt-get upgrade -y

# Install base utils
sudo apt-get install -y ca-certificates apt-transport-https lsb-release gnupg curl git unzip build-essential wget

# Add Ondrej PPA for recent PHP versions (safe on Ubuntu LTS)
if ! grep -q "ondrej" /etc/apt/sources.list.d/* 2>/dev/null || true; then
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository -y ppa:ondrej/php
fi

sudo apt-get update -y

# Install PHP and common extensions (adjust PHP version here if needed)
PHP_VERSION="8.2"
sudo apt-get install -y php${PHP_VERSION}-cli php${PHP_VERSION}-fpm php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring php${PHP_VERSION}-curl php${PHP_VERSION}-zip php${PHP_VERSION}-intl php${PHP_VERSION}-gd

# Ensure composer installed
if ! command -v composer >/dev/null 2>&1; then
  echo "Installing Composer..."
  curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
  php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
  rm /tmp/composer-setup.php
else
  echo "Composer already installed: $(composer --version)"
fi

# Symfony CLI
if ! command -v symfony >/dev/null 2>&1; then
  echo "Installing Symfony CLI..."
  wget https://get.symfony.com/cli/installer -O - | bash
  sudo mv /home/$USER/.symfony/bin/symfony /usr/local/bin/symfony || true
else
  echo "Symfony CLI already installed: $(symfony -v)"
fi

# NodeJS (NodeSource LTS 18.x)
if ! command -v node >/dev/null 2>&1 || [ "$(node -v 2>/dev/null | cut -d. -f1 | tr -d 'v')" -lt 18 ]; then
  echo "Installing Node.js 18.x..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get install -y nodejs
else
  echo "Node already installed: $(node -v)"
fi

# Optional: yarn (if you prefer)
if ! command -v yarn >/dev/null 2>&1; then
  echo "Installing yarn..."
  npm install --global yarn
else
  echo "Yarn present: $(yarn -v)"
fi

# Helpful PHP tools
if ! command -v php-cs-fixer >/dev/null 2>&1; then
  echo "Installing php-cs-fixer (optional)..."
  composer global require friendsofphp/php-cs-fixer --no-interaction
  export PATH="$PATH:$HOME/.config/composer/vendor/bin"
fi

# Show versions
echo "Installed versions:"
php -v | head -n 1
composer --version
symfony -v || true
node -v
npm -v
yarn -v || true
git --version

echo "Bootstrap complete. Next steps (recommended):"
echo "  1) Open a new shell so PATH updates take effect."
echo "  2) cd into your workspace, clone repositories (stellar-assets, space-stellar-backend, xlm.fish)."
echo "  3) To create a minimal Symfony project: composer create-project symfony/skeleton xlmfish-site"
echo "  4) Add Twig: composer require twig symfony/apache-pack (or composer req webapp)"
echo
echo "If you want, I can generate a minimal Symfony scaffold and Twig templates for you to copy into the project."