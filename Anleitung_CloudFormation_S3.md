# Anleitung: S3-Website mit CloudFormation erstellen

**Dauer:** ca. 10 Minuten
**Voraussetzung:** Zugang zur AWS-Konsole, Berechtigung für S3 & CloudFormation

---

## Worum geht's?

Statt Terraform (einem externen Tool) nutzen wir jetzt **CloudFormation**
– den hauseigenen Dienst von AWS, um Infrastruktur automatisch zu
erstellen. Das Prinzip ist gleich: Eine Textdatei (hier im YAML-Format)
beschreibt, welche Infrastruktur entstehen soll, und AWS baut sie
automatisch. Gleiches Ziel wie bei der Terraform-Übung (ein S3-Bucket
als Website), diesmal aber komplett AWS-intern, ohne zusätzliches Tool.

---

## Schritt 1: Template herunterladen

Datei `cloudformation-s3-website.yaml` bereitstellen (z. B. von euch
als Trainer verteilt).

---

## Schritt 2: Stack erstellen

Ein **Stack** ist die Gruppe aller Ressourcen, die aus einem Template
entstehen.

1. In der AWS-Konsole zu **CloudFormation** navigieren
2. Auf **„Create stack"** → **„With new resources (standard)"** klicken
3. Bei **„Template source"**: **„Upload a template file"** auswählen
4. Die Datei `cloudformation-s3-website.yaml` hochladen → **„Next"**

---

## Schritt 3: Stack konfigurieren

1. **Stack name** vergeben, z. B. `cats-website-<dein-name>`
2. Beim Parameter **„BucketName"** einen eindeutigen Namen eintragen,
   z. B. `cf-bucket-<dein-name>-2026` (S3-Bucket-Namen müssen weltweit
   einmalig sein!)
3. Zweimal auf **„Next"** klicken, dann **„Submit"**

---

## Schritt 4: Warten & Ergebnis prüfen

1. CloudFormation zeigt zuerst **„CREATE_IN_PROGRESS"** (wird gerade
   erstellt), nach ca. 1 Minute dann **„CREATE_COMPLETE"** (fertig)
2. Tab **„Outputs"** öffnen → dort steht die fertige **WebsiteURL**

---

## Schritt 5: Inhalt hochladen

Das Template erstellt nur die **Infrastruktur** (den Bucket und seine
Einstellungen), aber noch keine Website-Datei. Jetzt noch eine
`index.html` hochladen:

1. In der S3-Konsole den neu erstellten Bucket öffnen
2. **„Upload"** → eigene `index.html` hochladen (z. B. die
   Katzen-Galerie aus der vorherigen Übung)
3. Die WebsiteURL aus Schritt 4 erneut aufrufen → die Seite ist jetzt
   live

---

## Schritt 6: Aufräumen

Bei Terraform heißt der Befehl `terraform destroy`, in der
CloudFormation-Konsole heißt der Button einfach **„Delete"**:

1. Zurück zu CloudFormation → Stack auswählen
2. **„Delete"** klicken → bestätigen
3. CloudFormation löscht automatisch alle Ressourcen, die es erstellt
   hat (auch die Bucket Policy, also die Zugriffsregeln)

---

## Troubleshooting

| Problem | Lösung |
|---|---|
| **CREATE_FAILED: BucketAlreadyExists** | Der Bucket-Name ist schon vergeben – einen anderen wählen |
| **CREATE_FAILED: Access Denied** | Der Account hat keine Berechtigung, einen Stack oder Bucket zu erstellen – Trainer fragen |
| **Stack bleibt bei ROLLBACK_COMPLETE hängen** | Stack löschen und mit einem neuen Bucket-Namen erneut versuchen |
| **Website zeigt 403 (Zugriff verweigert) nach Upload** | Kurz warten – die Zugriffsregeln brauchen manchmal ein paar Sekunden, bis sie wirksam werden |

---

## Zum Nachdenken: Terraform vs. CloudFormation

| | Terraform | CloudFormation |
|---|---|---|
| Anbieter | Drittanbieter (HashiCorp) | Von AWS selbst |
| Sprache | HCL | YAML/JSON |
| Funktioniert mit mehreren Cloud-Anbietern | Ja (auch Azure, GCP …) | Nein (nur AWS) |
| Installation nötig | Ja | Nein (schon in der AWS-Konsole enthalten) |
| Rückgängig machen | Befehl `terraform destroy` | Button „Delete" |

**Diskussionsfrage an die Gruppe:** Warum könnte ein Unternehmen
trotzdem Terraform statt CloudFormation nutzen, obwohl CloudFormation
kostenlos dabei ist? (Stichwort: mit mehreren Cloud-Anbietern
gleichzeitig arbeiten, Folie 31–32)
