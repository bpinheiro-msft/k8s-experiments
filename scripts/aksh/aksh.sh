#!/bin/bash

date="$(date +%s)"
rg="test"
location="uksouth"
aks="aks$date"
vnet="vnet$date"
vnetAddr=10.0.0.0/16
subnet="subnet$date"
subnetAddr=10.0.240.0/24
serviceCidr=10.0.242.0/24
dnsIp=10.0.242.10
sku="standard_d2as_v4" #"standard_b2s" Cheaper option
nodeCount=1

aks() {

    for arg in "$@"; do
        
        case "$arg" in
        create)

            echo "Creating the resource group"
            az group create -n $rg -l $location

            echo "Creating vnet and subnet"
            az network vnet create -g $rg -n $vnet --address-prefix $vnetAddr --subnet-name $subnet --subnet-prefixes $subnetAddr

            subnetId=$(az network vnet subnet show -g $rg --vnet-name $vnet -n $subnet --query id -o tsv)

            echo "Creating AKS cluster"
            az aks create -g $rg -n $aks --network-plugin azure --vnet-subnet-id $subnetId --service-cidr $serviceCidr --dns-service-ip $dnsIp --node-vm-size $sku --node-count $nodeCount

            echo "az aks get-credentials --resource-group $rg --name $aks -f $KUBECONFIG"
            ;;
            
        createpriv)
            echo "Creating the resource group"
            az group create --name $rg --location $location

            echo "Creating vnet and subnet"
            az network vnet create -g $rg -n $vnet --address-prefix $vnetAddr --subnet-name $subnet --subnet-prefixes $subnetAddr

            subnetId=$(az network vnet subnet show -g $rg --vnet-name $vnet -n $subnet --query id -o tsv)

            echo "Creating private AKS cluster"
            az aks create -g $rg -n $aks --network-plugin azure --vnet-subnet-id $subnetId --service-cidr $serviceCidr --dns-service-ip $dnsIp --node-vm-size $sku --node-count $nodeCount --enable-private-cluster --disable-public-fqdn

            echo "Creating Azure VM in the same vnet"
            az vm create -g test -n myVM --image UbuntuLTS --vnet-name $vnet --admin-username azureuser --ssh-key-value ~/.ssh/id_rsa.pub
            ;;

        delete)
            echo "Deleting resource group"
            az group delete -n $rg
            ;; 
        
        -h | --help)
            help
            ;;
        *)
            echo "Invalid arguments"
            help
            exit 1
            ;;
        esac
    done
}

help() {
        echo 'Help:'
        echo "Create an AKS cluster with azure cni"
        echo '$ aks create'
        echo ""
        echo "Create a private AKS cluster"
        echo "$ aks createpriv"
        echo ""
        echo "Delete the resource group"
        echo "$ aks delete"
        echo ""
}

main(){
    if [ -z "$1" ]; then
        echo "No arguments"
        help
        return 1
    fi

    aks $@
}

main $@