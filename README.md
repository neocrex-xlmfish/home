# Stellar Scripts & Symfony Website Integration

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue.svg)](https://www.python.org/)
[![Symfony](https://img.shields.io/badge/symfony-php%208.x-black.svg)](https://symfony.com/)
[![Stellar](https://img.shields.io/badge/stellar-API-blueviolet.svg)](https://www.stellar.org/developers/)

---

## Project Overview

This repository contains a collection of scripts and tools for interacting with the Stellar blockchain, as well as the beginnings of a web-based interface.  
The project is split into two main components:

- **Python scripts:**  
  Used for local command-line operations, automation, and bots (e.g., managing trustlines, account creation, asset monitoring).

- **Website (Symfony/PHP):**  
  A web application (currently static HTML, planned migration to Symfony) for user-facing features and Stellar network interaction via PHP.

---

## Project Intent

- **Separation of Concerns:**  
  Keep blockchain operations/automation in Python for flexibility and scripting power.
  Use PHP/Symfony for the website to leverage a robust web framework and native web features.

- **Integration Goal:**  
  Over time, integrate Stellar blockchain operations directly into the website using PHP components, while continuing to use Python scripts for local and automated tasks such as bots.

- **Scalability:**  
  This architecture allows for rapid development and testing with Python, and stable, scalable user interfaces with Symfony.

---

## Tech Stack

- **Python 3:**  
  For blockchain scripts, bots, and automation.
- **PHP (Symfony):**  
  For the website (planned migration from static HTML).
- **Stellar SDKs:**  
  - [stellar-sdk for Python](https://github.com/StellarCN/py-stellar-base)
  - [stellar-php/stellar-php](https://github.com/stellar-php/stellar-php) (PHP integration, planned)
- **GitHub Actions:**  
  (Optional) For CI/CD and automation.

---

## Getting Started

### Python Scripts

1. Clone the repository:
    ```sh
    git clone https://github.com/neocrex-xlmfish/stellar-scripts.git
    cd stellar-scripts
    ```

2. Set up your Python environment:
    ```sh
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```

3. Run a script (example):
    ```sh
    python3 create_trustlines.py --wallet-secret WALLET_SECRET --wallet-public WALLET_PUBLIC
    ```

### Website

- The web component is currently static HTML but will be migrated to Symfony.  
- PHP/Symfony code will be located under `/web` (planned).
- To run the website locally (in the future):
    ```sh
    cd web
    symfony serve
    ```

---

## Roadmap

- [x] Add Python scripts for trustline management
- [x] Introduce configuration file support for Horizon URLs
- [ ] Migrate website to Symfony PHP framework
- [ ] Integrate Stellar operations into Symfony using PHP SDK
- [ ] Document API endpoints and usage examples
- [ ] Add CI/CD workflows

---

## Contributing

Contributions are welcome!
- For Python scripts: add features or improve automation/bots.
- For the website: help migrate to Symfony and implement PHP Stellar integration.

---

## License

MIT License

---

## Contact

- Project maintainer: [neocrex-xlmfish](https://github.com/neocrex-xlmfish)