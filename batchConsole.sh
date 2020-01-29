# Create a GCS bucket
gsutil mb -l us-central1  gs://$DEVSHELL_PROJECT_ID-bucket

# Create a filestore instance'
# yes to pipe enable file.googleapis.com
yes | gcloud filestore instances create batch-filestore \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=us-central1-a \
    --tier=STANDARD \
    --file-share=name="fsname",capacity=1TB \
    --network=name=default