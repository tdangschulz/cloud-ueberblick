// ============================================================
// app.js – die Express-Anwendung selbst, OHNE den Server zu starten
// ============================================================
// Getrennt von server.js, damit Tests (server.test.js) die App
// importieren und testen können, ohne dass dabei ein echter Port
// geöffnet wird (supertest übernimmt das für die Tests selbst).

const express = require('express');
const app = express();

// Diese Umgebungsvariablen werden im Dockerfile per ENV gesetzt
// bzw. per ARG->ENV durchgereicht — guter Live-Beweis für die
// Teilnehmer, dass ENV wirklich im laufenden Container ankommt.
const nodeEnv = process.env.NODE_ENV || 'nicht gesetzt';
const appVersion = process.env.APP_VERSION || 'nicht gesetzt';

// Hauptseite: zeigt an, dass die App läuft, inkl. der ENV-Werte
app.get('/', (req, res) => {
  res.send(`
    <h1>🐳 Docker-Beispielprojekt läuft!</h1>
    <p><strong>NODE_ENV:</strong> ${nodeEnv}</p>
    <p><strong>APP_VERSION:</strong> ${appVersion}</p>
    <p>Diese Seite läuft in einem Container, gestartet aus dem
    kommentierten Beispiel-Dockerfile.</p>
  `);
});

// Health-Endpoint: wird vom HEALTHCHECK-Befehl im Dockerfile
// aufgerufen (wget --spider http://localhost:3000/health)
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

module.exports = app;
