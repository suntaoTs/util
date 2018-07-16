#!/bin/bash
cd `dirname $0`

docker build -t iva-image-pipeline-build:0.0.1 .

