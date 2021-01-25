#! /bin/sh

rofi \
    -font "DejaVu Sans 15" \
    -modi drun -show drun \
    -show-icons \
    -matching fuzzy \
    -sorting-method fzf \
    -terminal termite

