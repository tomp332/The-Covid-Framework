#!/bin/bash

docker run --rm \
    --mount type=bind,source=$PWD/custom.ini,target=/etc/grafana/grafana.ini\
    --mount type=bind,source=$PWD/RootCA.key,target=/etc/grafana/RootCA.key\
    --mount type=bind,source=$PWD/RootCA.crt,target=/etc/grafana/RootCA.crt\
    -p 5000:5000 grafana/grafana