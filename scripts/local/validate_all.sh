#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)/terraform-aws-infra"
for env in dev stage prod; do

  echo "== Validating $env =="
  pushd "$ROOT_DIR/environments/$env" >/dev/null
  terraform init -backend=false
  
  terraform validate
  
  popd >/dev/null
done
