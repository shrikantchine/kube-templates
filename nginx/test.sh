#! /usr/bin/bash

KUBECMD=microk8s.kubectl

echo $PWD
echo "Running deploy"
$KUBECMD apply -f ./deploy.yaml

echo "Waiting 5s for deploy to finish"
sleep 5s

echo "Running Service"
$KUBECMD apply -f ./service.yaml

sleep 5s


IP=$($KUBECMD get svc web-service -o go-template --template '{{ .spec.clusterIP }}')
PORT=$($KUBECMD get svc web-service -o json | jq .spec.ports[0].port)

echo "Calling IP=$IP at PORT=$PORT"

if [ "$(curl -s -o /dev/null -w ''%{http_code}'' $IP:$PORT)" != "200" ]
then
    echo "===>TEST failed"
else
    echo "===>Test successful"
fi

echo "Cleaning up"
$KUBECMD delete -f ./deploy.yaml
$KUBECMD delete -f ./service.yaml