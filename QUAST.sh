#!/bin/bash
#SBATCH --job-name=quast
#SBATCH --output=quast_%j.log
#SBATCH --error=quast_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8

# Working directory
WORKDIR="/data/users/nireddy/assembly_course"
OUTDIR="$WORKDIR/quast_results"
mkdir -p $OUTDIR

# Assemblies
FLYE="/data/users/nireddy/assembly_course/flye_output/assembly.fasta"
HIFIASM="$WORKDIR/hifiasm_output/geg14.asm.bp.p_ctg.fa"

# Reference + annotation
REF="/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
GFF="/data/courses/assembly-annotation-course/references/TAIR10_GFF3_genes.gff"

# Container
CONTAINER="/containers/apptainer/quast_5.2.0.sif"

# --- Run without reference ---
apptainer exec --bind $WORKDIR $CONTAINER quast.py \
  -o $OUTDIR/no_ref \
  --threads $SLURM_CPUS_PER_TASK \
  $FLYE $HIFIASM

# --- Run with reference ---
apptainer exec --bind /data $CONTAINER quast.py \
  -o $OUTDIR/with_ref \
  --threads $SLURM_CPUS_PER_TASK \
  -r $REF -g $GFF \
  $FLYE $HIFIASM