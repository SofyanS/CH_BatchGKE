# (https://cloud.google.com/kubernetes-engine/docs/how-to/batch/managing-clusters)
# Create install script for Batch on GKE  (./install.sh)
######################################################################################
DEVSHELL_PROJECT_ID="REPLACE_PROJECTID" # Insert project ID. Sed it on the program script
EMAIL="REPLACE_EMAIL" # Insert email. Sed it on the main program script

gcloud auth login

# Create regional cluster with workload identitiy enabled
gcloud beta container clusters create hello-batch \
  --region us-central1 \
  --node-locations us-central1-a \
  --num-nodes 1 \
  --machine-type n1-standard-8 \
  --release-channel regular \
  --enable-stackdriver-kubernetes \
  --identity-namespace=$DEVSHELL_PROJECT_ID.svc.id.goog \
  --enable-ip-alias

# Configure IAM
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member user:$EMAIL --role=roles/owner

gcloud iam roles create BatchUser --project $DEVSHELL_PROJECT_ID \
--title GKEClusterReader --permissions container.clusters.get --stage BETA 2>&1

kubectl create clusterrolebinding cluster-admin-binding-$EMAIL \
--clusterrole=cluster-admin --user $EMAIL

gcloud iam service-accounts create kbatch-controllers-gcloud-sa --display-name \
kbatch-controllers-gcloud-service-account

kubectl create serviceaccount --namespace kube-system kbatch-controllers-k8s-sa

# Add the following IAM policy bindings:
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member serviceAccount:kbatch-controllers-gcloud-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
--role=roles/container.clusterAdmin

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member serviceAccount:kbatch-controllers-gcloud-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
--role=roles/compute.admin

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member serviceAccount:kbatch-controllers-gcloud-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
--role=roles/iam.serviceAccountUser

gcloud iam service-accounts add-iam-policy-binding \
--role roles/iam.workloadIdentityUser \
--member "serviceAccount:$DEVSHELL_PROJECT_ID.svc.id.goog[kube-system/kbatch-controllers-k8s-sa]" kbatch-controllers-gcloud-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com

kubectl annotate serviceaccount --namespace kube-system kbatch-controllers-k8s-sa \
 iam.gke.io/gcp-service-account=kbatch-controllers-gcloud-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com

###########################
# Install Kbatch and ksub #
###########################
cd Kbatch-tar
sed -i "s~<kbatch-project-id>~$DEVSHELL_PROJECT_ID~g" config/kbatch-config.yaml
kubectl create configmap --from-file config/kbatch-config.yaml -n kube-system kbatch-config
gcloud compute machine-types list --filter="zone:us-central1-a" --format json > ./machine_types.json
kubectl create configmap --from-file machine_types.json -n kube-system kbatch-machine-types

# Install batch custom resource definitions
kubectl apply -f install/01-crds.yaml
kubectl apply -f install/02-admission.yaml
kubectl apply -f install/03-controller.yaml