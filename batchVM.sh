# Prep
yum install nano
DEVSHELL_PROJECT_ID="qwiklabs-gcp-ml-0bc583e3798d" # Insert project ID


# Mount Filestore at /mnt/filestore #
mkdir /mnt/filestore
gcloud filestore instances describe batch-filestore \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=us-central1-a > fstore.txt
FILESTORE_IP=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$' fstore.txt)
mount --source $FILESTORE_IP:/fsname --target /mnt/filestore

# Install batch on GKE, Ksub, and create cluster
./install.sh

# Add the default values for projectID, clusterName, and, if you are not operating in the default namespace, namespace in .ksubrc:
# After running ./ksub --config --create-default.
# nano ~/.ksubrc

