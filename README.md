# nextflow-plugin-testsuite

Scripts for deploying nf-core pipelines and testing new Nextflow plugins against them.

## Setup

You need a working conda installation.

Specify which pipelines you want to test your plugin against in `supported_nf-core_pipelines`. The default contains every nf-core pipeline that uses the DSL version 2.

```
airrflow, 4.1.0
ampliseq, 2.11.0
atacseq, 2.1.2
bacass, 2.3.1
[...]
```

The file `one_pipeline` contains only the demo pipeline and can be used for first tests.

`supported_nextflow_versions` contains Nextflow versions you want to test against:

```
24.04
23.10
```

Creates a Conda environment for each Nextflow version specified in `supported_nextflow_versions`.

```
chmod +x install_nextflow_versions.sh
./install_nextflow_versions.sh
```

Download nf-core pipelines and the Singularity containers they are using.
The script does not have any options. The default installation directory is `./`.
It will iterate over the pipelines from `supported_nf-core_pipelines` and downloads it using the `nf-core` tool.

```
chmod +x install_nf-core_pipelines.sh
./install_nf-core_pipelines.sh
```

## Test your plugin

`run_nf-core_pipelines.sh` runs your plugin against nf-core pipelines.
Currently only the `nf-prov` plugin is supported.

```
chmod +x run_nf-core_pipelines.sh
./run_nf-core_pipelines.sh \
  --nf-version 24.04 \
  --prov-version 1.1.0 \
  --base-output-dir /tmp \
  --pipelines-file supported_nf-core_pipelines \
  --profiles test
```





