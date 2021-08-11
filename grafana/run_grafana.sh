#!/bin/bash

docker run --rm \
    --mount type=bind,source=$PWD/custom.ini,target=/etc/grafana/grafana.ini\
    --mount type=bind,source=$PWD/privkey.pem,target=/etc/grafana/privkey.pem\
    --mount type=bind,source=$PWD/cert.pem,target=/etc/grafana/cert.pem\
    -p 5000:5000 grafana/grafana