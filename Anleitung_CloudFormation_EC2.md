# Anleitung: EC2-Webserver mit CloudFormation provisionieren

**Dauer:** ca. 10 Minuten
**Voraussetzung:** Zugang zur AWS-Konsole, Berechtigung für EC2 & CloudFormation

---

## Worum geht's?

Das ist die **automatisierte Version** der manuellen EC2-Übung von Tag 2
(Folie 66a): Statt Instanz, Security Group und Webserver einzeln von Hand zu
konfigurieren, beschreibt ein CloudFormation-Template alles auf einmal –
inklusive Webserver-Installation per Startskript (**UserData**).

---

## Schritt 1: Key Pair sicherstellen

Für SSH-Zugriff wird ein vorhandenes Key Pair benötigt:

1. In der EC2-Konsole unter **„Key Pairs"** prüfen, ob bereits eines existiert
   (z. B. aus der EC2-Übung von Folie 66a)
2. Falls nicht: **„Create key pair"** → Namen vergeben → `.pem`-Datei herunterladen

---

## Schritt 2: Stack erstellen

1. In der AWS-Konsole zu **CloudFormation** navigieren
2. **„Create stack"** → **„With new resources (standard)"**
3. **„Upload a template file"** → `cloudformation-ec2-webserver.yaml` hochladen → **„Next"**

---

## Schritt 3: Parameter setzen

1. **Stack name**: z. B. `ec2-webserver-<dein-name>`
2. **KeyPairName**: das vorhandene Key Pair aus Schritt 1 auswählen
3. **InstanceType**: `t2.micro` (Standard, Free Tier) belassen
4. Zweimal **„Next"**, dann **„Submit"**

---

## Schritt 4: Warten & Ergebnis prüfen

1. Status wechselt von **„CREATE_IN_PROGRESS"** zu **„CREATE_COMPLETE"**
   (dauert ca. 1–2 Minuten – etwas länger als bei S3, da eine echte Instanz hochfährt)
2. Tab **„Outputs"** öffnen → **WebsiteURL** kopieren
3. URL im Browser öffnen → automatisch installierte Seite erscheint

   > Hinweis: Der Webserver braucht nach dem „CREATE_COMPLETE" noch ein paar
   > Sekunden zusätzlich, bis das UserData-Skript fertig durchgelaufen ist –
   > bei „Connection refused" einfach kurz warten und neu laden.

---

## Schritt 5: Aufräumen

1. Zurück zu CloudFormation → Stack auswählen → **„Delete"**
2. Bestätigen – CloudFormation terminiert automatisch die Instanz UND löscht
   die Security Group, in der richtigen Reihenfolge (das müsstet ihr manuell
   selbst beachten: erst Instanz terminieren, dann Security Group löschen)

---

## Troubleshooting

| Problem | Lösung |
|---|---|
| **Parameter KeyPairName zeigt keine Auswahl** | Noch kein Key Pair vorhanden – erst Schritt 1 nachholen |
| **CREATE_FAILED: UnauthorizedOperation** | Account darf keine EC2-Instanzen erstellen – Trainer fragen |
| **Rollback wegen Ressourcen-Limit** | Ggf. laufen schon zu viele Instanzen im Account (Sandbox-Limit) – alte Instanzen aus vorherigen Übungen terminieren |
| **Website lädt nicht nach CREATE_COMPLETE** | UserData-Skript läuft noch – 30–60 Sekunden warten und neu laden |

---

## Zum Nachdenken

- Vergleich zur manuellen EC2-Übung (Folie 66a): Was musstet ihr dort per SSH
  eintippen, was hier automatisch im **UserData**-Block passiert?
- Was passiert, wenn ihr den Stack löscht und mit **geändertem** UserData-Skript
  neu erstellt? (Antwort: komplett neue, saubere Instanz – nichts "Handgestricktes"
  bleibt zurück, anders als bei manueller Konfiguration)
- Genau das ist der Kern von **Konsistenz & Wiederholbarkeit** aus Folie 95
