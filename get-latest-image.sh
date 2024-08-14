#!/usr/bin/env bash

set -e

log() {
  echo "$@" >&2
}

repo="$1"
matcher="$2"

skip_point="${SKIP_POINT_RELEASE:=true}"
sorter="${SORTER:-version}"

case "${sorter}" in
version)
  sort() {
    command sort -V
  }
  ;;
normal)
  sort() {
    command sort
  }
  ;;
*)
  echo "error: unrecognized sort func: $sorter" >&2
  exit 1
  ;;
esac

log "listing repo '$repo'"
readarray -t all_versions < <(crane ls "$repo" | grep -E "${matcher}")

max_ndots=0
for v in "${all_versions[@]}"
do
  ndots="$(awk -F. '{ print NF - 1 }' <<< "$v")"
  if [[ $ndots -gt $max_ndots ]]
  then max_ndots=$ndots
  fi
done

declare -a specific_versions
for v in "${all_versions[@]}"
do
  if [[ "${skip_point}" = true ]] && grep -E '\.0+$' <<< "$v" > /dev/null
  then continue
  fi

  if grep -E "(.*\..*){$ndots}" <<< "$v" > /dev/null
  then specific_versions+=("$v")
  fi
done

for v in "${specific_versions[@]}"
do
  echo "$v"
done | sort | tail -n1
