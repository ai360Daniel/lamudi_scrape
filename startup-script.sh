#!/bin/bash

# Script startup ultra simple para VMs de Lamudi Scraper
# Instalaciones básicas requeridas

apt-get update
apt-get install -y python3-pip git
apt-get install -y chromium-browser
apt-get install -y chromium-chromedriver

# Clonar repositorio
cd /root || cd /tmp
git clone https://github.com/ai360Daniel/lamudi_scrape.git

# Instalar dependencias Python
cd lamudi_scrape
pip3 install -r requirements.txt

echo "Setup completado en $(date)" > /tmp/setup-complete.txt
