#!/bin/bash
#SBATCH --job-name=flye_assembly
#SBATCH --output=flye_assembly_%j.log
#SBATCH --error=flye_assembly_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition pibu_el8

#define variables:
WORKDIR="/data/users/nireddy/assembly_course"

# Input reads (PacBio HiFi)
READS="/data/courses/assembly-annotation-course/raw_data/Geg-14/ERR11437349.fastq.gz"

# Output directory
OUTDIR="$WORKDIR/flye_output"
mkdir -p $OUTDIR

# Run Flye
apptainer exec --bind /data /containers/apptainer/flye_2.9.5.sif flye \
  --pacbio-hifi $READS \
  --out-dir $OUTDIR \
  --threads $SLURM_CPUS_PER_TASK
