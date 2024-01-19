#!/usr/bin/env bash
set -Eeuo pipefail

echo "❯ Starting Virtual DSM for Docker v$(</run/version)..."
echo "❯ For support visit https://github.com/vdsm/virtual-dsm"
echo

cd /run

. reset.sh      # Initialize system
. install.sh    # Run installation
. disk.sh       # Initialize disks
. display.sh    # Initialize graphics
. network.sh    # Initialize network
. proc.sh       # Initialize processor
. serial.sh     # Initialize serialport
. power.sh      # Configure shutdown
. config.sh     # Configure arguments

trap - ERR

if [[ "$CONSOLE" == [Yy]* ]]; then
  exec qemu-system-x86_64 ${ARGS:+ $ARGS}
fi

[[ "$DEBUG" == [Yy1]* ]] && info "$VERS" && echo "Arguments: $ARGS" && echo
{ qemu-system-x86_64 ${ARGS:+ $ARGS} >"$QEMU_OUT" 2>"$QEMU_LOG"; rc=$?; } || :
(( rc != 0 )) && error "$(<"$QEMU_LOG")" && exit 15

terminal
tail -fn +0 "$QEMU_LOG" 2>/dev/null &
cat "$QEMU_TERM" 2>/dev/null & wait $! || :

sleep 1 && finish 0
