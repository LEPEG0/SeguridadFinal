#!/bin/bash

echo "Iniciando el sistema de comunicaciones seguras..."

# Obtener la dirección MAC de la contraparte
source ./get_mac_address.sh

# Solicitar la llave pública del administrador por SSH
source ./get_public_key.sh

# Capturar o seleccionar un archivo y cifrarlo
source ./encrypt_message.sh

# Enviar el archivo cifrado a otro equipo
source ./send_encrypted_file.sh

echo "Sistema de comunicaciones seguras completado."

