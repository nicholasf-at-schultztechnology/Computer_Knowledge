function Get-SafeFileName {
    param (
        [string]$name
    )
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars() -join ''
    $safeName = $name -replace "[$invalidChars]", '_'
    return $safeName
}

# Define the root directory for the export
$ExportDir = "kubernetes-export"
New-Item -Path $ExportDir -ItemType Directory -Force | Out-Null

# Get all resource types that can be listed in the cluster
$resources = kubectl api-resources --verbs=list -o name

# Loop through each resource type
foreach ($resource in $resources) {
    # Create directory for the resource type
    $resourceDir = Join-Path $ExportDir $resource
    New-Item -Path $resourceDir -ItemType Directory -Force | Out-Null

    # Get all instances of the resource type across all namespaces in JSON
    $items = kubectl get $resource --all-namespaces -o json | ConvertFrom-Json

    # If there are items for this resource type
    if ($items.items.Count -gt 0) {
        foreach ($item in $items.items) {
            # Extract namespace and name for each resource
            $namespace = $item.metadata.namespace
            $name = $item.metadata.name

            # Define file name based on namespace and resource name
            if ($namespace) {
                $fileName = "$namespace`_$safeName.yaml"
            }
            else {
                $fileName = "$name.yaml"
            }
            
            # Set the file path for saving
            $filePath = Join-Path $resourceDir $fileName

            # Output the resource's YAML to the file
            $yaml = kubectl get $resource -n $namespace $name -o yaml
            $filePath = Get-SafeFileName -name $filePath
            Set-Content -Path $filePath -Value $yaml

            # Inform the user that the file was exported
            Write-Host "Exported $resource/$name to $filePath"
        }
    }
}
