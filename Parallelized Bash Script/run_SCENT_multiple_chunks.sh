#!/usr/bin/env bash
set -eu
set -o pipefail

scent_object="$1"
candidate_link_folder="$2"
scent_output_folder="$3"
script="${4:-run_SCENT.R}"
jobs="${5:-4}"

mkdir -p "$scent_output_folder"

run_one() {
  local candidate_link_file="$1"
  local base
  base="$(basename "$candidate_link_file")"
  local basename_noext="${base%.*}"
  local scent_output_file="$scent_output_folder/$basename_noext.tsv"
  local log_file="$scent_output_folder/$basename_noext.log"

  if [[ -f "$scent_output_file" ]]; then
    echo "Skipping $candidate_link_file: $scent_output_file already exists"
    return 0
  fi

  echo "Running SCENT for $candidate_link_file"
  Rscript "$script" \
    --scent_object "$scent_object" \
    --candidate_link_file "$candidate_link_file" \
    --scent_output_file "$scent_output_file" \
    >"$log_file" 2>&1
}

export -f run_one
export scent_object scent_output_folder script

find "$candidate_link_folder" -maxdepth 1 -type f -print0 \
  | xargs -0 -n 1 -P "$jobs" bash -c 'run_one "$@"' _
