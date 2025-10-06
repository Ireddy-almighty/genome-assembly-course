#!/bin/bash
#SBATCH --job-name=jellyfish_kmers
#SBATCH --output=jellyfish_%j.log
#SBATCH --error=jellyfish_%j.err
#SBATCH --time=12:00:00
#SBATCH --mem=48G
#SBATCH --cpus-per-task=4
#SBATCH --partition=pibu_el8

# Working dir
WORKDIR="/data/users/nireddy/assembly_course"
pacbioREAD1="/data/courses/assembly-annotation-course/raw_data/Geg-14/ERR11437349.fastq.gz"
illuminaread1="/data/courses/assembly-annotation-course/raw_data/RNAseq_Sha/ERR754081_1.fastq.gz"
illuminaread2="/data/courses/assembly-annotation-course/raw_data/RNAseq_Sha/ERR754081_2.fastq.gz"
CONTAINER="/containers/apptainer/jellyfish_2.3.0.sif"

cd $WORKDIR

# Output dirs
OUTDIR="$WORKDIR/k-mer_counting_results"
mkdir -p "$OUTDIR"

cd "$OUTDIR"

# Parameters
K=21
HASH_SIZE=5G
THREADS=4

# --- 1) Count k-mers ---
apptainer exec --bind /data $CONTAINER jellyfish count \
  -C \
  -m $K \
  -s $HASH_SIZE \
  -t $THREADS \
  <(zcat $READ1) \
  -o reads_k${K}.jf

# --- 2) Make histogram ---
apptainer exec $CONTAINER jellyfish histo \
  -t $THREADS \
  reads_k${K}.jf \
  > reads_k${K}.histo

echo "Done. Upload reads_k${K}.histo to http://genomescope.org/genomescope2.0/"