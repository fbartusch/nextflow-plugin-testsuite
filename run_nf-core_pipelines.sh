#!/bin/bash

#TODO Iterate over supported_nextflow_versions file as alternative to --nf-version parameter
#TODO Implement run with conda
#TODO Check if nf-prov configuration exists

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --nf-version)
      NF_VERSION="$2"
      shift # past argument
      shift # past value
      ;;
    --provone-version)
      PROVONE_VERSION="$2"
      shift # past argument
      shift # past value
      ;;
    --prov-version)
      PROV_VERSION="$2"
      shift # past argument
      shift # past value
      ;;
    --base-output-dir)
      BASE_OUTPUT_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    --pipelines-file)
      PIPELINES_FILE="$2"
      shift # past argument
      shift # past value
      ;;
    --profiles)
      PROFILES="$2"
      shift # past argument
      shift # past value
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# Check for required parameters
if [ -z ${NF_VERSION+x} ]; then
    echo "Set a Nextflow version (e.g. --nf-version 24.04)."
    exit 1
fi

if [ -z ${BASE_OUTPUT_DIR+x} ]; then
    echo "Set a base output directory (e.g. --base-output-dir <some_path>)."
    echo "The effective output dir: \$BASE_OUTPUT_DIR/nf-provone-\$PROVONE_VERSION}/\$DATE"
    echo "Without nf-provone:       \$BASE_OUTPUT_DIR/nf-core_outdir/\$DATE"
    exit 1
fi

if [ -z ${PIPELINES_FILE+x} ]; then
    echo "Set a pipeline file containing nf-core pipelines to run (e.g. --pipeline-file <file>"
    echo "pipeline file entries look like:"
    echo "<pipeline>, <revision>, e.g.: rnaseq, 3.0.0" 
    exit 1
fi

if [ -z ${PROFILES+x} ]; then
    echo "No profiles specified. Use 'test' profile."
    PROFILES="test"
fi

# Use provone plugin?
if [ ! -z ${PROVONE_VERSION+x} ]; then
  export USE_PROVONE=true
else
  export USE_PROVONE=false
fi

# Use prov plugin?
if [ ! -z ${PROV_VERSION+x} ]; then
  export USE_PROV=true
else
  export USE_PROV=false
fi

echo "Use Provone: ${USE_PROVONE}"
echo "Use Prov: ${USE_PROV}"

# Print parameter summary
echo "Run nf-core pipelines with:"
echo "Nextflow version : ${NF_VERSION}"
if [ -n "$USE_PROVONE+x" ] ; then
    echo "Provone plugin   : ${PROVONE_VERSION}"
fi
if [ -n "$USE_PROV+x" ] ; then
    echo "Prov plugin   : ${PROV_VERSION}"
fi
echo "Base output dir  : ${BASE_OUTPUT_DIR}"
echo "Pipeline file    : ${PIPELINES_FILE}"
echo "Profiles         : ${PROFILES}"
echo ""

# Load conda environment for set nextflow version
source $HOME/miniconda3/etc/profile.d/conda.sh
conda activate nextflow-${NF_VERSION}
NF_EXE=$(which nextflow)
echo "Using Nextflow: ${NF_EXE}"

base_dir=$BASE_OUTPUT_DIR
printf -v date '%(%Y-%m-%d)T' -1

# Set effective output directory
if [ "$USE_PROVONE" = true ] ; then
    export base_output_dir="${BASE_OUTPUT_DIR}/nf-provone-${PROVONE_VERSION}/${date}"
else
    export base_output_dir="${BASE_OUTPUT_DIR}/nf-core_outdir/${date}"
fi

# Run all nf-core pipelines
while read pipeline_string; do

    pipeline=$(echo ${pipeline_string%,*} | tr -d ' ')
    revision=$(echo ${pipeline_string##*,} | tr -d ' ')
    export pipeline_dir=${base_dir}/nf-core/${pipeline}/$(echo $revision | tr . _)

    if [ ! -d ${pipeline_dir} ]; then
      echo "Pipeline not installed: ${pipeline}:${revision}"
    else
      echo "Pipeline installed: ${pipeline}:${revision}"

    # Run with container
    export nxf_work_dir=${base_output_dir}/workdir
    export nxf_outdir=${base_output_dir}/${pipeline}/${revision}

    # Build option string
    opt_str="-profile ${PROFILES} -work-dir ${nxf_work_dir}"
    # Add plugins
    plugin_str="-plugins"
    if [ "$USE_PROVONE" = true ] ; then
      plugin_str+=" nf-provone@${PROVONE_VERSION}"
    fi
    if [ "$USE_PROV" = true ] ; then
      plugin_str+=" nf-prov@${PROV_VERSION}"
      opt_str+=" -c nf-prov.config"
    fi
    echo "plugin string: ${plugin_str}"
    if [ ${#plugin_str} -ge 10 ]; then
      opt_str+=" ${plugin_str}"
    fi

    # Add outdir
    opt_str+=" --outdir ${nxf_outdir}"

    # Run pipeline
    nextflow -log ${nxf_outdir}/nextflow.log run ${pipeline_dir} ${opt_str}
fi
done < ${PIPELINES_FILE}
