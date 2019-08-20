#!/bin/sh

cp config /etc/systemd/system/lock@.service
systemctl daemon-reload
systemctl enable lock@$1
