# PrivateBin-SSL-Docker

Deploy PrivateBin with self-signed SSL with ease.

## Prerequisites
- Git
- Docker

## Instructions

### First time
- Clone this repository
- Modify the variables `NEW_DOMAIN` and `NEW_EMAIL` in `run.sh`.
- Execute `run.sh`.
- Done!

### What if my certificate expires?
Don't worry, `ssl_keygen.sh` will check if your certificate is valid. If not, it'll generate a new one. (Thus, you'll have to complete the previous step again).
Certificates are valid for 90 days.

### Tips
Don't forget to configure your domain to redirect to the IP of your device.
