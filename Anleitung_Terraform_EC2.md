# Anleitung: EC2-Webserver mit Terraform provisionieren

**Dauer:** ca. 10 Minuten
**Voraussetzung:** AWS-Zugangsdaten (Access Key/Secret oder SSO), Terraform installiert (`terraform -version`)

---

## Worum geht's?

Gleiches Ergebnis wie bei `cloudformation-ec2-webserver.yaml`, nur mit
einem anderen IaC-Tool: Terraform beschreibt EC2-Instanz, Security Group
und Webserver-Installation (**user_data**) deklarativ in `.tf`-Dateien
im Ordner `terraform-ec2-demo/`.

Guter Vergleichspunkt zur CloudFormation-Übung: **gleiches Konzept
(deklarativ, wiederholbar, versionierbar), anderes Tool** – und
Terraform funktioniert genauso mit Azure, GCP, etc., nicht nur AWS.

---

## Schritt 1: AWS-Zugangsdaten bereitstellen

Terraform braucht Zugriff auf AWS – z. B. über die AWS CLI:

```bash
aws configure
```

(Access Key, Secret Key, Region eingeben – oder `AWS_ACCESS_KEY_ID` /
`AWS_SECRET_ACCESS_KEY` als Umgebungsvariablen setzen.)

---

## Schritt 2: Key Pair sicherstellen

Für SSH-Zugriff wird ein vorhandenes Key Pair benötigt (dasselbe wie
bei der CloudFormation-Übung, falls schon vorhanden):

1. In der EC2-Konsole unter **„Key Pairs"** prüfen
2. Falls nicht vorhanden: **„Create key pair"** → Namen merken

---

## Schritt 3: Terraform initialisieren

```bash
cd terraform-ec2-demo
terraform init
```

Lädt den AWS-Provider herunter (entspricht in etwa dem "Hochladen des
Templates" bei CloudFormation – nur einmal pro Ordner nötig).

---

## Schritt 4: Plan ansehen

```bash
terraform plan -var="key_name=<dein-key-pair-name>"
```

Zeigt genau, WAS erstellt werden würde, OHNE es wirklich zu tun –
guter Diskussionspunkt: CloudFormation hat mit "Change Sets" ein
ähnliches Konzept, ist aber bei Terraform Standard-Workflow.

---

## Schritt 5: Anwenden

```bash
terraform apply -var="key_name=<dein-key-pair-name>"
```

Mit `yes` bestätigen. Dauert ca. 1–2 Minuten, bis die Instanz läuft.

Am Ende gibt Terraform die **Outputs** aus (`public_ip`, `website_url`).
Falls sie später nochmal gebraucht werden:

```bash
terraform output
```

---

## Schritt 6: Ergebnis prüfen

`website_url` aus den Outputs im Browser öffnen.

> Hinweis: Der Webserver braucht nach "Apply complete" noch ein paar
> Sekunden zusätzlich, bis das user_data-Skript fertig durchgelaufen
> ist – bei "Connection refused" kurz warten und neu laden.

---

## Schritt 7: Aufräumen

```bash
terraform destroy -var="key_name=<dein-key-pair-name>"
```

Mit `yes` bestätigen – Terraform löscht Instanz UND Security Group in
der richtigen Reihenfolge (genau wie CloudFormation das automatisch
macht).

---

## Troubleshooting

| Problem | Lösung |
|---|---|
| **Error: No valid credential sources found** | `aws configure` noch nicht ausgeführt bzw. Zugangsdaten abgelaufen |
| **InvalidKeyPair.NotFound** | `key_name` falsch geschrieben oder Key Pair existiert nicht in der gewählten Region |
| **Error: creating EC2 Instance ... UnauthorizedOperation** | Account darf keine EC2-Instanzen erstellen – Trainer fragen |
| **terraform.tfstate lokal "verloren"** | Ohne Remote-Backend liegt der State nur lokal – bei Teamarbeit unbedingt S3+DynamoDB-Backend nutzen |

---

## Zum Nachdenken

- Vergleich zu `cloudformation-ec2-webserver.yaml`: Gleiche Ressourcen,
  gleiches `user_data`-Skript – was ist an der Terraform-Syntax anders,
  was ist gleich geblieben?
- Terraform speichert den aktuellen Zustand in `terraform.tfstate`.
  Was passiert, wenn diese Datei gelöscht wird, die Instanz aber
  weiterläuft? (Antwort: Terraform "vergisst" die Ressource und würde
  bei erneutem `apply` versuchen, eine zweite zu erstellen – guter
  Grund für Remote-State im Team)
- Terraform ist Cloud-agnostisch, CloudFormation nicht. Wann würde man
  trotzdem CloudFormation bevorzugen? (Antwort: reine AWS-Umgebung,
  keine externe Abhängigkeit, native Integration mit anderen AWS-Diensten)
