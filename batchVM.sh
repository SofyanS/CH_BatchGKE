# Prep
sudo su
yes | yum install nano
git clone https://github.com/SofyanS/CH_BatchGKE.git
DEVSHELL_PROJECT_ID="qwiklabs-gcp-01-a9b5651062a2" # Insert project ID
EMAIL="student-01-dd4c729d720b@qwiklabs.netstudent-01-dd4c729d720b@qwiklabs.net" # Insert Email

# Mount Filestore at /mnt/filestore #
mkdir /mnt/filestore
gcloud filestore instances describe batch-filestore \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=us-central1-a > fstore.txt
FILESTORE_IP=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$' fstore.txt)
mount --source $FILESTORE_IP:/fsname --target /mnt/filestore

# Install batch on GKE, Ksub, and create cluster
sed -i "s~REPLACE_PROJECTID~$DEVSHELL_PROJECT_ID~g" install.sh
sed -i "s~REPLACE_EMAIL~$DEVSHELL_PROJECT_ID~g" install.sh
./install.sh
git clone https://github.com/GoogleCloudPlatform/Kbatch.git

# Add the default values for projectID, clusterName, and, if you are not operating in the default namespace, namespace in .ksubrc:
# After running ./ksub --config --create-default.
# nano ~/.ksubrc

