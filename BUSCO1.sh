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
OUTDIR_BASE="$WORKDIR/busco_results1"
mkdir -p "$OUTDIR_BASE"

# Assemblies
ASSEMBLIES=(
  "$WORKDIR/flye_output/assembly.fasta"
  "$WORKDIR/hifiasm_output/geg14.asm.bp.p_ctg.fa"
  "$WORKDIR/Trinity_output.Trinity.fasta"
)

# Mode for each assembly
MODES=("genome" "genome" "transcriptome")

INPUT=${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}
NAME=${NAMES[$SLURM_ARRAY_TASK_ID]}
MODE=${MODES[$SLURM_ARRAY_TASK_ID]}

busco -f -i "$INPUT" -c 16 --out_path "$OUTDIR" -o "$NAME" -m "$MODE" -l brassicales_odb10

echo "BUSCO done for $NAME"