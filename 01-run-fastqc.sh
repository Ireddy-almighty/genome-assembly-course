#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --output=fastqc_%j.log
#SBATCH --error=fastqc_%j.err
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --partition=pibu_el8


# Define working directory
WORKDIR="/data/users/nireddy/assembly_course"
cd $WORKDIR

# Input reads (can be multiple, comma-separated or space-separated)
READS="/data/courses/assembly-annotation-course/raw_data/Geg-14/ERR11437349.fastq.gz"

# Output directory
OUTDIR="$WORKDIR/fastqc_output"
mkdir -p $OUTDIR

# Run FastQC
apptainer exec \
  --bind /data \
  /containers/apptainer/fastqc-0.12.1.sif \
  fastqc \
  -o $OUTDIR \
  -t $SLURM_CPUS_PER_TASK \
  $READS