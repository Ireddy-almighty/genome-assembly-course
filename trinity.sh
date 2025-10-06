#!/bin/bash
#SBATCH --job-name=Trinity_assembly
#SBATCH --output=Trinity_assembly_%j.log
#SBATCH --error=trinity_assembly_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition pibu_el8

module load Trinity

#define variables:
WORKDIR="/data/users/nireddy/assembly_course"

# Input reads (PacBio HiFi)
READS1="/data/courses/assembly-annotation-course/raw_data/RNAseq_Sha/ERR754081_1.fastq.gz"
READS2="/data/courses/assembly-annotation-course/raw_data/RNAseq_Sha/ERR754081_2.fastq.gz"

# Output directory
OUTDIR="$WORKDIR/Trinity_output"
mkdir -p $OUTDIR

# Run Trinity
Trinity \
  --seqType fq \
  --max_memory 62G \
  --CPU $SLURM_CPUS_PER_TASK \
  --left $READS1 \
  --right $READS2 \
  --output $OUTDIR
