#!/bin/bash

# Set the new values
NEW_DOMAIN="mydomain.com or my.domain.com" 
NEW_EMAIL="joe@doe.com"                         # Used by Certbot
IMAGE_NAME="privatebin_withssl:latest"          # Docker image name
CONTAINER_NAME="privatebin_withssl-container"   # Container name

# Path to the ssl_keygen.sh script
SSL_KEYGEN_SCRIPT_PATH="./etc/scripts/ssl_keygen.sh"

# Modify the ssl_keygen.sh script with the new values
sed -i "s/^DOMAIN_NAME=.*/DOMAIN_NAME=\"$NEW_DOMAIN\"/" $SSL_KEYGEN_SCRIPT_PATH
sed -i "s/^USER_MAIL=.*/USER_MAIL=\"$NEW_EMAIL\"/" $SSL_KEYGEN_SCRIPT_PATH

echo "Starting deployment of PrivateBin with SSL..."

# Replace the domain name in Nginx configuration files
echo "Updating the domain name in Nginx configuration files..."
sed -i "s/domain.com/$NEW_DOMAIN/g" nginx.conf
sed -i "s/domain.com/$NEW_DOMAIN/g" nginx.conf.new

# Build the Docker image
echo "Building Docker image $IMAGE_NAME..."
echo "Building Docker image $IMAGE_NAME..."
sudo docker build \
  --build-arg DOMAIN_NAME=$NEW_DOMAIN \
  --build-arg USER_EMAIL=$NEW_EMAIL \
  -t $IMAGE_NAME .

# Remove the existing container if it exists
echo "Removing existing container $CONTAINER_NAME (if exists)..."
sudo docker container rm -f $CONTAINER_NAME

# Launch the new container
echo "Launching the new container $CONTAINER_NAME..."
sudo docker run -d --name $CONTAINER_NAME -p 443:443 -p 80:80 $IMAGE_NAME

echo "PrivateBin deployment completed successfully."
