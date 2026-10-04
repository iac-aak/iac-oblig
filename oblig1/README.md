# Obligatorisk øving

Terraform-oppsettet ruller ut to miljøer (`dev` og `test`) fra én kodebase. State ligger i Azure, og utrullingen gjøres av en GitHub Actions-workflow med OIDC.

## Struktur

```
backend-bootstrap/   State-kontoen, containeren og Key Vault (fra øving 5, lokal state, rulles ikke ut herfra)
modules/
  network/           VNet, subnett (for_each) og NSG med kobling per subnett
  compute/           NIC og Linux-VM med SSH-nøkkel
stacks/
  nettverk/          Bruker modules/network. Publiserer subnet_ids
  app/               Bruker modules/compute. Leser subnet_ids med terraform_remote_state
shared/backend.hcl   Eneste sted state-kontoen er navngitt
scripts/             Opplasting av parameterfiler til Key Vault

../.github/workflows/   deploy.yml, destroy.yml og den gjenbrukbare terraform-stack.yml (i rota av repoet)
```

## Navnekonvensjon

`<type>[-<rolle>]-<miljø>-<kortnavn>`, bygget i `locals` fra variabler:

| Ressurs | dev |
|---|---|
| Ressursgruppe | `rg-nettverk-dev-aak`, `rg-app-dev-aak` |
| VNet / NSG | `vnet-dev-aak`, `nsg-dev-aak` |
| Subnett | `snet-web-dev-aak`, `snet-app-…`, `snet-data-…` |
| VM / NIC | `vm-dev-aak`, `nic-dev-aak` |

## State

Begge stackene har en tom `backend "azurerm" {}`. Workflowen gir adressen med `-backend-config=oblig1/shared/backend.hcl` og key med `-backend-config="key=<miljø>/<stack>.tfstate"`:

```
dev/nettverk.tfstate
dev/app.tfstate
test/nettverk.tfstate
test/app.tfstate
```

## Parameterverdier

Ingen `.tfvars` ligger i repoet. Hver stack og hvert miljø har sin egen secret i Key Vault, `tfvars-<stack>-<miljø>`. Workflowen henter den til `params.auto.tfvars` og sletter fila til slutt. Opplasting:

```bash
./scripts/last-opp-tfvars.sh <kv-navn> <mappe-utenfor-repoet>
```

## Workflow

- **`deploy.yml`**: push til `main` ruller ut `dev`. `test` rulles ut manuelt (`workflow_dispatch`). Først `nettverk`, deretter `app`.
- **`destroy.yml`**: manuell. Krever bekreftelsen `riv ned <miljø>`, og river ned `app` før `nettverk`.
- **`terraform-stack.yml`**: init, validate, plan og apply for én stack. Bruker `plan -detailed-exitcode`, og hopper over apply når planen er `No changes`.

GitHub-secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` og `AZURE_SUBSCRIPTION_ID` som repository secrets, og `KEYVAULT_NAME` som environment secret på `dev` og `test`.

## Lokal kjøring

```bash
cd stacks/nettverk
terraform init -backend-config=../../shared/backend.hcl -backend-config="key=dev/nettverk.tfstate"
terraform plan -var-file=<sti-til>/nettverk-dev.tfvars
```

`app` trenger i tillegg `TF_VAR_backend_resource_group_name`, `TF_VAR_backend_storage_account_name` og `TF_VAR_backend_container_name`, med samme verdier som i `shared/backend.hcl`.
