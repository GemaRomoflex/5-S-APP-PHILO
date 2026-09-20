# 📚 Historial de Adiciones y Modificaciones (Dashboard 5S)

> **⚠️ REGLA ESTRICTA PARA ASISTENTES IA (LLMs):**
> Este documento funciona como el mapa arquitectónico principal del proyecto. Tienes la obligación de leer estas reglas antes de modificar el código. Además:
> 1. **CADA VEZ que realices una adición o modificación significativa en la aplicación, debes documentarla al final de este archivo** para mantener el contexto histórico actualizado y ahorrar tokens en futuras iteraciones.
> 2. **OBLIGATORIO SUBIR A GITHUB AL TERMINAR:** Al concluir cualquier cambio, corrección o funcionalidad, es mandato obligatorio realizar commit y subir los cambios a GitHub (`git push origin main`) antes de finalizar la interacción.

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

### 5. Sincronización Obligatoria con GitHub
Todo cambio, mejora o corrección debe ser commiteado y subido al repositorio remoto de GitHub (`git push origin main`) una vez finalizado y probado. No dejar trabajo local pendiente de sincronización.

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

### [Agosto 2026] - Auditoría Cruzada (Ajuste de Interface / UI)
*   **Ocultar Encabezado Superior:** Se removió la visibilidad de la barra de encabezado superior (`main-header`) en la vista de Auditorías Cruzadas (`switchTab('audits')`) para eliminar los botones "Descargar Plantilla CSV" y "Cargar Datos Demo" de esta sección, manteniendo limpia la UI sin alterar el funcionamiento interno ni la lógica de carga de datos en las demás secciones.

### [Septiembre 2026] - Depuración de Datos de Prueba (L10 y L18)
*   **Limpieza en Base de Datos (Supabase):** Se eliminaron los 5 registros de prueba residuales correspondientes a las áreas inexistentes `L10` (acciones `ACT-101`, `ACT-102`, `ACT-103`) y `L18` (`ACT-115`, `ACT-116`) en la tabla `actions`, los cuales afectaban los indicadores y gráficas reales del dashboard.
*   **Corrección en Datos Demo y Plantilla CSV:** Se actualizaron las funciones `loadDemoData()` y `downloadSampleCSV()` en `index.html` para sustituir las áreas de ejemplo `L10` y `L18` por áreas reales operativas (`L11 TOP` y `L14 TOP`), evitando la reinyección accidental de áreas fantasma en la base de datos.

### [Septiembre 2026] - Modo TV: Panel Fijo de Aviso RH en Diapositiva 2
*   **Eliminación de Popup Modal Bloqueante:** Se retiró el modal emergente `#tv-disclaimer-modal` (que requería interacción o se cerraba por temporizador, tapando la información de fondo).
*   **Diseño Fijo a Dos Columnas:** En la Diapositiva 2 (`#tv-slide-top10`), la lista/gráfica del Top 10 se ajustó a la izquierda, mientras que a la derecha se integró un panel fijo estético en color rojo neón (`.tv-notice-panel`) con los letreros oficiales de RH, optimizado para pantallas desatendidas 24/7.

### [Septiembre 2026] - Modo TV: Rediseño Visual de Avisos RH y Paridad de Gráfica de Antigüedad
*   **Avisos RH Ultra-Visuales y Tipografía Gigante (Diapositiva 2):** Se simplificó y depuró el contenido del panel lateral derecho para maximizar su legibilidad en televisores sin texto pequeño:
    *   **Aviso Rojo de Salida Anticipada:** Tarjeta de advertencia en rojo (`.tv-notice-callout`) con icono ⚠️ destacando que cualquier salida antes de tiempo se realiza *ÚNICAMENTE* con acompañamiento del supervisor inmediato.
    *   **Inclusión de Restricción Médica:** Tarjeta informativa azul neón (`.tv-notice-medical`) con icono 🩺 estipulando que el personal con restricción médica vigente también cuenta con el beneficio de salida 5 minutos antes presentando su documento.
    *   **Comparador Visual de Horarios:** Bloques visuales lado a lado con relojes digitales gigantes comparando la **Salida 5 min antes** (en verde neón para Top 4 + Restricción Médica) frente a la **Salida Normal** (horario habitual de turno).
*   **Paridad de Gráfica de Antigüedad de Acciones (Diapositiva 1):** Se unificó `renderTvChartAgingOverdue()` en `index.html` para invocar la misma lógica `getStackedAgingData(arrOverdue, agingOverdueGroupBy)` del dashboard principal, restaurando las barras apiladas por departamento clasificadas en rangos (`0-7 días`, `8-14 días`, `15-30 días`, `+30 días`).

### [Septiembre 2026] - Modo TV: Exclusión de Áreas Comunes y Edificios Externos en Tops
*   **Filtro de Áreas Inelegibles (`isTvExcludedArea`):** Se creó una función de filtrado para omitir áreas que no cuentan con personal asignado en la nave o cuyo personal checa su salida en otros edificios, evitando que aparezcan en los rankings de incentivos de RH y tops de TV.
*   **Áreas Excluidas:** `RMA GLP`, `RMA VLP`, `LOBBY`, `MONITORES`, `OFFICES` (y variantes de oficina), `TEST ROOM 2`, `MOONSHINE`, `ENTRADA`, `PERIFERIAS`, `RECICLAJE`, `PASILLO SMKT-SMT`, `PASILLO PACK-WAREHOUSE`.
*   **Alcance:**
    *   **Diapositiva 2 (Top 10 Mejores Áreas):** Los incentivos de salida 5 minutos antes para los primeros 4 puestos ahora se asignan estrictamente a líneas de producción y áreas operativas con personal local (`TOOL ROOM`, `L11 BOTTOM`, `L14 BOTTOM`, `L12 BOTTOM`, etc.).
    *   **Diapositiva 1 (Top 10 Peores Áreas):** Depuración de la gráfica de desempeño, sustituyendo áreas comunes (como `MONITORES`) por áreas productivas reales.
