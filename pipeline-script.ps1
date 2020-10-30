Write-Host "Create Storage Account"
az storage account create -n "annomatedata" -g "RG_AnnoMate_POC" -l "westeurope" --sku "Standard_LRS"
$access_key = $(az storage account keys list -g "RG_AnnoMate_POC" -n "annomatedata" --query [0].value -o tsv)

Write-Host "Create File Share"
az storage share create --account-name "annomatedata" --name "data"

Write-Host "Create App Service plan"
az appservice plan create --name annomate-asp --resource-group "RG_AnnoMate_POC" --sku "P1V2" --is-linux

Write-Host "Create Web App from docker-compose file"
az webapp create --resource-group "RG_AnnoMate_POC" --plan "annomate-asp" --name "annomate" --multicontainer-config-type "compose" --multicontainer-config-file "docker-compose.yml"

Write-Host "Add Storage Account configs"
az webapp config storage-account add -g "RG_AnnoMate_POC" -n "annomate" `
  --custom-id "cvat_data" `
  --storage-type "AzureFiles" `
  --account-name "annomatedata" `
  --share-name "data" `
  --access-key $access_key `
  --mount-path "/home/django/data"

Write-Host "Enable logging from docker containers"
az webapp log config --name annomate --resource-group RG_AnnoMate_POC --docker-container-logging filesystem

Write-Host "Set registry configs and enable file storage"
az webapp config appsettings set --resource-group RG_AnnoMate_POC --name annomate --settings `
  DOCKER_REGISTRY_SERVER_PASSWORD="Wnsr8K6wdYlvXYav7RQmeB8jyF=fxTLy" `
  DOCKER_REGISTRY_SERVER_URL="https://annomatepocacr.azurecr.io" `
  DOCKER_REGISTRY_SERVER_USERNAME="annomatepocacr" `
  WEBSITE_HTTPLOGGING_RETENTION_DAYS="1" `
  WEBSITES_ENABLE_APP_SERVICE_STORAGE="FALSE"

Write-Host "Restart Web App"
az webapp restart --name "annomate" --resource-group "RG_AnnoMate_POC"