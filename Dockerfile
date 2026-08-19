# ============================================================
# BEISPIEL-DOCKERFILE zum Erklären der wichtigsten Docker-Befehle
# ============================================================
# Dieses Dockerfile baut eine kleine Node.js-Webanwendung.
# Jede Zeile ist bewusst ausführlich kommentiert für die Schulung.


# ------------------------------------------------------------
# FROM: Basis-Image, auf dem alles aufbaut
# ------------------------------------------------------------
# Jedes Docker-Image startet mit einem Basis-Image (Layer 1).
# "node:20-alpine" = offizielles Node.js-Image, "alpine" = extra
# schlanke Linux-Distribution (~5 MB statt ~900 MB bei "node:20").
# GUTER GESPRÄCHSPUNKT: Warum ist ein kleineres Image besser?
# (schnellere Downloads, kleinere Angriffsfläche, schnelleres Deployment)
FROM node:24-alpine


# ------------------------------------------------------------
# LABEL: Metadaten am Image hinterlegen (optional, aber gute Praxis)
# ------------------------------------------------------------
LABEL maintainer="cloud-schulung@beispiel.de"
LABEL description="Beispiel-Image zur Erklärung von Docker-Grundlagen"


# ------------------------------------------------------------
# ARG: Build-Zeit-Variable (nur beim "docker build" verfügbar,
# NICHT mehr im laufenden Container)
# ------------------------------------------------------------
# Nützlich z.B. für Versionsnummern, die beim Bauen übergeben werden:
# docker build --build-arg APP_VERSION=1.2.0 .
ARG APP_VERSION=1.0.0


# ------------------------------------------------------------
# ENV: Umgebungsvariable, die AUCH im laufenden Container existiert
# ------------------------------------------------------------
# Unterschied zu ARG: ENV bleibt zur Laufzeit erhalten,
# ARG nur während des Build-Vorgangs.
ENV NODE_ENV=production
ENV APP_VERSION=${APP_VERSION}


# ------------------------------------------------------------
# WORKDIR: Arbeitsverzeichnis IM Container festlegen
# ------------------------------------------------------------
# Alle folgenden Befehle (COPY, RUN, CMD, ...) beziehen sich
# relativ auf dieses Verzeichnis. Wird angelegt, falls nicht vorhanden.
WORKDIR /app


# ------------------------------------------------------------
# COPY: Dateien vom Build-Kontext (deinem Rechner) ins Image kopieren
# ------------------------------------------------------------
# WICHTIG für Caching: package.json ZUERST separat kopieren,
# BEVOR der restliche Code kopiert wird (siehe RUN npm install unten).
# Docker cached jeden Layer einzeln — ändert sich nur der Anwendungscode,
# nicht aber package.json, muss "npm install" beim nächsten Build
# NICHT erneut ausgeführt werden. Das spart bei jedem Rebuild Zeit.
COPY package.json package-lock.json ./


# ------------------------------------------------------------
# RUN: Befehl WÄHREND des Build-Vorgangs ausführen
# ------------------------------------------------------------
# Jedes RUN erzeugt einen eigenen Layer im Image.
# "npm ci" statt "npm install": installiert exakt die Versionen
# aus package-lock.json — reproduzierbarer als "npm install".
RUN npm ci --only=production


# ------------------------------------------------------------
# COPY (zweiter Aufruf): jetzt erst den restlichen Anwendungscode kopieren
# ------------------------------------------------------------
# Bewusst NACH "npm ci", damit Code-Änderungen (die viel häufiger
# vorkommen als Abhängigkeits-Änderungen) den npm-install-Layer
# nicht "invalidieren" (= nicht neu ausführen müssen).
COPY . .


# ------------------------------------------------------------
# ADD: ähnlich wie COPY, kann aber ZUSÄTZLICH:
#  - entfernte URLs herunterladen
#  - .tar-Archive automatisch entpacken
# ------------------------------------------------------------
# BEST PRACTICE: COPY bevorzugen, wenn keine der Zusatzfunktionen
# gebraucht wird — ADD ist "mächtiger", aber weniger vorhersehbar.
# Beispiel (hier auskommentiert, nur zur Erklärung):
# ADD https://beispiel.de/config.tar.gz /app/config/


# ------------------------------------------------------------
# EXPOSE: dokumentiert, auf welchem Port die Anwendung im Container lauscht
# ------------------------------------------------------------
# WICHTIG: EXPOSE öffnet NICHT wirklich den Port nach außen!
# Es ist nur Dokumentation. Die tatsächliche Portfreigabe passiert
# beim "docker run -p 8080:3000 ..." bzw. in Lightsail/ECS bei
# "Open ports" / "Port Mapping".
EXPOSE 3000


# ------------------------------------------------------------
# USER: Container NICHT als root laufen lassen (Sicherheit!)
# ------------------------------------------------------------
# Alpine-Node-Images bringen bereits einen unprivilegierten
# "node"-User mit. Guter Diskussionspunkt für die Security-Sektion:
# Warum ist "als root laufen" riskant, wenn ein Angreifer aus dem
# Container ausbrechen könnte?
USER node


# ------------------------------------------------------------
# VOLUME: Verzeichnis kennzeichnen, das persistente Daten enthält
# ------------------------------------------------------------
# Daten in einem VOLUME überleben einen "docker rm" des Containers.
# Guter Vergleich zur Cloud-Theorie: Container selbst sind "cattle"
# (austauschbar), aber Volumes sind wie eine externe Festplatte,
# die man an einen neuen Container "cattle" wieder anschließen kann.
VOLUME ["/app/logs"]


# ------------------------------------------------------------
# HEALTHCHECK: Docker prüft selbstständig, ob die Anwendung noch lebt
# ------------------------------------------------------------
# Relevant für Orchestrierung (ECS/Kubernetes): ein "unhealthy"
# Container kann automatisch neu gestartet werden.
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1


# ------------------------------------------------------------
# ENTRYPOINT vs. CMD: beide legen fest, was beim Start passiert —
# aber mit unterschiedlichem Zweck
# ------------------------------------------------------------
# ENTRYPOINT: das "Hauptprogramm", schwer von außen überschreibbar
# CMD: Standard-Argumente/Befehl, LEICHT überschreibbar
#      (z.B. mit "docker run mein-image andere-datei.js")
#
# Häufiges Muster: ENTRYPOINT + CMD kombiniert:
# ENTRYPOINT ["node"]
# CMD ["server.js"]
# → docker run mein-image        → führt aus: node server.js
# → docker run mein-image app.js → führt aus: node app.js
#
# Hier bewusst einfacher, nur CMD (reicht für die meisten Fälle):
CMD ["node", "server.js"]


# ============================================================
# ZUM AUSPROBIEREN MIT DEN TEILNEHMERN:
# ------------------------------------------------------------
# Bauen:   docker build -t mein-beispiel-image .
# Starten: docker run -p 8080:3000 mein-beispiel-image
# Layer ansehen: docker history mein-beispiel-image
# Größe vergleichen: docker images
# ============================================================
