# Anleitung: EC2-Webserver mit CloudFormation erstellen

**Dauer:** ca. 10 Minuten
**Voraussetzung:** Zugang zur AWS-Konsole, Berechtigung für EC2 & CloudFormation

---

## Worum geht's?

Das ist die **automatische Version** der EC2-Übung von Tag 2 (Folie 66a).
Statt Instanz, Security Group (Firewall-Regeln) und Webserver einzeln von
Hand einzurichten, beschreibt eine einzige Datei (das **CloudFormation-
Template**) alles auf einmal. AWS liest diese Datei und baut daraus
automatisch alle Ressourcen – inklusive der Webserver-Installation über
ein Startskript, das **UserData** heißt.

---

## Schritt 1: Key Pair sicherstellen

Für den späteren Fernzugriff per SSH auf die Instanz braucht ihr ein
**Key Pair** (ein Schlüsselpaar, mit dem ihr euch später einloggen könnt):

1. In der EC2-Konsole unter **„Key Pairs"** prüfen, ob schon eines
   existiert (z. B. aus der EC2-Übung von Folie 66a)
2. Falls nicht: **„Create key pair"** → Namen vergeben → `.pem`-Datei
   herunterladen und gut aufbewahren

---

## Schritt 2: Stack erstellen

Ein **Stack** ist einfach die Gruppe aller Ressourcen, die aus einem
Template entstehen.

1. In der AWS-Konsole zu **CloudFormation** navigieren
2. **„Create stack"** → **„With new resources (standard)"**
3. **„Upload a template file"** → `cloudformation-ec2-webserver.yaml`
   hochladen → **„Next"**

---

## Schritt 3: Parameter setzen

1. **Stack name**: z. B. `ec2-webserver-<dein-name>`
2. **KeyPairName**: das vorhandene Key Pair aus Schritt 1 auswählen
3. **InstanceType**: `t2.micro` (Standard, kostenlos im Free Tier)
   einfach so lassen
4. Zweimal **„Next"**, dann **„Submit"**

---

## Schritt 4: Warten & Ergebnis prüfen

1. Der Status wechselt von **„CREATE_IN_PROGRESS"** (wird gerade
   erstellt) zu **„CREATE_COMPLETE"** (fertig) – dauert ca. 1–2 Minuten,
   etwas länger als bei S3, weil hier eine echte Instanz hochfährt
2. Tab **„Outputs"** öffnen → **WebsiteURL** kopieren
3. URL im Browser öffnen → die automatisch installierte Seite erscheint

   > Hinweis: Der Webserver braucht nach „CREATE_COMPLETE" noch ein
   > paar Sekunden zusätzlich, bis das Startskript fertig durchgelaufen
   > ist. Bei „Connection refused" also einfach kurz warten und die
   > Seite neu laden.

---

## Schritt 5: Aufräumen

1. Zurück zu CloudFormation → Stack auswählen → **„Delete"**
2. Bestätigen – CloudFormation löscht automatisch die Instanz UND die
   Security Group, und zwar in der richtigen Reihenfolge (das müsstet
   ihr bei manueller Konfiguration selbst beachten: erst Instanz
   beenden, dann Security Group löschen)

---

## Troubleshooting

| Problem | Lösung |
|---|---|
| **Bei KeyPairName ist keine Auswahl möglich** | Es existiert noch kein Key Pair – erst Schritt 1 nachholen |
| **CREATE_FAILED: UnauthorizedOperation** | Der Account darf keine EC2-Instanzen erstellen – Trainer fragen |
| **Rollback wegen Ressourcen-Limit** | Es laufen vermutlich schon zu viele Instanzen im Account (Sandbox-Limit) – alte Instanzen aus vorherigen Übungen beenden |
| **Website lädt nicht nach CREATE_COMPLETE** | Das Startskript läuft noch – 30–60 Sekunden warten und neu laden |

---

## Zum Nachdenken

- Vergleich zur manuellen EC2-Übung (Folie 66a): Was musstet ihr dort
  per SSH eintippen, was passiert hier automatisch im UserData-Startskript?
- Was passiert, wenn ihr den Stack löscht und mit einem **geänderten**
  Startskript neu erstellt? (Antwort: eine komplett neue, saubere
  Instanz – nichts "Handgestricktes" bleibt zurück, anders als bei
  manueller Konfiguration)
- Genau das ist der Kern von **Konsistenz & Wiederholbarkeit** aus
  Folie 95
