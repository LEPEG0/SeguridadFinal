# Proyecto de Seguridad

## Descripción
Este proyecto implementa un sistema de comunicación segura entre dos equipos, utilizando RSA y técnicas de esteganografía.

## Funcionalidades
- Solicitar la llave pública de la contraparte.
- Capturar un mensaje o seleccionar un archivo.
- Generar el hash SHA-384 del mensaje.
- Encriptar el mensaje utilizando RSA invertido.
- Generar el hash SHA-512 del mensaje encriptado.
- Ocultar el mensaje en una imagen.
- Generar el hash Blake2 de la imagen con el mensaje oculto.
- Enviar el mensaje al otro equipo.
- Validar la integridad del mensaje recibido.
- Extraer el mensaje de la imagen.
- Desencriptar el mensaje utilizando la llave privada.
- Validar los hashes para asegurar la integridad del mensaje.

## Requisitos
- Zenity
- OpenSSL
- Steghide
- b2sum
- jq
- SSH para la transferencia de archivos

## Instalación
Ejecutar el siguiente comando para instalar las dependencias necesarias:
```bash
sudo apt update
sudo apt install zenity openssl steghide b2sum jq openssh-client
