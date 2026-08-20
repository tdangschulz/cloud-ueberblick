# 🐱 Container of Cats – Elastic Beanstalk (Node.js)

Kleine Express-Website mit selbstgezeichneten (lizenzfreien) Katzen-Illustrationen –
gebaut für die AWS Elastic Beanstalk Node.js-Plattform.

## Projektstruktur

```
.
├── app.js              # Express-Server, liefert public/ aus
├── package.json        # Node.js-Abhängigkeiten & Start-Skript
└── public/
    ├── index.html       # Katzen-Galerie
    └── images/
        ├── cat1.svg      # Astronauten-Katze
        ├── cat2.svg      # Pizza-Katze
        └── cat3.svg      # Business-Katze
```

## Deployment auf Elastic Beanstalk

1. In der AWS-Konsole zu **Elastic Beanstalk** → **„Create Application"**
2. Application name vergeben, z. B. `container-of-cats-<dein-name>`
3. Bei **„Platform"**: **Node.js** auswählen (aktuelle Version)
4. Bei **„Application code"**: **„Upload your code"** wählen
5. Dieses **gesamte ZIP** (ohne übergeordneten Ordner, also `app.js`/`package.json` direkt auf oberster Ebene im ZIP) hochladen
6. **„Create application"** klicken und 5–10 Minuten warten
7. Die angezeigte URL öffnen → die Katzen-Galerie erscheint

Wichtig: **Kein `node_modules`-Ordner nötig** – Elastic Beanstalk führt beim Deployment
automatisch `npm install` anhand der `package.json` aus.

## Lokal testen (optional)

```bash
npm install
npm start
```

Danach unter `http://localhost:8080` erreichbar.
