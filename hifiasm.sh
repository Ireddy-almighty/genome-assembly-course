#!/bin/bash
#SBATCH --job-name=hifiasm_assembly
#SBATCH --output=hifiasm_assembly_%j.log
#SBATCH --error=hifiasm_assembly_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition pibu_el8

# Define working directory
WORKDIR="/data/users/nireddy/assembly_course"

# Input reads (PacBio HiFi)
READS="/data/courses/assembly-annotation-course/raw_data/Geg-14/ERR11437349.fastq.gz"

# Output directory
OUTDIR="$WORKDIR/hifiasm_output"
mkdir -p $OUTDIR

# Run hifiasm inside the Apptainer container
apptainer exec --bind /data /containers/apptainer/hifiasm_0.25.0.sif hifiasm \
  -o $OUTDIR/geg14.asm \
  -t $SLURM_CPUS_PER_TASK \
  $READS