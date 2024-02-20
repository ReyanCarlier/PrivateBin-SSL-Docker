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

### After generating an SSL certificate
After the first launch, if everything went well (which it must), you'll need to get the content of these files:
- `/etc/letsencrypt/live/<yourdomain.name>/fullchain.pem`
- `/etc/letsencrypt/live/<yourdomain.name>/privkey.pem`
And copy your certificate values into the files stored in `/etc/ssl/` in this repository.

### What if my certificate expires?
Don't worry, `ssl_keygen.sh` will check if your certificate is valid. If not, it'll generate a new one. (Thus, you'll have to complete the previous step again).
Certificates are valid for 90 days.

### Tips
Don't forget to configure your domain to redirect to the IP of your device.
