#!/usr/bin/env bash
# Laster opp parameterfilene til Key Vault, én secret per stack og miljø:
#   <mappe>/<stack>-<miljø>.tfvars  ->  tfvars-<stack>-<miljø>
#
# Parameterfilene skal ligge UTENFOR repoet (K7 – selvtesten ser også på
# arbeidsmappa, ikke bare på git).
#
# Bruk:  ./scripts/last-opp-tfvars.sh <kv-navn> <mappe-med-tfvars>
# F.eks: ./scripts/last-opp-tfvars.sh kv-tf-aak ../../Oblig-lokalt/oblig1/tfvars
set -euo pipefail

KV_NAME="${1:-}"
MAPPE="${2:-}"

if [[ -z "$KV_NAME" || -z "$MAPPE" ]]; then
  echo "Bruk: $0 <kv-navn> <mappe-med-tfvars>" >&2
  exit 1
fi

shopt -s nullglob
FILER=("$MAPPE"/*.tfvars)
if [[ ${#FILER[@]} -eq 0 ]]; then
  echo "Fant ingen .tfvars i $MAPPE" >&2
  exit 1
fi

for fil in "${FILER[@]}"; do
  navn="tfvars-$(basename "$fil" .tfvars)"
  echo "Laster opp $fil som $navn"
  az keyvault secret set \
    --vault-name "$KV_NAME" \
    --name "$navn" \
    --file "$fil" \
    --content-type 'application/tfvars; charset=utf-8' \
    --only-show-errors \
    --query '{name:name, contentType:contentType}' -o tsv
done
