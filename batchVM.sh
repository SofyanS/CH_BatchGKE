# Prep
yes | sudo yum install nano
git clone https://github.com/SofyanS/CH_BatchGKE.git
cd CH_BatchGKE
git clone https://github.com/GoogleCloudPlatform/Kbatch.git
DEVSHELL_PROJECT_ID="qwiklabs-gcp-01-631fc4d51611" # Insert project ID
EMAIL="student-01-2df1fbf06758@qwiklabs.net" # Insert Email

# Install batch on GKE, Ksub, and create cluster
sed -i "s~REPLACE_PROJECTID~$DEVSHELL_PROJECT_ID~g" install.sh
sed -i "s~REPLACE_EMAIL~$DEVSHELL_PROJECT_ID~g" install.sh

# Manually run for now
./install.sh

# Set namespace to kube-system for debugging
kubectl config set-context --current --namespace=kube-system

# Enable ksub to use your user credentials for API Access
gcloud auth application-default login

# Initialize Ksub
cd Kbatch-tar
./ksub --config --create-default

# Add the default values for projectID, clusterName, namespace
# namespace is $DEVSHELL_PROJECT_ID.svc.id.goog OR kube-system
nano ~/.ksubrc # Later I can just sed this file once I see what it generates
export PATH=$PATH:/home/student-01-952135633b74/CH_BatchGKE/Kbatch-tar



# Mount Filestore at /mnt/filestore #
sudo mkdir /mnt/filestore
gcloud filestore instances describe batch-filestore \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=us-central1-a > fstore.txt
FILESTORE_IP=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$' fstore.txt)
sudo mount --source $FILESTORE_IP:/fsname --target /mnt/filestore

# set up mount points
./ksub --config --add-volume fs-volume --volume-source PersistentVolumeClaim --params claimName:standard --params readOnly:false

# Generate image
sudo touch /mnt/filestore/cloud.png # Just do this

cd ../Kbatch
./samples/defaultresources/create.sh

cd samples/imageprocess
./apply-extra-config.sh


