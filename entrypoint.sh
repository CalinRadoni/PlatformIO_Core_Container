#!/bin/bash

if (( $# == 0 )); then
    /bin/bash
    exit
fi

export PLATFORMIO_CORE_DIR='/platformio'

exec pio "$@"
