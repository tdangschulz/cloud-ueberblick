# Anleitung: S3-Website mit CloudFormation provisionieren

**Dauer:** ca. 10 Minuten
**Voraussetzung:** Zugang zur AWS-Konsole, Berechtigung für S3 & CloudFormation

---

## Worum geht's?

Statt Terraform (externes Tool) nutzen wir jetzt **CloudFormation** – AWS' eigenen
IaC-Dienst. Prinzip ist identisch: eine Textdatei (hier: YAML) beschreibt die
gewünschte Infrastruktur, AWS erstellt sie automatisch. Gleiches Ziel wie bei der
Terraform-Übung (S3-Bucket), diesmal aber komplett AWS-nativ, ohne Zusatz-Tool.

---

## Schritt 1: Template herunterladen

Datei `cloudformation-s3-website.yaml` bereitstellen (z. B. von euch als Trainer verteilt).

---

## Schritt 2: Stack erstellen

1. In der AWS-Konsole zu **CloudFormation** navigieren
2. Auf **„Create stack"** → **„With new resources (standard)"** klicken
3. Bei **„Template source"**: **„Upload a template file"** auswählen
4. Die Datei `cloudformation-s3-website.yaml` hochladen → **„Next"**

---

## Schritt 3: Stack konfigurieren

1. **Stack name** vergeben, z. B. `cats-website-<dein-name>`
2. Beim Parameter **„BucketName"** einen eindeutigen Namen eintragen,
   z. B. `cf-bucket-<dein-name>-2026` (S3-Namen sind weltweit eindeutig!)
3. Zweimal auf **„Next"** klicken, dann **„Submit"**

---

## Schritt 4: Warten & Ergebnis prüfen

1. CloudFormation zeigt den Status **„CREATE_IN_PROGRESS"** → nach ca. 1 Minute
   **„CREATE_COMPLETE"**
2. Tab **„Outputs"** öffnen → dort steht die fertige **WebsiteURL**

---

## Schritt 5: Inhalt hochladen

Das Template erstellt nur die **Infrastruktur** (Bucket + Konfiguration), nicht die
Website-Datei selbst. Jetzt noch eine `index.html` hochladen:

1. In der S3-Konsole den neu erstellten Bucket öffnen
2. **„Upload"** → eigene `index.html` hochladen (z. B. die Katzen-Galerie aus der
   vorherigen Übung)
3. Die WebsiteURL aus Schritt 4 erneut aufrufen → Seite ist jetzt live

---

## Schritt 6: Aufräumen

Im Gegensatz zu `terraform destroy` heißt der Befehl hier **„Delete"**:

1. Zurück zu CloudFormation → Stack auswählen
2. **„Delete"** klicken → bestätigen
3. CloudFormation löscht automatisch alle Ressourcen, die es erstellt hat
   (auch die Bucket Policy)

---

## Troubleshooting

| Problem | Lösung |
|---|---|
| **CREATE_FAILED: BucketAlreadyExists** | Bucket-Name ist bereits vergeben – anderen Namen wählen |
| **CREATE_FAILED: Access Denied** | Account hat keine Berechtigung für `cloudformation:CreateStack` oder `s3:CreateBucket` – Trainer fragen |
| **Stack bleibt bei ROLLBACK_COMPLETE hängen** | Stack löschen und mit neuem Bucket-Namen erneut versuchen |
| **Website zeigt 403 nach Upload** | Kurz warten (Policy-Propagierung dauert manchmal ein paar Sekunden) |

---

## Zum Nachdenken: Terraform vs. CloudFormation

| | Terraform | CloudFormation |
|---|---|---|
| Anbieter | Drittanbieter (HashiCorp) | AWS-nativ |
| Sprache | HCL | YAML/JSON |
| Multi-Cloud-fähig | Ja (auch Azure, GCP …) | Nein (nur AWS) |
| Installation nötig | Ja | Nein (in AWS-Konsole integriert) |
| Rückgängig machen | `terraform destroy` | Stack „Delete" |

**Diskussionsfrage an die Gruppe:** Warum könnte ein Unternehmen trotzdem Terraform
statt CloudFormation wählen, obwohl CloudFormation "kostenlos mitgeliefert" wird?
(Stichwort: Multi-Cloud-Strategie, Folie 31–32)
