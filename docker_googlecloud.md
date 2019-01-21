# Setting Up Docker on Google Cloud
- **Only** use google's container optimized OS whih ships with docer and some other bits and pieces
- Container settings are stored in instance metadata ```gce-container-declaration```
- Once booted, instance pulls container image from the repo (eg dockerhub) and runs it using ```docker run <config>``` using config in metadata
- Googles Cloud Build can be used to do the building

### Pushing container to google cloud registry
``` bash
# Tag the image
docker tag [local_image_name] eu.gcr.io/ndn-thesis/[remote_image_name(can be same as local)]

# Note docker image ls will show tag with full name (including repo location etc)
# Just use the image_name (eg the local_image_name above)
docker push eu.gcr.io/ndn-thesis/[IMAGE_NAME]

# Check it arrived
gcloud container images list-tags eu.gcr.io/ndn-thesis/[IMAGE_NAME]
```

### Pulling images from container
# Tab completion is your friend here..
```bash
docker pull eu.gcr.io/ndn-thesis/[IMAGE]:[TAG (or omit for latest)]
```
### Creating the container instance template

```bash
# Create an actual instance template that will use the container
gcloud compute instance-templates create-with-container [NEW_TEMPLATE_NAME] --container-image eu.gcr.io/ndn-thesis/[CONTAINER_NAME]
```

### Create instance from template
```bash
gcloud compute instances create [INSTANCE_NAME] --source-instance-template [TEMPLATE_NAME]
```

### Create an instance using a container
- Note: I'm not sure what hardware gets used here?
```bash
gcloud compute instances create-with-container [INSTANCE_NAME] --container-image [DOCKER_IMAGE]```
```

### Update the container a particular instance is running
```bash
gcloud compute instances update-container [INSTANCE_NAME] --container-image [DOCKER_IMAGE]```
```

# Kubernetes
- Allows multiple containers to be deployed on each VM instance