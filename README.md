# Proyecto Godot

Este repositorio contiene un proyecto desarrollado con el motor **Godot Engine**. A continuación se describen los pasos necesarios para abrirlo correctamente en el editor, así como información adicional sobre los archivos generados y su ubicación.

---

## 🧰 Requisitos

- [Godot Engine](https://godotengine.org/download) (versión compatible con este proyecto, preferiblemente la misma con la que fue creado)
- Opcional: un visor de archivos `.xlsx` (como Microsoft Excel o LibreOffice Calc) para analizar los resultados de pruebas

---

## 🚀 Cómo abrir el proyecto

1. Abre el editor de **Godot Engine**.
2. En la pantalla de inicio, haz clic en `Importar`.
3. Busca y selecciona la carpeta `TFG-iter-2` ubicada en la raíz del repositorio.
4. Haz clic en `Importar y editar`.

Esto abrirá el proyecto en el editor de Godot, desde donde podrás ejecutar y modificar la escena principal o cualquier otra.

---

## 📂 Carpeta `exports`

En la carpeta `exports` se encuentran los resultados de las pruebas realizadas, incluyendo:

- Un archivo `.xlsx` con los resultados numéricos.
- Uno o varios archivos `.png` con gráficos generados a partir de estos datos.

---

## ⚠️ Archivos generados en tiempo de ejecución

Cuando se ejecuta la **escena principal**, el proyecto genera archivos automáticamente en la **ruta por defecto de Godot**:


> ⚠️ Ten en cuenta que esta ubicación puede variar dependiendo del sistema operativo y configuración del usuario. En sistemas Windows, se encuentra típicamente en:
>
> ```
> C:\Users\<TuUsuario>\AppData\Roaming\Godot\app_userdata
> ```

---

## 📝 Notas adicionales

- Si decides mover el proyecto, asegúrate de mantener la estructura de carpetas original para evitar errores de carga de recursos.
- La carpeta `exports` no es necesaria para ejecutar el proyecto, pero sí útil para revisar los resultados de las pruebas.



