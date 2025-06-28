#!/bin/sh

set -eu

CHARGE_CONTROL_END_THRESHOLD_PATH="/sys/class/power_supply/BAT0/charge_control_end_threshold"
CHARGE_CONTROL_START_THRESHOLD_PATH="/sys/class/power_supply/BAT0/charge_control_start_threshold"
ENERGY_FULL="$(cat "/sys/class/power_supply/BAT0/energy_full")"
ENERGY_FULL_DESIGN="$(cat "/sys/class/power_supply/BAT0/energy_full_design")"

range=""
limit=""

usage() {
  echo "Usage: $(basename -- "$0") [-l limit] [-r range]"
  exit 1
}

while getopts ":l:r:h" opt; do
  case ${opt} in
  h)
    usage
    ;;
  l)
    limit=$OPTARG
    ;;
  r)
    range=$OPTARG
    ;;
  \?)
    echo "Invalid Option: -$OPTARG" 1>&2
    usage
    ;;
  :)
    echo "Invalid Option: -$OPTARG requires an argument" 1>&2
    usage
    ;;
  esac
done
shift $((OPTIND - 1))

set_thresholds() {
  start_threshold="$1"
  end_threshold="$2"

  cur_end_threshold="$(cat "$CHARGE_CONTROL_END_THRESHOLD_PATH")"

  echo "[INFO] Set battery charge threshold to {start: ${start_threshold}, end: ${end_threshold}}"

  if [ "$cur_end_threshold" -gt "$end_threshold" ]; then
    echo "$start_threshold" >"$CHARGE_CONTROL_START_THRESHOLD_PATH"
    echo "$end_threshold" >"$CHARGE_CONTROL_END_THRESHOLD_PATH"
  else
    echo "$end_threshold" >"$CHARGE_CONTROL_END_THRESHOLD_PATH"
    echo "$start_threshold" >"$CHARGE_CONTROL_START_THRESHOLD_PATH"
  fi
}

clamp() {
  val="$1"
  min="$2"
  max="$3"

  if [ "$val" -gt "$max" ]; then
    echo "$max"
  elif [ "$val" -lt "$min" ]; then
    echo "$min"
  else
    echo "$val"
  fi
}

main() {
  if [ $# -ne 0 ]; then
    echo "Error: Unexpected arguments: $*" 1>&2
    usage
  fi

  if [ "$limit" = "" ] || [ "$range" = "" ]; then
    echo "Error: Both -l and -r options are required." 1>&2
    usage
  fi

  if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    return 1
  fi

  start_threshold="$((limit - range))"

  real_end="$((limit * ENERGY_FULL_DESIGN / ENERGY_FULL))"
  real_start="$((start_threshold * ENERGY_FULL_DESIGN / ENERGY_FULL))"

  real_end="$(clamp "$real_end" 1 100)"
  real_start="$(clamp "$real_start" 0 99)"

  if [ "$real_start" -ge "$real_end" ]; then
    real_start="$((real_end - 1))"
  fi

  set_thresholds "$real_start" "$real_end"
}

main "$@"
