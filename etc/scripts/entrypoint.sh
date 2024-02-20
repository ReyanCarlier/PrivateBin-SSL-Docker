#!/bin/sh

echo "Launching the supervisor..."
/usr/bin/supervisord -c /etc/supervisord.conf
echo "Supervisor launched!"
