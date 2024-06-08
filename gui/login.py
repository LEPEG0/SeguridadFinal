import tkinter as tk
from tkinter import messagebox
import socket
import uuid
import json

class PantallaInicioSesion(tk.Frame):
    def __init__(self, master):
        super().__init__(master)
        self.master = master

        # Elementos de la pantalla de inicio de sesión
        self.label_usuario = tk.Label(self, text="Usuario:")
        self.entry_usuario = tk.Entry(self)

        self.label_contrasena = tk.Label(self, text="Contraseña:")
        self.entry_contrasena = tk.Entry(self, show="*")

        self.checkbox_avisos = tk.Checkbutton(self, text="Aceptar avisos de privacidad y políticas de usuario")

        self.boton_login = tk.Button(self, text="Iniciar Sesión", command=self.iniciar_sesion)

        # Posicionamiento de los elementos
        self.label_usuario.grid(row=0, column=0, padx=10, pady=5, sticky=tk.E)
        self.entry_usuario.grid(row=0, column=1, padx=10, pady=5)

        self.label_contrasena.grid(row=1, column=0, padx=10, pady=5, sticky=tk.E)
        self.entry_contrasena.grid(row=1, column=1, padx=10, pady=5)

        self.checkbox_avisos.grid(row=2, columnspan=2, padx=10, pady=5)

        self.boton_login.grid(row=3, columnspan=2, padx=10, pady=10)

    def obtener_ip(self):
        try:
            ip = socket.gethostbyname(socket.gethostname())
            return ip
        except:
            return "Error al obtener la IP"

    def obtener_mac(self):
        try:
            mac = ':'.join(['{:02x}'.format((uuid.getnode() >> elements) & 0xff) for elements in range(0,2*6,2)][::-1])
            return mac
        except:
            return "Error al obtener la MAC Address"

    def guardar_info_sesion(self, usuario, contrasena):
        ip = self.obtener_ip()
        mac = self.obtener_mac()

        if ip.startswith("Error") or mac.startswith("Error"):
            messagebox.showerror("Error", "No se pudo obtener la información de red.")
            return

        sesion_info = {
            "usuario": usuario,
            "password": contrasena,
            "ip": ip,
            "macAddress": mac,
            "activo": 1  # Por defecto, la sesión está activa
        }

        with open("sesion_info.json", "w") as file:
            json.dump(sesion_info, file)

    def iniciar_sesion(self):
        usuario = self.entry_usuario.get()
        contrasena = self.entry_contrasena.get()

        if usuario == "" or contrasena == "":
            messagebox.showerror("Error", "Por favor, ingrese nombre de usuario y contraseña.")
            return

        self.guardar_info_sesion(usuario, contrasena)
        messagebox.showinfo("Éxito", "Inicio de sesión exitoso!")
