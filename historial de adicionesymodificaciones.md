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

### [Septiembre 2026] - Modo TV: Actualización de Política de Restricción Médica
*   **Ajuste de Horario de Salida:** Se actualizó el anuncio oficial de Recursos Humanos en la diapositiva 2 (`#tv-slide-top10`) para especificar que el personal con restricción médica vigente puede salir **10 minutos antes** (en lugar de 5 minutos).

### [Octubre 2026] - Exclusión de Áreas No Operativas en Gráficas del Dashboard y Auditorías de Tool Room en Viernes
*   **Exclusión de Áreas Comunes/No Operativas en Dashboard (`isDashboardExcludedArea`):**
    *   Se creó e implementó el filtro `isDashboardExcludedArea()` en `index.html` para omitir las áreas `VISITAS`, `LOBBY`, `MONITORES` y `OFICINAS` (así como sus variantes `visita`, `monitor`, `office`, `offices`) tanto del cálculo de acciones en proceso/vencidas/próximas (`validActions` en `updateDashboard()`) como de las gráficas de desempeño de áreas (`renderChartAreaScores()`).
    *   Se extendió la consistencia a reportes ejecutivos semanales (`renderWeeklyCharts()`) y áreas (`renderAreasCharts()`), así como al filtro de modo TV (`isTvExcludedArea()`).
*   **Restricción de Auditorías de Tool Room a Días Viernes:**
    *   **Alineación en Base de Datos (Supabase):** Se actualizaron todos los registros operativos de `TOOL ROOM` en `calendar_events` para que su programación coincida estrictamente con los días viernes de cada semana durante todo el ciclo (semanas de octubre y noviembre ajustadas a sus respectivos viernes: 09/10, 16/10, 23/10, 30/10, 06/11, 13/11, 27/11).
    *   **Validación Estricta en Drag & Drop (`calDrop`):** Si un auditor intenta arrastrar y soltar un evento de `TOOL ROOM` en un día diferente a viernes, la acción se bloquea automáticamente mostrando un toast de advertencia.
    *   **Validación y UI Dinámica en Modal (`openCalendarModal` y `saveCalendarEvent`):** Se deshabilita y bloquea visualmente la casilla de `TOOL ROOM` si la fecha elegida en el modal no es viernes; asimismo, `saveCalendarEvent()` previene el guardado si se intenta programar en cualquier día que no sea viernes.

### [Octubre 2026] - Integración de Acciones Vencidas Totales en el Reporte Semanal
*   **Función Centralizada de Extracción de Overdue (`getOverdueActionsForReport`):**
    *   Se desacopló y unificó la lógica de filtrado de acciones vencidas (evaluación de estatus, fecha límite respecto al SLA y cálculo de `daysOverdue`) para que tanto el Reporte de Acciones Vencidas como el Reporte Semanal compartan exactamente el mismo criterio y consistencia matemática.
*   **Inclusión de Acciones Vencidas Totales en el Reporte Semanal (`weekly`):**
    *   En `generateVisualReport()`, además de filtrar las auditorías y acciones de la semana seleccionada, se extrae la totalidad de acciones vencidas del site (`overdueData`).
    *   Se actualizó el mensaje ejecutivo (`greetingText`) para reportar la calificación promedio semanal junto con el total acumulado de acciones en estatus overdue (`Total de Acciones Vencidas (Overdue)`).
    *   En `renderWeeklyCharts()`, se integró una tercera tarjeta con la gráfica de barras apiladas por responsable (`chart-weekly-overdue`) que refleja la antigüedad acumulada de las acciones vencidas (`0-7 días`, `8-14 días`, `15-30 días`, `+30 días`) utilizando `getStackedAgingData(overdueData, 'owner')` idéntica a la del reporte de acciones vencidas, o un banner verde si el sitio no cuenta con acciones vencidas.

### [Octubre 2026] - Corrección y Robustez en Generación de Imagen del Reporte Semanal (html2canvas)
*   **Alineación de Ciclo de Vida y Renderizado en `renderWeeklyCharts`:**
    *   Se restauró el patrón síncrono estándar con temporizador interno (`setTimeout(() => { ... }, 100)`) utilizado en las demás funciones de reporte del sistema, eliminando bloqueos de promesas asíncronas que desfasaban el renderizado con respecto al llamado de `html2canvas`.
    *   Se aumentó la ventana de espera para la captura en `generateVisualReport()` a 1000ms para garantizar que las tres gráficas (calificaciones semanales, acciones generadas y acciones vencidas totales) completen su renderizado en el canvas antes de la exportación.
