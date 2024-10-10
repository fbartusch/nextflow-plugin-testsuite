#!/bin/bash

# Create environments various Nextflow versions
while read nextflow_version; do

    # Check if environment already exists for this Nextflow version
    if { conda env list | cut -d' ' -f 1 | grep "nextflow-${nextflow_version}"; } >/dev/null 2>&1; then
        echo "Install Nextflow-${nextflow_version}: Conda environment already exists."
    else
        echo "Install Nextflow-${nextflow_version}: Create new Conda environment."
        conda create --name nextflow-${nextflow_version} nextflow=${nextflow_version} nf-core -y 
    fi

done < supported_nextflow_versions
