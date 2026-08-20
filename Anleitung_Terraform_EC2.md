# Anleitung: EC2-Webserver mit Terraform erstellen

**Dauer:** ca. 10 Minuten
**Voraussetzung:** AWS-Zugangsdaten (Access Key/Secret oder SSO),
Terraform installiert (mit `terraform -version` prüfbar)

---

## Worum geht's?

Gleiches Ergebnis wie bei `cloudformation-ec2-webserver.yaml`, nur mit
einem anderen Werkzeug: Terraform beschreibt EC2-Instanz, Security
Group und die Webserver-Installation (**user_data**) in `.tf`-Dateien
im Ordner `terraform-ec2-demo/`.

Guter Vergleichspunkt zur CloudFormation-Übung: gleiches Prinzip
(alles wird in einer Datei beschrieben und automatisch erstellt),
nur ein anderes Werkzeug – und Terraform funktioniert genauso mit
Azure, GCP usw., nicht nur mit AWS.

---

## Schritt 1: AWS-Zugangsdaten bereitstellen

Terraform braucht Zugriff auf euren AWS-Account, z. B. über die AWS CLI:

```bash
aws configure
```

(Fragt nach Access Key, Secret Key und Region – alternativ könnt ihr
`AWS_ACCESS_KEY_ID` und `AWS_SECRET_ACCESS_KEY` als
Umgebungsvariablen setzen.)

---

## Schritt 2: Key Pair sicherstellen

Für den späteren Fernzugriff per SSH braucht ihr ein vorhandenes Key
Pair (dasselbe wie bei der CloudFormation-Übung, falls schon vorhanden):

1. In der EC2-Konsole unter **„Key Pairs"** prüfen
2. Falls keins vorhanden ist: **„Create key pair"** → Namen merken

---

## Schritt 3: Terraform initialisieren

```bash
cd terraform-ec2-demo
terraform init
```

Lädt das nötige AWS-Plugin herunter (vergleichbar mit dem Hochladen
des Templates bei CloudFormation – nur einmal pro Ordner nötig).

---

## Schritt 4: Plan ansehen

```bash
terraform plan -var="key_name=<dein-key-pair-name>"
```

Zeigt genau, WAS erstellt werden würde, OHNE es wirklich zu tun – so
könnt ihr vorher prüfen, ob alles stimmt.

---

## Schritt 5: Anwenden

```bash
terraform apply -var="key_name=<dein-key-pair-name>"
```

Mit `yes` bestätigen. Dauert ca. 1–2 Minuten, bis die Instanz läuft.

Am Ende zeigt Terraform die **Outputs** an (`public_ip`,
`website_url`). Falls ihr sie später nochmal braucht:

```bash
terraform output
```

---

## Schritt 6: Ergebnis prüfen

`website_url` aus den Outputs im Browser öffnen.

> Hinweis: Der Webserver braucht nach "Apply complete" noch ein paar
> Sekunden zusätzlich, bis das Startskript fertig durchgelaufen ist.
> Bei „Connection refused" also kurz warten und neu laden.

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
| **Error: No valid credential sources found** | `aws configure` wurde noch nicht ausgeführt, oder die Zugangsdaten sind abgelaufen |
| **InvalidKeyPair.NotFound** | `key_name` falsch geschrieben, oder das Key Pair existiert nicht in der gewählten Region |
| **Error: creating EC2 Instance ... UnauthorizedOperation** | Der Account darf keine EC2-Instanzen erstellen – Trainer fragen |
| **terraform.tfstate lokal "verloren"** | Die Terraform-Statusdatei liegt nur lokal auf eurem Rechner – bei Teamarbeit besser einen zentralen Speicherort nutzen |

---

## Zum Nachdenken

- Vergleich zu `cloudformation-ec2-webserver.yaml`: Gleiche
  Ressourcen, gleiches Startskript – was ist an der Terraform-Syntax
  anders, was ist gleich geblieben?
- Terraform speichert den aktuellen Zustand in einer Datei namens
  `terraform.tfstate`. Was passiert, wenn diese Datei gelöscht wird,
  die Instanz aber weiterläuft? (Antwort: Terraform "vergisst" die
  Ressource und würde beim nächsten `apply` versuchen, eine zweite zu
  erstellen – ein guter Grund, den Zustand im Team zentral zu
  speichern)
- Terraform funktioniert mit mehreren Cloud-Anbietern,
  CloudFormation nur mit AWS. Wann würde man trotzdem CloudFormation
  bevorzugen? (Antwort: wenn man nur AWS nutzt und keine zusätzliche
  Abhängigkeit von einem externen Tool möchte)