*   **Limpieza Preventiva de Instancias de Chart.js y Aislamiento de Errores:**
    *   Se incorporó la destrucción explícita de gráficas previas (`Chart.getChart(ctx)?.destroy()`) en los tres lienzos (`chart-weekly-scores`, `chart-weekly-actions`, `chart-weekly-overdue`) previniendo excepciones por reutilización de canvas.
    *   Se envolvieron las inicializaciones de cada gráfica y el procesamiento de aging en bloques `try...catch` individuales para que una eventualidad en un lienzo no interrumpa la exportación del reporte visual.
*   **Mejora en Manejo y Mensajería de Errores:**
    *   Se actualizó el bloque de captura de `html2canvas` para reportar en consola y alertar al usuario con el mensaje técnico específico en caso de cualquier excepción del navegador o de seguridad.

### [Octubre 2026] - Reparto Equitativo de Auditorías 5S en Calendario y Tool Room en Viernes
*   **Distribución Equitativa de Carga Semanal (15 / 15 / 15):**
    *   Se rebalancearon las 45 auditorías semanales programadas en la tabla `calendar_events` de Supabase entre los 3 auditores oficiales (`Gema`, `Jose`, `Alisson`).
    *   Anteriormente, la carga estaba desproporcionada (Alisson: 20 auditorías/semana, Jose: 15, Gema: 10).
    *   Con el nuevo reparto, cada auditor tiene asignadas exactamente **15 auditorías semanales** (1/3 de la carga operativa para cada uno).
*   **Balance Diario Equitativo:**
    *   En días con 9 auditorías (lunes, miércoles, jueves): cada persona tiene exactamente **3 auditorías diarias** (3 Gema, 3 Jose, 3 Alisson).
    *   En martes (8 auditorías) y viernes (10 auditorías): la asignación se ajusta (3, 3, 2 y 4, 3, 3 respectivamente) de forma balanceada para que el total semanal se mantenga estrictamente en 15 para cada auditor.
*   **Consistencia de Tool Room en Viernes:**
### [Octubre 2026] - Reemplazo de Control Tower por Critical Repair 4 y Ajuste de Carga (Gema: 14 auditorías/semana)
*   **Baja de Control Tower y Alta de Critical Repair 4:**
    *   **Base de Datos (Supabase):** Se actualizaron todos los registros (12 semanas) en la tabla `calendar_events` sustituyendo la locación inexistente `CONTROL TOWER` por `CRITICAL REPAIR 4`.
    *   **Frontend (`index.html`):**
        *   Se integró `Critical repair 4` al `Sector 1` y se retiró `Control tower` del `Sector 2` en `sectorMapping`.
        *   Se asignó el avatar de personaje `Iggy` a `critical repair 4` en `areaCharacterMap`.
        *   Se eliminó `control tower` de `excludedAreas`.
        *   Se actualizó el mapeo de respaldo `auditorFallbackMap` asociando `CRITICAL REPAIR 4` con auditor Jose.
*   **Ajuste y Rotación Equitativa de Carga (Gema: 14 auditorías/semana):**
    *   **Carga Semanal de Gema:** Se reajustó la programación para que Gema tenga exactamente **14 auditorías semanales** a lo largo de las 12 semanas del ciclo (distribuidas de forma óptima en 3 auditorías diarias y 2 en el día de menor carga de la semana).
    *   **Rotación Balanceada entre Jose y Alisson:** En las semanas regulares de 45 auditorías, Jose y Alisson rotan semanalmente entre 15 y 16 auditorías (ej. semana 1: Alisson 16, Jose 15; semana 2: Jose 16, Alisson 15), manteniendo un acumulado perfectamente equitativo a lo largo del trimestre (185 vs 186 auditorías). En la semana de 44 auditorías, ambos cuentan con exactamente 15 auditorías.
    *   **Preservación de Tool Room en Viernes:** Se mantuvo sin alteración la asignación estricta de `TOOL ROOM` exclusivamente en días viernes en todas las 12 semanas del ciclo.
    *   **Integridad de Datos Históricos:** Se conservó intacto el registro histórico completado (`Assembly|Gema` del 08/09/2026).
