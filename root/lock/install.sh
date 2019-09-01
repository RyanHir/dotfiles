#!/bin/sh

sudo cp config /etc/systemd/system/lock@.service
sudo systemctl daemon-reload
sudo systemctl enable "lock@$USER"
