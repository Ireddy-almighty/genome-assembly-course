#!/bin/bash
#SBATCH --job-name=fastp_run
#SBATCH --output=fastp_%j.log
#SBATCH --error=fastp_%j.err
#SBATCH --time=12:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --partition=pibu_el8

# Load module
module load fastp

# Working directories
WORKDIR="/data/users/nireddy/assembly_course"
RNA_IN1="/data/courses/assembly-annotation-course/raw_data/RNAseq_Sha/ERR754081_1.fastq.gz"
RNA_IN2="/data/courses/assembly-annotation-course/raw_data/RNAseq_Sha/ERR754081_2.fastq.gz"
PACBIO_IN="/data/courses/assembly-annotation-course/raw_data/Geg-14/ERR11437349.fastq.gz"

# Output dirs
OUTDIR="$WORKDIR/fastp_results"
mkdir -p "$OUTDIR"

cd "$OUTDIR"

# --- 1) Illumina RNAseq filtering & trimming ---
fastp \
  -i $RNA_IN1 -I $RNA_IN2 \
  -o illumina_R1.trimmed.fastq.gz -O illumina_R2.trimmed.fastq.gz \
  -h illumina_fastp_report.html -j illumina_fastp_report.json \
  --detect_adapter_for_pe \
  --thread 8

# --- 2) PacBio HiFi (report only, no filtering) ---
fastp \
  -i $PACBIO_IN \
  -o pacbio_out.fastq.gz \
  -h pacbio_fastp_report.html -j pacbio_fastp_report.json \
  --disable_length_filtering \
  --disable_quality_filtering \
  --thread 8

echo "fastp finished. Reports in $OUTDIR"
