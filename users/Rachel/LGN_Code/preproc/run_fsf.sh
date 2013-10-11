#!/bin/bash

for fsf in $(ls epi*.fsf)
do
    echo $fsf
    feat $fsf
done
