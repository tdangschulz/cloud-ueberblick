import json
import boto3
import urllib.parse

s3 = boto3.client('s3')

def lambda_handler(event, context):
    """
    Wird automatisch von S3 aufgerufen, sobald eine neue Datei
    im Bucket unter dem Präfix 'uploads/' hochgeladen wird.

    Das 'event' enthält Details zum auslösenden S3-Ereignis —
    unter anderem Bucket-Namen und Objekt-Key.
    """

    # Bucket- und Dateiname aus dem S3-Event auslesen
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(
        event['Records'][0]['s3']['object']['key'], encoding='utf-8'
    )

    print(f"Neue Datei erkannt: s3://{bucket}/{key}")

    # Inhalt der hochgeladenen Datei lesen
    response = s3.get_object(Bucket=bucket, Key=key)
    original_content = response['Body'].read().decode('utf-8')

    # Einfache "Verarbeitung": Text in Großbuchstaben umwandeln
    # und eine Zeile mit Metadaten ergänzen
    processed_content = (
        f"=== Automatisch verarbeitet durch Lambda ===\n"
        f"Ursprüngliche Datei: {key}\n"
        f"Ausgelöst durch: S3-Event (Object Created)\n"
        f"---\n"
        f"{original_content.upper()}\n"
    )

    # Neue Datei im Präfix 'processed/' ablegen
    # WICHTIG: bewusst ein ANDERES Präfix als der Trigger ('uploads/'),
    # sonst würde die neue Datei den Trigger erneut auslösen -> Endlosschleife!
    new_key = key.replace('uploads/', 'processed/')

    s3.put_object(
        Bucket=bucket,
        Key=new_key,
        Body=processed_content.encode('utf-8')
    )

    print(f"Verarbeitete Datei gespeichert: s3://{bucket}/{new_key}")

    return {
        'statusCode': 200,
        'body': json.dumps(f'Datei {key} erfolgreich verarbeitet.')
    }
