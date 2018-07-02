#!/bin/bash
. bashlib.sh
bl_init
bl_echo_h "cascade.sh"

if ! eval "./t1.sh first 0"; then
  bl_die "Error in bashlib_test.sh"
else
  if ! eval "./t1.sh second 1"; then
    bl_die "Error in bashlib_test.sh"
  fi
fi

exit 0
