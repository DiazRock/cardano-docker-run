source ./.env
gcloud container clusters create $CLUSTER_NAME \
  --disk-size=32GB \
  --machine-type=e2-medium \
  --node-locations=$CLUSTER_ZONE \
  --zone=$CLUSTER_ZONE \
  --num-nodes=3
