#!/bin/bash

kubectl run -it srvlookup --image=tutum/dnsutils --rm --restart=Never -- dig SRV openam-service.default.svc.cluster.local