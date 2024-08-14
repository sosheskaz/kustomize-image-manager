#!/usr/bin/env bash

set -e

touch kustomization.yaml

yq e -Pi '.apiVersion="kustomize.config.k8s.io/v1alpha1"' kustomization.yaml
yq e -Pi '.kind="Component"' kustomization.yaml
yq ea -Pi 'select(fi==0).images = (select(fi==1).images | to_entries | map({"name": .key} * .value)) | select(fi==0)' kustomization.yaml versions.yaml
