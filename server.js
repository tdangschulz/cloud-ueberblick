// ============================================================
// server.js – startet die Express-App aus app.js auf Port 3000
// ============================================================
// Passt genau zum "Beispiel-Dockerfile-erklaert":
//   - lauscht auf Port 3000 (siehe EXPOSE 3000 im Dockerfile)
//   - bietet /health für den HEALTHCHECK-Befehl im Dockerfile

const app = require('./app');

const port = 3000;

app.listen(port, () => {
  console.log(`Docker-Beispielprojekt läuft auf Port ${port}`);
});
