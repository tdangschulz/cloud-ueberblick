# Anleitung: Elastic Beanstalk mit Terraform provisionieren

**Dauer:** ca. 10–15 Minuten
**Voraussetzung:** AWS-Zugangsdaten konfiguriert (siehe `Anleitung_Terraform_EC2.md`, Schritt 1–2)

---

## Worum geht's?

Deployt das bestehende Docker-Image aus `Dockerrun.aws.json`
(`ghcr.io/tdangschulz/meine-pipeline-app:main`) auf **Elastic Beanstalk** –
das "Container-of-Cats"-Beispiel aus `container-of-cats-beanstalk.zip`,
nur automatisiert per Terraform statt manuell über die Konsole hochgeladen.

Elastic Beanstalk übernimmt im Hintergrund automatisch: EC2-Instanz,
Sicherheitsgruppen, Health-Checks, Rolling-Deployments bei neuen Versionen –
guter Vergleichspunkt zu den EC2-Übungen: **eine Ebene höher als
"nackte" EC2-Instanzen selbst verwalten.**

---

## Schritt 1: Terraform initialisieren

```bash
cd terraform-beanstalk-demo
terraform init
```

---

## Schritt 2: Plan ansehen

```bash
terraform plan
```

Zeigt: S3-Bucket, IAM-Rollen, Beanstalk-Application, -Version und
-Environment – alles mit sinnvollen Defaults, keine Parameter nötig
(anders als bei der EC2-Übung, wo `key_name` Pflicht ist).

---

## Schritt 3: Anwenden

```bash
terraform apply
```

Mit `yes` bestätigen. **Dauert deutlich länger als die reine
EC2-Übung – ca. 5–10 Minuten**, da Beanstalk im Hintergrund eine
komplette Umgebung (Instanz, Health-Monitoring, ...) aufbaut.

Am Ende gibt Terraform `environment_url` aus.

---

## Schritt 4: Ergebnis prüfen

`environment_url` aus den Outputs im Browser öffnen.

> Hinweis: Auch nach "Apply complete" kann es noch 1–2 Minuten dauern,
> bis der Container tatsächlich hochgefahren und die Health-Checks grün
> sind – bei Fehlermeldung kurz warten und neu laden.

Status jederzeit auch in der AWS-Konsole unter **Elastic Beanstalk →
Environments** einsehbar (zeigt Health-Ampel: grün/gelb/rot).

---

## Schritt 5: Aufräumen

```bash
terraform destroy
```

Mit `yes` bestätigen – löscht Environment, Application, IAM-Rollen und
den S3-Bucket in der richtigen Reihenfolge.

---

## Troubleshooting

| Problem | Lösung |
|---|---|
| **No valid credential sources found** | Siehe `Anleitung_Terraform_EC2.md` – Session ggf. via `eval "$(aws configure export-credentials --format env)"` erneuern |
| **InvalidParameterValue: Unable to find solution stack** | Die automatisch gesuchte Docker-Plattform ("64bit Amazon Linux 2023 ... running Docker") wurde in der Region nicht gefunden – Region wechseln oder `name_regex` in `main.tf` anpassen |
| **Environment-Status bleibt "Severe" / "Red"** | Meist zieht der Container das Image aus GHCR nicht – Image-Name in `Dockerrun.aws.json` prüfen, oder in der Beanstalk-Konsole unter "Logs" nachschauen |
| **terraform destroy hängt beim S3-Bucket** | Bucket ist nicht leer (alte App-Versionen) – Terraform löscht das Objekt selbst mit, bei Problemen Objekt manuell in der S3-Konsole löschen und destroy erneut ausführen |

---

## Zum Nachdenken

- Vergleich zu `terraform-ec2-demo`: Dort baut ihr die Instanz + Webserver
  komplett selbst; hier übernimmt Beanstalk das "Drumherum" (Load-Balancing,
  Health-Checks, Deployment-Strategie) automatisch. Wann lohnt sich der
  Mehraufwand von "nackten" EC2-Instanzen trotzdem?
- `aws_elastic_beanstalk_application_version` bekommt einen Namen, der vom
  Datei-Hash abhängt (`v-${etag}`). Was passiert, wenn ihr `Dockerrun.aws.json`
  ändert und erneut `terraform apply` ausführt? (Antwort: neue Version wird
  erstellt und automatisch als Rolling-Deployment ausgerollt – alte Version
  bleibt in der Historie erhalten, guter Vergleich zu Docker-Image-Tags)
