#!/bin/bash
#SBATCH --job-name=merqury_eval
#SBATCH --output=merqury_%j.log
#SBATCH --error=merqury_%j.err
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8

# Add Merqury path
export MERQURY="/usr/local/share/merqury"

# Working directories
WORKDIR="/data/users/nireddy/assembly_course"
READS="/data/courses/assembly-annotation-course/raw_data/Geg-14/ERR11437349.fastq.gz"
CONTAINER="/containers/apptainer/merqury_1.3.sif"

# Assemblies
FLYE="$WORKDIR/flye_output/assembly.fasta"
HIFIASM="$WORKDIR/hifiasm_output/geg14.asm.bp.p_ctg.fa"

cd $WORKDIR

# --- Step 1: Prepare meryl DB from reads ---
if [ ! -d read_k21.meryl ]; then
    apptainer exec --bind /data $CONTAINER meryl k=21 count $READS output read_k21.meryl
fi

# --- Step 2: Run Merqury for each assembly ---
apptainer exec --bind /data $CONTAINER $MERQURY/merqury.sh read_k21.meryl $FLYE flye_merqury
apptainer exec --bind /data $CONTAINER $MERQURY/merqury.sh read_k21.meryl $HIFIASM hifiasm_merqury


