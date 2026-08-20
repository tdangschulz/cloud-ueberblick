# Anleitung: Elastic Beanstalk mit Terraform erstellen

**Dauer:** ca. 10–15 Minuten
**Voraussetzung:** AWS-Zugangsdaten konfiguriert (siehe `Anleitung_Terraform_EC2.md`, Schritt 1–2)

---

## Worum geht's?

Bringt das Docker-Image aus `Dockerrun.aws.json`
(`ghcr.io/tdangschulz/meine-pipeline-app:main`) automatisch online –
über **Elastic Beanstalk**, den gleichen Dienst wie bei der
"Container-of-Cats"-Übung (`container-of-cats-beanstalk.zip`), nur
diesmal per Terraform statt manuell über die Konsole hochgeladen.

Elastic Beanstalk kümmert sich im Hintergrund automatisch um: die
EC2-Instanz, Sicherheitsregeln, Gesundheitschecks (ob die App noch
läuft) und das Ausrollen neuer Versionen. Guter Vergleichspunkt zu den
EC2-Übungen: eine Ebene bequemer, als eine EC2-Instanz komplett selbst
zu verwalten.

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

Zeigt, was erstellt wird: ein S3-Bucket, Berechtigungen (IAM-Rollen),
sowie die Beanstalk-Anwendung, -Version und -Umgebung – alles mit
sinnvollen Standardwerten, ihr müsst nichts extra angeben (anders als
bei der EC2-Übung, wo ihr den Key-Pair-Namen angeben müsst).

---

## Schritt 3: Anwenden

```bash
terraform apply
```

Mit `yes` bestätigen. **Dauert deutlich länger als die reine
EC2-Übung – ca. 5–10 Minuten**, weil Beanstalk im Hintergrund eine
komplette Umgebung aufbaut (Instanz, Überwachung, …).

Am Ende zeigt Terraform `environment_url` an.

---

## Schritt 4: Ergebnis prüfen

`environment_url` aus den Outputs im Browser öffnen.

> Hinweis: Auch nach "Apply complete" kann es noch 1–2 Minuten dauern,
> bis der Container tatsächlich läuft und alles grün ist – bei einer
> Fehlermeldung also kurz warten und neu laden.

Der Status lässt sich auch jederzeit in der AWS-Konsole unter
**Elastic Beanstalk → Environments** ansehen (zeigt eine Ampel:
grün = läuft gut, gelb = Warnung, rot = Problem).

---

## Schritt 5: Aufräumen

```bash
terraform destroy
```

Mit `yes` bestätigen – löscht Umgebung, Anwendung, Berechtigungen und
den S3-Bucket in der richtigen Reihenfolge.

---

## Troubleshooting

| Problem | Lösung |
|---|---|
| **No valid credential sources found** | Siehe `Anleitung_Terraform_EC2.md` – Zugangsdaten ggf. erneuern |
| **InvalidParameterValue: Unable to find solution stack** | Die automatisch gesuchte Docker-Plattform wurde in der Region nicht gefunden – Region wechseln oder Trainer fragen |
| **Umgebungsstatus bleibt "Severe" / "Red" (rot)** | Meist zieht der Container das Image nicht erfolgreich – Image-Name in `Dockerrun.aws.json` prüfen, oder in der Beanstalk-Konsole unter "Logs" nachschauen |
| **terraform destroy hängt beim S3-Bucket** | Der Bucket ist nicht leer (alte App-Versionen liegen noch drin) – bei Problemen das Objekt manuell in der S3-Konsole löschen und destroy erneut ausführen |

---

## Zum Nachdenken

- Vergleich zu `terraform-ec2-demo`: Dort baut ihr Instanz und
  Webserver komplett selbst; hier übernimmt Beanstalk das
  "Drumherum" automatisch (Lastverteilung, Gesundheitschecks,
  Ausroll-Strategie). Wann lohnt sich der Mehraufwand einer "nackten"
  EC2-Instanz trotzdem?
- Jede neue Anwendungsversion bekommt einen eigenen Namen, abhängig
  vom Datei-Inhalt. Was passiert, wenn ihr `Dockerrun.aws.json`
  ändert und `terraform apply` erneut ausführt? (Antwort: es entsteht
  automatisch eine neue Version, die ausgerollt wird – die alte
  Version bleibt in der Historie erhalten, ähnlich wie bei
  Docker-Image-Tags)
