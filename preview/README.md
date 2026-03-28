# Vista previa visual (mock UI)

Esta carpeta contiene una maqueta estática para visualizar rápidamente el look & feel inicial del aplicativo.

## Ejecutar localmente

Desde la raíz del repo:

```bash
python3 -m http.server 8080
```

Luego abrir en navegador:

- http://localhost:8080/preview/

## Alcance
- Dashboard web con tabla de hallazgos y etiquetas de estado/prioridad.
- Pantalla móvil de creación de hallazgo (foto, audio, transcripción, origen, prioridad, ubicación, responsable).

> Nota: es una **vista mock** (sin backend conectado). En siguientes iteraciones se reemplaza por frontend real (Next.js + Expo).
