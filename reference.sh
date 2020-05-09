#!/bin/bash

packer --help | tee packer-help.txt

for I in build; do
  packer "${I}" --help | tee "packer-${I}-help.txt"
done
