#!/bin/bash
#set -e

echo "##########################################################"
echo "##### Delete existing installation: be aware of dataloss #########"
echo "##########################################################"

echo "##### Delete Fabric CA #########"

kubectl delete -f fabric/*

echo "##########################################################"
echo "##### Fabric installation deleted #########"
echo "##########################################################"
