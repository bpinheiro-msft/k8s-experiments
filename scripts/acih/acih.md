Bash script to automate the creation of Azure Container Instances.

## Installation:
```bash
wget https://github.com/bpinheiro19/k8s-experiments/blob/dev/scripts/acih/acih.sh
chmod +x ./acih
sudo mv ./acih /usr/local/bin/acih
```

## Help:
```bash
Create an AKS cluster
$ aks create

Delete an AKS cluster
$ aks delete

Delete the resource group
$ aks delrg
```