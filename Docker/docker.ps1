#region Windows Containers
#This demo requires Windows Containers
docker run -it mcr.microsoft.com/windows/servercore cmd.exe
docker run -it --name demo1 -v C:\containerdata:c:\data mcr.microsoft.com/windows/servercore cmd.exe

docker images
#MS moved from docker hub https://github.com/microsoft/containerregistry/blob/main/docs/dockerhub-to-mcr-repo-mapping.md
#mcr does NOT have a latest tag. Must specify a version
docker pull mcr.microsoft.com/windows/servercore:ltsc2022  #previously microsoft/windowsservercore
docker pull mcr.microsoft.com/windows/nanoserver:ltsc2022
docker search sql
docker pull mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022 #previously microsoft/iis
docker image history mcr.microsoft.com/windows/servercore/iis

#Quick image
Set-Location badfather
docker build -t badfather .

#Windows examples
docker run --name iisdemo -it -p 80:80 badfather cmd
#add --isolation=hyperv    to make a Hyper-V container instead

docker rmi badfather
#endregion

#region Linux Containers
#Apache image
docker images
docker search --filter is-official=true httpd
docker pull httpd
docker image history httpd #view the layers
docker image inspect httpd #detailed info about image
docker run --name httpdrun -dit httpd bash

#list containers
docker ps -a 
$dockid = $(docker ps -a -q --filter "name=httpdrun")
docker attach $dockid  #Ctrl P Q to exit and leave running. Or exit to stop
docker start $dockid
docker stop $dockid
docker rm $dockid

Set-Location badfatherapache
docker build -t badfather .
docker history badfather
docker images


#DC:create container using image stored in Azure Container Registry and map port 80 on box with port 80 on container; name: badfather-app-fromACR
docker run -dit --name badfather-app-fromACR -p 80:80 dc2containerregistry.azurecr.io/images/badfather
$dockid = $(docker ps -a -q --filter "name=badfather-app-fromACR")
docker rmi badfather


#DC:create container and map port 80 on box with port 80 on container
docker run -dit --name badfather-app -p 80:80 badfather
$dockid = $(docker ps -a -q --filter "name=badfather-app")
docker rmi badfather

#Networking
docker network ls
docker network inspect bridge

#endregion

#region Azure and Docker Hub Interactions
#Need to be logged into Azure first
#https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?tabs=azure-cli#log-in-to-a-registry
az login
az acr login --name dc2containerregistry
docker login dc2containerregistry.azurecr.io

#DC: Create Azure Container Instance using Azure Contaner Registry image
az container show --resource-group DCOSMA --name dccontainerinstance --query ipAddress.fqdn
az acr show --name dc2containerregistry.azurecr.io/images/badfather --query loginServer
#az container create --resource-group DCOSMA --name dcbadfatherci --image <acrLoginServer>/aci-tutorial-app:v1 --cpu 1 --memory 1 --registry-login-server <acrLoginServer> --registry-username <service-principal-ID> --registry-password <service-principal-password> --ip-address Public --dns-name-label <aciDnsLabel> --ports 80

docker tag badfather dc2containerregistry.azurecr.io/images/badfather
docker push dc2containerregistry.azurecr.io/images/badfather
docker pull dc2containerregistry.azurecr.io/images/badfather
docker image history dc2containerregistry.azurecr.io/images/badfather

#Cleanup
docker rmi dc2containerregistry.azurecr.io/images/badfather
docker rmi badfather
docker rmi httpd

#talk to running ACI instance
az container list --output table
az container exec -g RG-ACI --name bad1 --container-name bad1 --exec-command "/bin/bash"


#Docker Hub demo
docker login  #johnthebrit
docker images
docker tag a93a249d820c johnthebrit/badfather:latest
docker push johnthebrit/badfather
docker pull johnthebrit/badfather
#endregion

#region Bulk Cleanup
#Remove all containers
docker rm $(docker ps -a -q)

#Remove all container images
docker rmi $(docker images -q)
#endregion