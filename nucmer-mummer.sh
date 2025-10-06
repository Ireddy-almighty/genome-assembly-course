#!/bin/bash
#SBATCH --job-name=nucmer_mummerplot
#SBATCH --output=nucmer_mummerplot_%j.log
#SBATCH --error=nucmer_mummerplot_%j.err
#SBATCH --time=8:00:00
#SBATCH --mem=48G
#SBATCH --cpus-per-task=8
#SBATCH --partition=pibu_el8

set -euo pipefail

# ----------------------------
# Paths
# ----------------------------
WORKDIR="/data/users/nireddy/assembly_course"
OUTDIR="$WORKDIR/mummer_results"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Assemblies (uncompressed FASTA)
FLYE="$WORKDIR/flye_output/assembly.fasta"
HIFIASM="$WORKDIR/hifiasm_output/geg14.asm.bp.p_ctg.fa"

# Reference (uncompressed FASTA)
REF_FA="/data/users/nireddy/assembly_course/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"

# Container
CONTAINER="/containers/apptainer/mummer4_gnuplot.sif"  # adjust path if needed

# ----------------------------
# Checks
# ----------------------------
for f in "$FLYE" "$HIFIASM" "$REF_FA"; do
    if [[ ! -s "$f" ]]; then
        echo "ERROR: FASTA file missing or empty: $f"
        exit 1
    fi
done

# ----------------------------
# Function to run comparison
# ----------------------------
run_compare() {
    local ref="$1"
    local qry="$2"
    local prefix="$3"

    echo "Running comparison: $prefix"

    # Nucmer
    apptainer exec --bind /data "$CONTAINER" nucmer \
        --mincluster 1000 \
        --breaklen 1000 \
        --prefix "$prefix" \
        "$ref" "$qry"

    # Filter delta
    apptainer exec --bind /data "$CONTAINER" delta-filter -1 "${prefix}.delta" > "${prefix}.filter.delta"

    # Mummerplot
    apptainer exec --bind /data "$CONTAINER" mummerplot \
        -R "$ref" -Q "$qry" \
        --filter \
        -t png \
        --large \
        --layout \
        --fat \
        --prefix "$prefix" \
        "${prefix}.filter.delta"

    echo "Dotplot generated: ${prefix}.png"
}

# ----------------------------
# Run comparisons
# ----------------------------

# Assemblies vs Reference
run_compare "$REF_FA" "$FLYE" "flye_vs_ref"
run_compare "$REF_FA" "$HIFIASM" "hifiasm_vs_ref"

# Pairwise assembly comparison
run_compare "$FLYE" "$HIFIASM" "flye_vs_hifiasm"
