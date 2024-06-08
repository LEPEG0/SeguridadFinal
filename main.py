import tkinter as tk
from gui.login import PantallaInicioSesion

class MiAplicacion(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Mi Aplicación")
        self.geometry("400x300")  # Tamaño predeterminado de la ventana
        self.resizable(False, False)  # Evitar que la ventana sea redimensionable

        # Abrir la pantalla de inicio de sesión
        self.mostrar_pantalla_inicio_sesion()

    def mostrar_pantalla_inicio_sesion(self):
        self.pantalla_inicio_sesion = PantallaInicioSesion(self)
        self.pantalla_inicio_sesion.pack(fill=tk.BOTH, expand=True)

if __name__ == "__main__":
    app = MiAplicacion()
    app.mainloop()
