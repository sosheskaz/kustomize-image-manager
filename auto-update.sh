#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

managed_images=($(yq e '.managed_images | keys | .[]' -r config.yaml))

touch versions.yaml

for mi in "${managed_images[@]}"
do
  repo="$(IMAGE_NAME="$mi" yq e '.managed_images[env(IMAGE_NAME)].repo // env("IMAGE_NAME")' -r config.yaml)"
  matcher="$(IMAGE_NAME="$mi" yq e '.managed_images[env(IMAGE_NAME)].matcher // env("IMAGE_NAME")' -r config.yaml)"
  sorter="$(IMAGE_NAME="$mi" yq e '.managed_images[env(IMAGE_NAME)].sorter // "version"' -r config.yaml)"
  skip_point="$(IMAGE_NAME="$mi" yq e '.managed_images[env(IMAGE_NAME)].skip_point | (. == null or . == true)' -r config.yaml)"
  latest="$(SORTER="$sorter" SKIP_POINT_RELEASE="$skip_point" ./get-latest-image.sh "$repo" "$matcher")"
  echo "setting $mi to $repo:$latest" >&2
  IMAGE_NAME="$mi" REPO="$repo" TAG="$latest" yq e -P -i 'with(.images[env(IMAGE_NAME)]; .newName = env(REPO) | .newTag = (env(TAG) | to_string))' 'versions.yaml'
done

./generate-kustomize.sh
