# 📚 Historial de Adiciones y Modificaciones (Dashboard 5S)

> **⚠️ REGLA ESTRICTA PARA ASISTENTES IA (LLMs):**
> Este documento funciona como el mapa arquitectónico principal del proyecto. Tienes la obligación de leer estas reglas antes de modificar el código. Además:
> 1. **CADA VEZ que realices una adición o modificación significativa en la aplicación, debes documentarla al final de este archivo** para mantener el contexto histórico actualizado y ahorrar tokens en futuras iteraciones.
> 2. **OBLIGATORIO SUBIR A GITHUB AL TERMINAR:** Al concluir cualquier cambio, corrección o funcionalidad, es mandato obligatorio realizar commit y subir los cambios a GitHub (`git push origin main`) antes de finalizar la interacción.
> 3. **PROHIBICIÓN ESTRICTA DE DATOS DE PRUEBA O DEMO:** La base de datos (Supabase) contiene información real y operativa de producción. Queda terminantemente prohibido inyectar o cargar registros de prueba/demo (ej. `ACT-*`, `AUD-*`, o invocar `loadDemoData()`) ya que alteran directamente los métricos reales.

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

### 6. Prohibición Absoluta de Datos de Prueba / Demo
La base de datos (Supabase) almacena exclusivamente métricas, hallazgos y auditorías reales de las líneas operativas. Está terminantemente prohibido ejecutar, invocar o reactivar funciones de inserción de datos de prueba (como `loadDemoData()`, registros `ACT-*`, `AUD-*` o similares), así como reincorporar botones o disparadores demo en la interfaz. Toda prueba de desarrollo debe limitarse a la inspección de datos existentes o mocks locales en memoria sin persistencia remota.

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

### [Septiembre 2026] - Calificaciones 0 y 4 en Promedios y Acciones Correctivas
*   **Inclusión de Calificación 0 en Promedios (Escala 0-5):**
    *   Se actualizó la lógica matemática en `getAuditScores()`, `calculateKPIs()`, `calculateGlobalMetrics()`, vista de Mapa/Layout y los generadores de reportes ejecutivos para que la calificación `0` (incumplimiento total) sea tomada en cuenta en los promedios como 0 puntos (0%), afectando proporcionalmente la calificación del área.
    *   Se mantiene el valor `-1` como el único identificador para preguntas *"No Aplica"* (N/A) que quedan descartadas del cálculo.
*   **Tratamiento de Calificación 4 como Aprobatoria:**
    *   Se formalizó en `isValidAction()` y filtros de acciones que las calificaciones `4` y `5` se consideran conformes/aprobadas y no generan tickets ni acciones correctivas (no admiten fotos ni owner), pero **sí se incluyen y ponderan en los promedios y porcentajes del área** (donde un 4 equivale al 80%).
    *   Se permitió que hallazgos con calificación `0` a `3` puedan generar acciones correctivas reales siempre que cuenten con fecha compromiso o responsable asignado.

### [Septiembre 2026] - Eliminación Definitiva de Datos de Prueba y Bloqueo de Carga Demo
*   **Purga Completa en Base de Datos (Supabase):** Se eliminaron de forma permanente y definitiva todos los registros demo residuales (`ACT-101` a `ACT-118` / `AUD-2026-001` a `AUD-2026-007`) de la tabla `actions`, restaurando la pureza de las métricas reales del site.
*   **Retiro del Botón de la UI:** Se eliminó por completo el botón "Cargar Datos Demo" del encabezado principal (`header-actions`) para imposibilitar disparos o clics accidentales.
*   **Neutralización de `loadDemoData()`:** Se desmanteló el cuerpo de la función en `index.html` impidiendo que realice escrituras o llamadas `upsert` a Supabase bajo ninguna circunstancia.
*   **Regla de Arquitectura Permanente:** Se integró formalmente la regla 6 de "Prohibición Absoluta de Datos de Prueba / Demo" en las directrices mandatorias del proyecto.


