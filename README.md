# 🐳 Docker-Beispielprojekt für die Cloud-Schulung

Kleine, lauffähige Node.js/Express-App, passend zum ausführlich kommentierten
Beispiel-Dockerfile — zum Erklären der wichtigsten Docker-Konzepte anhand
eines echten Builds.

## Enthaltene Dateien

- **Dockerfile** — jede Anweisung (FROM, ARG, ENV, WORKDIR, COPY, RUN, ADD,
  EXPOSE, USER, VOLUME, HEALTHCHECK, ENTRYPOINT/CMD) ausführlich kommentiert
- **server.js** — Express-Server, zeigt live die ENV-Werte aus dem Dockerfile an
  und bietet einen `/health`-Endpoint für den HEALTHCHECK-Befehl
- **package.json** / **package-lock.json** — Abhängigkeiten (nur `express`)

## Zum Ausprobieren mit den Teilnehmern

```bash
# Image bauen
docker build -t mein-beispiel-image .

# Mit angepasster Versionsnummer bauen (zeigt ARG live)
docker build --build-arg APP_VERSION=2.0.0 -t mein-beispiel-image .

# Starten (Port 3000 im Container → Port 8080 auf dem Host)
docker run -p 8080:3000 mein-beispiel-image

# Im Browser öffnen: http://localhost:8080
# Zeigt NODE_ENV und APP_VERSION direkt aus den ENV-Variablen an

# Health-Endpoint direkt testen
curl http://localhost:8080/health

# Layer-Historie ansehen (guter Talking Point für Layer-Caching)
docker history mein-beispiel-image

# Image-Größe ansehen
docker images mein-beispiel-image
```

## Guter Vorführ-Moment: Layer-Caching live zeigen

1. `docker build -t test .` einmal ausführen → Zeit stoppen
2. Nur in `server.js` eine Kleinigkeit ändern (z. B. Text in der `/`-Route)
3. `docker build -t test .` erneut ausführen → deutlich schneller, weil
   der `npm ci`-Layer aus dem Cache wiederverwendet wird
   (`package.json` hat sich ja nicht geändert!)
4. Jetzt zum Vergleich `package.json` selbst ändern (z. B. Beschreibung) und
   neu bauen → jetzt dauert `npm ci` wieder komplett neu
