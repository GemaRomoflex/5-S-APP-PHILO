# 📚 Historial de Adiciones y Modificaciones (Dashboard 5S)

> **⚠️ REGLA ESTRICTA PARA ASISTENTES IA (LLMs):**
> Este documento funciona como el mapa arquitectónico principal del proyecto. Tienes la obligación de leer estas reglas antes de modificar el código. Además, **CADA VEZ que realices una adición o modificación significativa en la aplicación, debes documentarla al final de este archivo** para mantener el contexto histórico actualizado y ahorrar tokens en futuras iteraciones.

---

## 🏛️ REGLAS ARQUITECTÓNICAS Y RESTRICCIONES CLAVE

### 1. La Base de Datos (Supabase) es Inflexible
La estructura original de la tabla `actions` en Supabase no puede ser alterada. **No intentes agregar nuevas columnas** (ej. `evidence_url`, `shift`, `source`). Si lo haces, Supabase rechazará la inserción y crasheará la app por error de "schema cache".

### 2. Esteganografía de Datos (Camuflaje en `comments`)
Dado que no podemos agregar columnas a Supabase, **cualquier metadato adicional** (múltiples fotografías, turno, etc.) debe inyectarse como texto plano al final de la columna oficial `comments`.
*   **Guardado:** Utiliza etiquetas únicas como `\nEVIDENCE:url1|url2` o `\nTURNO:2` pegadas al string del comentario.
*   **Lectura/Renderizado:** Cuando el frontend lea de Supabase, debe extraer esas etiquetas usando expresiones regulares (Regex), utilizarlas (ej. para pintar imágenes en HTML) y **borrarlas** de la variable temporal para que el usuario solo vea el texto limpio en la pantalla y en los reportes.

### 3. Identificación del Origen de los Datos (Sin columnas inventadas)
Para distinguir qué módulo generó una acción, no uses variables inexistentes como `item.source`. En su lugar, usa la columna oficial `department`:
*   Si es Gemba, usa `department: 'Gemba'`.
*   Si es Cruzada, usa `department: 'Cross Audit'`.
*   Si es Oficial, usa cualquier otro departamento corporativo.
*   *Nota: Todas las validaciones de filtros globales y reportes en JS deben basarse en `item.department`.*

### 4. Modelo de Seguridad (RBAC)
Todo el control de vistas está centralizado en la función `applyRBAC()`.
*   Cualquier botón u opción administrativa (como "Gestionar Owners" o "Editar Layout") debe tener la clase `hidden` o `display: none;` por defecto en el HTML.
*   Es tarea exclusiva de `applyRBAC()` evaluar si el `window.currentUserRole` es un Administrador y solo entonces revelar (`display: block`) los elementos protegidos. Los roles básicos son `Auditor` y `Auditor Cruzado`.

---

## 🛠️ HISTORIAL DE MODIFICACIONES

### [Julio 2026] - Módulo "Gemba Walks"
*   **Formulario Dedicado:** Se creó un formulario paralelo para registrar recorridos Gemba (Turno, Múltiples Áreas, Hallazgos múltiples, Nivel de Prioridad SLA).
*   **Cuadro de Mensaje Personalizable:** Se inyectó un `<textarea>` en la UI antes del botón de envío, lo que permite al auditor redactar o editar un mensaje ejecutivo y profesional antes de que se genere el reporte PDF.
*   **Reportes Automáticos Estéticos (PNG):** Se integró `html2canvas` para imprimir reportes de 1400px de ancho. Los reportes utilizan la imagen institucional `plantilla de comunicados.png` como cabecera (banner) y acomodan perfectamente las fotos (que extraen de los `comments`).

### [Julio 2026] - Panel Administrativo de Owners
*   **Modal Seguro:** Se desarrolló un panel flotante de "Gestión de Owners" conectado directamente a la tabla `owners_directory` en Supabase.
*   **CRUD Directo:** Permite al administrador consultar, agregar, editar y eliminar responsables y departamentos.
*   **Seguridad:** El botón para acceder a este panel está oculto por defecto y solo el sistema RBAC lo libera para Administradores.

### [Julio 2026] - Auditoría Cruzada (Fixes de Estabilidad)
*   **Refactorización de Evidencias:** Se purgó el código que intentaba guardar e invocar la columna fantasma `evidence_url`. Ahora el renderizado cruzado también extrae las fotografías secretas desde el interior de los `comments`.
