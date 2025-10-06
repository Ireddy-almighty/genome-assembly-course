#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=jellyfish
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/nireddy/assembly_course"
pacbioREAD1="/data/courses/assembly-annotation-course/raw_data/Geg-14/ERR11437349.fastq.gz"
illuminaread1="/data/courses/assembly-annotation-course/raw_data/RNAseq_Sha/ERR754081_1.fastq.gz"
illuminaread2="/data/courses/assembly-annotation-course/raw_data/RNAseq_Sha/ERR754081_2.fastq.gz"

# Output dirs
OUTDIR="$WORKDIR/k-mer_counting_results"
mkdir -p "$OUTDIR"

cd "$OUTDIR"

# Run Jellyfish k-mer counting inside the container
# -C : count both strands (canonical)
# -m 21 : k-mer size of 21
# -s 5G : hash size (memory for k-mer storage)
# -t 4 : use 4 threads
# Input: all FASTQ files (decompressed on-the-fly with zcat)
# Output: Jellyfish binary k-mer database (.jf)
apptainer exec --bind /data \
    /containers/apptainer/jellyfish:2.2.6--0 \
    jellyfish count -C -m 21 -s 5G -t 4 \
    <(zcat $WORKDIR/*.fastq.gz) \
    -o $OUTDIR/Abd-0_reads.jf

# Generate histogram from the k-mer counts
# Output: text histogram file (.histo)
apptainer exec --bind /data \
    /containers/apptainer/jellyfish:2.2.6--0 \
    jellyfish histo -t 4 $OUTDIR/Abd-0_reads.jf > $OUTDIR/Abd-0_reads.histo