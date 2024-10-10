#!/bin/bash

conda activate nf-core

# Base directory in which pipelines will be installed
base_dir="./"

# Create environments various Nextflow versions
while read pipeline_string; do

    pipeline=$(echo ${pipeline_string%,*} | tr -d ' ')
    revision=$(echo ${pipeline_string##*,} | tr -d ' ')
    export pipeline_dir=${base_dir}/nf-core/${pipeline}

    if [ ! -d ${pipeline_dir} ]; then
      echo "Install ${pipeline}:${revision}"
      nf-core download --force -o ${pipeline_dir} -x none -d -u amend --container-system singularity -r ${revision} ${pipeline}
      # Ran against some limitation on the nf-core side. Wait a bit between downloads.
      sleep 30
    else
      echo "Already installed:  ${pipeline}:${revision}"
    fi

done < supported_nf-core_pipelines
