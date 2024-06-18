#!/bin/bash

# 1
echo "Iniciando el sistema de comunicaciones seguras..."

# 2
source ./get_mac_address.sh

# 3
source ./generate_and_send_keys.sh

# 4
source ./encrypt_message.sh

# 5
source ./send_encrypted_file.sh

# 6
echo "Sistema de comunicaciones seguras completado."
