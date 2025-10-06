#!/bin/bash
#SBATCH --job-name=busco_all_assemblies
#SBATCH --output=busco_all_%j.log
#SBATCH --error=busco_all_%j.err
#SBATCH --time=2-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --partition=pibu_el8
#SBATCH --array=0-2

# Load module if needed
module load BUSCO

# Working directory
WORKDIR="/data/users/nireddy/assembly_course"
cd $WORKDIR

# Output base directory
OUTDIR_BASE="$WORKDIR/busco_results"
mkdir -p "$OUTDIR_BASE"

# Assemblies
ASSEMBLIES=(
  "$WORKDIR/flye_output/assembly.fasta"
  "$WORKDIR/hifiasm_output/geg14.asm.bp.p_ctg.fa"
  "$WORKDIR/Trinity_output.Trinity.fasta"
)

# Mode for each assembly
MODES=("genome" "genome" "transcriptome")

ASSEMLY=${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}
MODE=${MODES[$SLURM_ARRAY_TASK_ID]}

# Select assembly and mode for this SLURM array task
ASSEMBLY=${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}
MODE=${MODES[$SLURM_ARRAY_TASK_ID]}
SAMPLE=$(basename "$ASSEMBLY")
SAMPLE=${SAMPLE%.fa*}  # remove .fa if present

echo "Running BUSCO on $ASSEMBLY (mode=$MODE)"

# 1)Run BUSCO with fixed lineage ---
OUTDIR_REF="$OUTDIR_BASE/${SAMPLE}_brassicales_odb10"
mkdir -p "$OUTDIR_REF"

busco -i "$ASSEMBLY" \
      -m "$MODE" \
      --lineage_dataset brassicales_odb10 \
      -o "${SAMPLE}_ref" \
      --cpu $SLURM_CPUS_PER_TASK \
      --out_path "$OUTDIR_REF"

# 2)Run BUSCO with auto-lineage ---
OUTDIR_AUTO="$OUTDIR_BASE/${SAMPLE}_auto"
mkdir -p "$OUTDIR_AUTO"

busco -i "$ASSEMBLY" \
      -m "$MODE" \
      --auto-lineage \
      -o "${SAMPLE}_auto" \
      --cpu $SLURM_CPUS_PER_TASK \
      --out_path "$OUTDIR_AUTO"

# 3)Verify lineage used ---
for dir in "$OUTDIR_REF" "$OUTDIR_AUTO"; do
    SS_FILE=$(ls "$dir"/*short_summary*.txt 2>/dev/null | head -n1)
    if [[ -n "$SS_FILE" ]]; then
        LINEAGE=$(grep -i '^# Database:' "$SS_FILE" | sed 's/# Database:[ \t]*//')
        MODE_USED=$(grep -i '^# Mode:' "$SS_FILE" | sed 's/# Mode:[ \t]*//')
        echo "[$dir] Lineage used: $LINEAGE | Mode: $MODE_USED"
    else
        echo "No short_summary found in $dir"
    fi
done