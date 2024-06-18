#!/bin/bash

encrypt_message() {
    # 1
    read -p "Desea capturar un mensaje (1) o seleccionar un archivo (2)? " choice
    if [ "$choice" -eq 1 ]; then
        # 2
        read -p "Ingrese el mensaje a cifrar: " message
        # 3
        echo "$message" > mensaje.txt
        # 4
        openssl rsautl -encrypt -inkey ~/.ssh/public_key.pem -pubin -in mensaje.txt -out mensaje_cifrado.bin
        if [ $? -eq 0 ]; then
            # 5
            echo "Mensaje cifrado y guardado en mensaje_cifrado.bin"
            # 6
            sha384sum mensaje.txt | awk '{ print $1 }' > mensaje_cifrado.bin.sha384
            # 7
            echo "Hash SHA-384 del mensaje generado y guardado en mensaje_cifrado.bin.sha384"
            # 8
            sha512sum mensaje_cifrado.bin | awk '{ print $1 }' > mensaje_cifrado.bin.sha512
            # 9
            echo "Hash SHA-512 del mensaje cifrado generado y guardado en mensaje_cifrado.bin.sha512"
            # 10
            b2sum mensaje_cifrado.bin | awk '{ print $1 }' > mensaje_cifrado.bin.blake2
            # 11
            echo "Hash BLAKE2 del mensaje cifrado generado y guardado en mensaje_cifrado.bin.blake2"
        else
            # 12
            echo "Error al cifrar el mensaje."
            exit 1
        fi
    elif [ "$choice" -eq 2 ]; then
        # 13
        read -p "Ingrese la ruta del archivo a cifrar: " file_path
        # 14
        if [ ! -f "$file_path" ]; then
            # 15
            echo "El archivo no existe."
            exit 1
        fi
        # 16
        openssl rsautl -encrypt -inkey ~/.ssh/public_key.pem -pubin -in "$file_path" -out archivo_cifrado.bin
        if [ $? -eq 0 ]; then
            # 17
            echo "Archivo cifrado y guardado en archivo_cifrado.bin"
            # 18
            sha384sum "$file_path" | awk '{ print $1 }' > archivo_cifrado.bin.sha384
            # 19
            echo "Hash SHA-384 del archivo generado y guardado en archivo_cifrado.bin.sha384"
            # 20
            sha512sum archivo_cifrado.bin | awk '{ print $1 }' > archivo_cifrado.bin.sha512
            # 21
            echo "Hash SHA-512 del archivo cifrado generado y guardado en archivo_cifrado.bin.sha512"
            # 22
            b2sum archivo_cifrado.bin | awk '{ print $1 }' > archivo_cifrado.bin.blake2
            # 23
            echo "Hash BLAKE2 del archivo cifrado generado y guardado en archivo_cifrado.bin.blake2"
        else
            # 24
            echo "Error al cifrar el archivo."
            exit 1
        fi
    else
        # 25
        echo "Opción no válida. Por favor, intente de nuevo."
        exit 1
    fi

    # 26
    read -p "¿Desea ocultar el mensaje cifrado en un archivo? (s/n): " hide_choice
    if [ "$hide_choice" == "s" ]; then
        # 27
        read -p "Ingrese la ruta del archivo de esteganografía (imagen, audio, etc.): " stego_file
        # 28
        if [ ! -f "$stego_file" ]; then
            # 29
            echo "El archivo de esteganografía no existe."
            exit 1
        fi
        # 30
        steghide embed -cf "$stego_file" -ef mensaje_cifrado.bin -sf stego_output -p "passphrase"
        if [ $? -eq 0 ]; then
            # 31
            echo "Mensaje ocultado en $stego_file y guardado en stego_output"
        else
            # 32
            echo "Error al ocultar el mensaje."
            exit 1
        fi
    fi
}

encrypt_message
