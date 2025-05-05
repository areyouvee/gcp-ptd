import datetime
from googleapiclient import discovery
from google.auth import default

def cleanup_services(request):
    credentials, project = default()
    run = discovery.build("run", "v1", credentials=credentials)

    region = "us-central1"
    parent = f"projects/{project}/locations/{region}"
    cutoff = (datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=7)).strftime('%Y%m%d')

    services = run.projects().locations().services().list(parent=parent).execute()

    for svc in services.get("items", []):
        name = svc["metadata"]["name"]
        labels = svc["metadata"].get("labels", {})
        created_at = labels.get("created_at", "")
        
        if name.startswith("sandbox-") and created_at < cutoff:
            print(f"Deleting {name} (created_at={created_at})")
            run.projects().locations().services().delete(name=f"{parent}/services/{name}").execute()
        else:
            print(f"Skipping {name} (created_at={created_at})")

    return "Cleanup complete"
