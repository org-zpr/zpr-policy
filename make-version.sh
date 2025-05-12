#!/usr/bin/env bash
#
# NOTE: This script can be run locally, but is intended for use by the github runner

set -uo pipefail

src_version_filename="zpr-policy.version"
this_version_filename="this.version"
tool_version_filename="protoc.version"

tool_version=$(protoc --version)


function get_source_dir() {
  if [[ "$0" == "$BASH_SOURCE" ]] ; then
    quit=exit
    src_dir=$(dirname "$0")
  else
    quit=return
    src_dir=$(dirname "$BASH_SOURCE")
  fi
}

function get_repo() {
  repo_long=$(git config --get remote.origin.url) || return 1
  repo=$(basename $repo_long .git)
}

function get_src_version() {
  src_version=$(cd "$src_dir" && git describe --tags --always --abbrev=0)
  src_hash=$(cd "$src_dir" && git show -s --format=%h "$src_version")
}

function get_previous_versions() {
  old_src_file=$(cat "$src_version_filename")
  old_src_version=$(echo "$old_src_file" | cut -d' ' -f 1)
  old_this_version=$(cat "$this_version_filename")
  old_tool_version=$(cat "$tool_version_filename")
}

function check_src_version() {
  # TODO: check that the version hasn't gone backwards
  echo "Source version changed from $old_src_version to $src_version"
  echo "${src_version} ${src_hash}" > "$src_version_filename"
}

function check_tool_version() {
  if [[ "$old_tool_version" != "$tool_version" ]] ; then
    echo "WARNING: Toolchain version changed from $old_tool_version to $tool_version"
    echo "Please consider bumping the major version."
    echo "This script does not yet support that functionality."
    echo "tool_version" > "$tool_version_filename"
  fi
}

function bump_version() {
  # TODO: figure out how to programmatically determine this
  # For now only bump minor and do others by hand
  bump_minor_version
}

function bump_major_version() {
  this_version=$(echo "$old_this_version" | awk -F . '{print $1+1 ".0.0"}')
  echo "Bumping major version from $old_this_version to $this_version"
  echo "$this_version" > "$this_version_filename"
}

function bump_minor_version() {
  this_version=$(echo "$old_this_version" | awk -F . '{print $1 "." $2+1 ".0"}')
  echo "Bumping minor version from $old_this_version to $this_version"
  echo "$this_version" > "$this_version_filename"
}

function bump_hotfix_version() {
  this_version=$(echo "$old_this_version" | awk -F . '{print $1 "." $2 "." $3+1}')
  echo "Bumping hotfix version from $old_this_version to $this_version"
  echo "$this_version" > "$this_version_filename"
}

function update_rust_cargo() {
  version_regex="\([0-9]\+.[0-9]\+.[0-9]\+\)"
  sed -i "s/\(version = \"\)$version_regex\"/\1${this_version:1}\"/" Cargo.toml
}

function populate_github_output() {
  if [[ -v GITHUB_OUTPUT ]]; then
    echo "title=[$this_version] Generate go bindings for POLICY IO $src_version" >> $GITHUB_OUTPUT
    echo "body=This code was automatically generated using $tool_version." >> $GITHUB_OUTPUT
    echo "branch=generate-$this_version" >> $GITHUB_OUTPUT
  fi
}

function do_versioning() {
  get_previous_versions
  check_tool_version
  check_src_version
  bump_version
  populate_github_output
}

get_source_dir

if ! get_repo; then
  echo "Error: Please invoke this script inside of a git repo"
  $quit 1
fi

get_src_version
case $repo in
  zpr-policy)
    # TODO: Could auto-tag?
    echo "Not supported"
    ;;
  zpr-policy-rs)
    echo "Updating version info for Rust bindings in $repo"
    do_versioning
    update_rust_cargo
    ;;
  zpr-policy-go)
    echo "Updating version info for Go bindings in $repo"
    do_versioning
    ;;
  *)
    echo "Invalid repository"
    ;;
esac
