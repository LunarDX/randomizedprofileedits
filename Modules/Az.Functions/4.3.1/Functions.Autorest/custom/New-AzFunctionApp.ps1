function New-AzFunctionApp {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.ISite])]
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.Description('Creates a function app.')]
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParametersetname="Consumption")]
    param(
        [Parameter(ParameterSetName="Consumption", HelpMessage='The Azure subscription ID.')]
        [Parameter(ParameterSetName="ByAppServicePlan")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${SubscriptionId},
        
        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The name of the resource group.')]
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan")]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [Parameter(Mandatory=$true, ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(Mandatory=$true, ParameterSetName="FlexConsumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${ResourceGroupName},
        
        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The name of the function app.')]
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan")]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [Parameter(Mandatory=$true, ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(Mandatory=$true,ParameterSetName="FlexConsumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${Name},
        
        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The name of the storage account.')]
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan")]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [Parameter(Mandatory=$true, ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(Mandatory=$true, ParameterSetName="FlexConsumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${StorageAccountName},

        [Parameter(ParameterSetName="Consumption", HelpMessage='Name of the existing App Insights project to be added to the function app.')]
        [Parameter(ParameterSetName="ByAppServicePlan")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [Alias("AppInsightsName")]
        ${ApplicationInsightsName},

        [Parameter(ParameterSetName="Consumption", HelpMessage='Instrumentation key of App Insights to be added.')]
        [Parameter(ParameterSetName="ByAppServicePlan")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [Alias("AppInsightsKey")]
        ${ApplicationInsightsKey},

        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The location for the consumption plan.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${Location},

        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan", HelpMessage='The name of the service plan.')]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${PlanName},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='The OS to host the function app.')]
        [Parameter(ParameterSetName="Consumption")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Functions.Support.WorkerType])]
        [ValidateSet("Linux", "Windows")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # OS type (Linux or Windows)
        ${OSType},
        
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan", HelpMessage='The function runtime.')]
        [Parameter(Mandatory=$true, ParameterSetName="Consumption")]
        [Parameter(Mandatory=$true, ParameterSetName="FlexConsumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # Runtime types are defined in HelperFunctions.ps1
        ${Runtime},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='The function runtime.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # RuntimeVersion types are defined in HelperFunctions.ps1
        ${RuntimeVersion},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='The Functions version.')]
        [Parameter(ParameterSetName="Consumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # FunctionsVersion types are defined in HelperFunctions.ps1
        ${FunctionsVersion},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Disable creating application insights resource during the function app creation. No logs will be available.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [System.Management.Automation.SwitchParameter]
        [Alias("DisableAppInsights")]
        ${DisableApplicationInsights},
        
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage", HelpMessage='Container image name, e.g., publisher/image-name:tag.')]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [Alias("DockerImageName")]
        ${Image},

        [Parameter(ParameterSetName="CustomDockerImage", HelpMessage='The container registry username and password. Required for private registries.')]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        [Alias("DockerRegistryCredential")]
        ${RegistryCredential},

        [Parameter(HelpMessage='Returns true when the command succeeds.')]
        [System.Management.Automation.SwitchParameter]
        ${PassThru},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Starts the operation and returns immediately, before the operation is completed. In order to determine if the operation has successfully been completed, use some other mechanism.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${NoWait},
        
        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Runs the cmdlet as a background job.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${AsJob},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Resource tags.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.Info(PossibleTypes=([Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.IResourceTags]))]
        [System.Collections.Hashtable]
        [ValidateNotNull()]
        ${Tag},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Function app settings.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        ${AppSetting},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage="Specifies the type of identity used for the function app.
            The acceptable values for this parameter are:
            - SystemAssigned
            - UserAssigned
            ")]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Functions.Support.FunctionAppManagedServiceIdentityCreateType])]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Support.ManagedServiceIdentityType]
        ${IdentityType},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage="Specifies the list of user identities associated with the function app.
            The user identity references will be ARM resource ids in the form:
            '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/identities/{identityName}'")]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Parameter(ParameterSetName="EnvironmentForContainerApp")]
        [Parameter(ParameterSetName="FlexConsumption")]
        [ValidateNotNull()]
        [System.String[]]
        ${IdentityID},

        [Parameter(Mandatory=$true,ParameterSetName="FlexConsumption", HelpMessage='Location to create Flex Consumption function app.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${FlexConsumptionLocation},

        [Parameter(ParameterSetName="FlexConsumption", HelpMessage='Name of deployment storage account to be used for function app artifacts.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${DeploymentStorageName},

        [Parameter(ParameterSetName="FlexConsumption", HelpMessage='Deployment storage container name.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${DeploymentStorageContainerName},

        [Parameter(ParameterSetName="FlexConsumption", HelpMessage='Deployment storage authentication type. Allowed values: StorageAccountConnectionString, SystemAssignedIdentity, UserAssignedIdentity')]
        [ValidateSet("StorageAccountConnectionString", "SystemAssignedIdentity", "UserAssignedIdentity")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${DeploymentStorageAuthType},

        [Parameter(ParameterSetName="FlexConsumption", HelpMessage='Deployment storage authentication value used for the chosen auth type (eg: connection string, or user-assigned identity resource id).')]
        [System.String]
        [ValidateNotNullOrEmpty()]
        ${DeploymentStorageAuthValue},

        [Parameter(ParameterSetName="FlexConsumption", HelpMessage=
'Array of hashtables describing the AlwaysReady configuration. Each hashtable must include:
- name: The function name or route name.
- instanceCount: The number of pre-warmed instances for that function.

Example:
@(@{ name = "http"; instanceCount = 2 }).')]
        [ValidateNotNullOrEmpty()]
        [Hashtable[]]
        ${AlwaysReady},

        [Parameter(ParameterSetName="FlexConsumption", HelpMessage='Maximum instance count for Flex Consumption.')]
        [ValidateRange(40, 1000)]
        [int]
        ${MaximumInstanceCount},

        [Parameter(ParameterSetName="FlexConsumption", HelpMessage='Per-instance memory in MB for Flex Consumption instances.')]
        [ValidateSet(512, 2048, 4096)]
        [int]
        ${InstanceMemoryMB},

        [Parameter(ParameterSetName="FlexConsumption", HelpMessage='The maximum number of concurrent HTTP trigger invocations per instance.')]
        [ValidateRange(1, 1000)]
        [int]
        ${HttpPerInstanceConcurrency},

        [Parameter(ParameterSetName="FlexConsumption", HelpMessage='Enable zone redundancy for high availability. Applies to Flex Consumption SKU only.')]
        [System.Management.Automation.SwitchParameter]
        ${EnableZoneRedundancy},

        [Parameter(Mandatory=$true, ParameterSetName="EnvironmentForContainerApp", HelpMessage='Name of the container app environment.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${Environment},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The workload profile name to run the container app on.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${WorkloadProfileName},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The CPU in cores of the container app. e.g., 0.75.')]
        [ValidateNotNullOrEmpty()]
        [Double]
        ${ResourceCpu},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The memory size of the container app. e.g., 1.0Gi.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${ResourceMemory},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The maximum number of replicas when creating a function app on container app.')]
        [ValidateScript({$_ -gt 0})]
        [Int]
        ${ScaleMaxReplica},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The minimum number of replicas when create function app on container app.')]
        [ValidateScript({$_ -gt 0})]
        [Int]
        ${ScaleMinReplica},

        [Parameter(Mandatory=$false, ParameterSetName="EnvironmentForContainerApp", HelpMessage='The container registry server hostname, e.g. myregistry.azurecr.io.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${RegistryServer},
        
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Azure')]
        [System.Management.Automation.PSObject]
        ${DefaultProfile},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process {

        RegisterFunctionsTabCompleters

        # Remove bound parameters from the dictionary that cannot be process by the intenal cmdlets.
        $paramsToRemove = @(
            "StorageAccountName",
            "ApplicationInsightsName",
            "ApplicationInsightsKey",
            "Location",
            "PlanName",
            "OSType",
            "Runtime",
            "DisableApplicationInsights",
            "Image",
            "RegistryCredential",
            "FunctionsVersion",
            "RuntimeVersion",
            "AppSetting",
            "IdentityType",
            "IdentityID",
            "Tag",
            "Environment",
            "RegistryServer",
            "WorkloadProfileName",
            "ResourceCpu",
            "ResourceMemory",
            "ScaleMaxReplica",
            "ScaleMinReplica",
            "FlexConsumptionLocation",
            "DeploymentStorageName",
            "DeploymentStorageContainerName",
            "DeploymentStorageAuthType",
            "DeploymentStorageAuthValue",
            "AlwaysReady",
            "MaximumInstanceCount",
            "InstanceMemoryMB",
            "HttpPerInstanceConcurrency",
            "EnableZoneRedundancy"
        )
        foreach ($paramName in $paramsToRemove)
        {
            if ($PSBoundParameters.ContainsKey($paramName))
            {
                $PSBoundParameters.Remove($paramName)  | Out-Null
            }
        }

        $functionAppIsCustomDockerImage = $PsCmdlet.ParameterSetName -eq "CustomDockerImage"
        $environmentForContainerApp = $PsCmdlet.ParameterSetName -eq "EnvironmentForContainerApp"
        $consumptionPlan = $PsCmdlet.ParameterSetName -eq "Consumption"
        $functionAppIsFlexConsumption = $PsCmdlet.ParameterSetName -eq "FlexConsumption"

        $flexConsumptionStorageContainerCreated = $false
        $flexConsumptionPlanCreated = $false
        $appInsightCreated = $false
        $functionAppCreatedSuccessfully = $false

        $appSettings = New-Object -TypeName System.Collections.Generic.List[System.Object]
        $siteConfig = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.SiteConfig
        $functionAppDef = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20231201.Site

        $OSIsLinux = ($OSType -eq "Linux") -or $functionAppIsFlexConsumption

        $params = GetParameterKeyValues -PSBoundParametersDictionary $PSBoundParameters `
                                        -ParameterList @("SubscriptionId", "HttpPipelineAppend", "HttpPipelinePrepend")

        ValidateFunctionAppNameAvailability -Name $Name @params

        $runtimeJsonDefinition = $null

        if (-not ($functionAppIsCustomDockerImage -or $environmentForContainerApp -or $functionAppIsFlexConsumption))
        {
            if (-not $FunctionsVersion)
            {
                $FunctionsVersion = $DefaultFunctionsVersion
                Write-Warning "FunctionsVersion not specified. Setting default value to '$FunctionsVersion'. $SetDefaultValueParameterWarningMessage"
            }

            ValidateFunctionsVersion -FunctionsVersion $FunctionsVersion

            if (-not $OSType)
            {
                $OSType = GetDefaultOSType -Runtime $Runtime
                Write-Warning "OSType not specified. Setting default value to '$OSType'. $SetDefaultValueParameterWarningMessage"
            }

            $runtimeJsonDefinition = GetStackDefinitionForRuntime -FunctionsVersion $FunctionsVersion -Runtime $Runtime -RuntimeVersion $RuntimeVersion -OSType $OSType

            if (-not $runtimeJsonDefinition)
            {
                $errorId = "FailedToGetRuntimeDefinition"
                $message += "Failed to get runtime definition for '$Runtime' version '$RuntimeVersion' in Functions version '$FunctionsVersion' on '$OSType'."
                $exception = [System.InvalidOperationException]::New($message)
                ThrowTerminatingError -ErrorId $errorId `
                                      -ErrorMessage $message `
                                      -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                      -Exception $exception

            }

            # Add app settings
            if ($runtimeJsonDefinition.AppSettingsDictionary.Count -gt 0)
            {
                foreach ($keyName in $runtimeJsonDefinition.AppSettingsDictionary.Keys)
                {
                    $value = $runtimeJsonDefinition.AppSettingsDictionary[$keyName]
                    $appSettings.Add((NewAppSetting -Name $keyName -Value $value))
                }
            }

            # Add site config properties
            if ($runtimeJsonDefinition.SiteConfigPropertiesDictionary.Count -gt 0)
            {
                foreach ($PropertyName in $runtimeJsonDefinition.SiteConfigPropertiesDictionary.Keys)
                {
                    $value = $runtimeJsonDefinition.SiteConfigPropertiesDictionary[$PropertyName]
                    $siteConfig.$PropertyName = $value
                }
            }
        }

        # Set function app managed identity
        if ($IdentityType)
        {
            $functionAppDef.IdentityType = $IdentityType

            if ($IdentityType -eq "UserAssigned")
            {
                # Set UserAssigned managed identiy
                if (-not $IdentityID)
                {
                    $errorMessage = "IdentityID is required for UserAssigned identity"
                    $exception = [System.InvalidOperationException]::New($errorMessage)
                    ThrowTerminatingError -ErrorId "IdentityIDIsRequiredForUserAssignedIdentity" `
                                            -ErrorMessage $errorMessage `
                                            -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                            -Exception $exception

                }

                $identityUserAssignedIdentity = NewIdentityUserAssignedIdentity -IdentityID $IdentityID
                $functionAppDef.IdentityUserAssignedIdentity = $identityUserAssignedIdentity
            }
        }

        $servicePlan = $null
        $dockerRegistryServerUrl = $null
        
        if ($consumptionPlan)
        {
            ValidateConsumptionPlanLocation -Location $Location -OSIsLinux:$OSIsLinux @params
            $functionAppDef.Location = $Location
        }
        elseif ($environmentForContainerApp)
        {
            $OSIsLinux = $true

            if (-not $Image)
            {
                Write-Warning "Image not specified. Setting default value to '$DefaultCentauriImage'."
                $Image = $DefaultCentauriImage
            }
            if ($RegistryServer)
            {
                $dockerRegistryServerUrl = $RegistryServer
            }

            if ($Environment -and $RegistryCredential)
            {
                # Error out if the user has specified both Environment and RegistryCredential and not provided RegistryServer.
                if (-not $RegistryServer)
                {
                    $errorMessage = "RegistryServer is required when Environment and RegistryCredential is specified."
                    $exception = [System.InvalidOperationException]::New($errorMessage)
                    ThrowTerminatingError -ErrorId "RegistryServerRequired" `
                                          -ErrorMessage $errorMessage `
                                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                          -Exception $exception
                }
            }
        }
        elseif ($PlanName)
        {
            # Host function app in Elastic Premium or app service plan
            $servicePlan = GetServicePlan $PlanName @params

            if ($null -ne $servicePlan.Location)
            {
                $Location = $servicePlan.Location
            }

            if ($null -ne $servicePlan.Reserved)
            {
                $OSIsLinux = $servicePlan.Reserved
            }

            $functionAppDef.ServerFarmId = $servicePlan.Id
            $functionAppDef.Location = $Location
        }

        if ($OSIsLinux)
        {
            # These are the scenarios we currently support when creating a Docker container:
            # 1) In Consumption, we only support images created by Functions with a predefine runtime name and version, e.g., Python 3.7
            # 2) For App Service and Premium plans, a customer can specify a customer container image

            # Linux function app
            $functionAppDef.Kind = 'functionapp,linux'
            $functionAppDef.Reserved = $true

            # Bring your own container is only supported on App Service, Premium plans and Container App
            if ($Image)
            {
                $functionAppDef.Kind = 'functionapp,linux,container'

                $appSettings.Add((NewAppSetting -Name 'DOCKER_CUSTOM_IMAGE_NAME' -Value $Image.Trim().ToLower()))
                $appSettings.Add((NewAppSetting -Name 'FUNCTION_APP_EDIT_MODE' -Value 'readOnly'))
                $appSettings.Add((NewAppSetting -Name 'WEBSITES_ENABLE_APP_SERVICE_STORAGE' -Value 'false'))

                $siteConfig.LinuxFxVersion = FormatFxVersion -Image $Image

                # Parse the docker registry url only for the custom image parameter set (otherwise it will be a breaking change for existing customers).
                # For the container app environment, the registry url must me explicitly provided.
                if (-not $dockerRegistryServerUrl -and -not $environmentForContainerApp)
                {
                    $dockerRegistryServerUrl = ParseDockerImage -DockerImageName $Image
                }

                if ($dockerRegistryServerUrl)
                {
                    $appSettings.Add((NewAppSetting -Name 'DOCKER_REGISTRY_SERVER_URL' -Value $dockerRegistryServerUrl))

                    if ($RegistryCredential)
                    {
                        $appSettings.Add((NewAppSetting -Name 'DOCKER_REGISTRY_SERVER_USERNAME' -Value $RegistryCredential.GetNetworkCredential().UserName))
                        $appSettings.Add((NewAppSetting -Name 'DOCKER_REGISTRY_SERVER_PASSWORD' -Value $RegistryCredential.GetNetworkCredential().Password))
                    }
                }
            }
            else
            {
                if (-not $functionAppIsFlexConsumption)
                {
                    $appSettings.Add((NewAppSetting -Name 'WEBSITES_ENABLE_APP_SERVICE_STORAGE' -Value 'true'))
                }
            }
        }
        else
        {
            # Windows function app
            $functionAppDef.Kind = 'functionapp'
        }

        if ($environmentForContainerApp)
        {
            $functionAppDef.Kind = 'functionapp,linux,container,azurecontainerapps'
            $functionAppDef.Reserved = $null
            $functionAppDef.HttpsOnly = $null
            $functionAppDef.ScmSiteAlsoStopped = $null

            ValidateCpuAndMemory -ResourceCpu $ResourceCpu -ResourceMemory $ResourceMemory
            if ($ResourceCpu -and $ResourceMemory)
            {
                $functionAppDef.ResourceConfigCpu = $ResourceCpu
                $functionAppDef.ResourceConfigMemory = $ResourceMemory
            }

            if ($WorkloadProfileName)
            {
                $functionAppDef.WorkloadProfileName = $WorkloadProfileName
            }

            $siteConfig.netFrameworkVersion = $null
            $siteConfig.JavaVersion = $null
            $siteConfig.Use32BitWorkerProcess = $null
            $siteConfig.PowerShellVersion = $null
            $siteConfig.Http20Enabled = $null
            $siteConfig.LocalMySqlEnabled = $null

            if ($ScaleMinReplica)
            {
                $siteConfig.MinimumElasticInstanceCount = $ScaleMinReplica
            }

            if ($ScaleMaxReplica)
            {
                $siteConfig.FunctionAppScaleLimit = $ScaleMaxReplica
            }
            
            $managedEnvironment = GetManagedEnvironment -Environment $Environment -ResourceGroupName $ResourceGroupName
            $functionAppDef.Location = $managedEnvironment.Location
            $functionAppDef.ManagedEnvironmentId = $managedEnvironment.Id
        }

        try
        {
            if ($functionAppIsFlexConsumption)
            {
                # Reset properties not applicable for Flex Consumption
                $siteConfig.NetFrameworkVersion = $null
                $functionAppDef.Reserved = $null
                $functionAppDef.IsXenon = $null
                $appSettings.Clear()

                # Validate Flex Consumption location
                Validate-FlexConsumptionLocation -Location $FlexConsumptionLocation -ZoneRedundancy:$EnableZoneRedundancy
                $FlexConsumptionLocation = Format-FlexConsumptionLocation -Location $FlexConsumptionLocation

                # Validate runtime and runtime version
                if (-not ($FlexConsumptionSupportedRuntimes -contains $Runtime))
                {
                    $errorId = "InvalidRuntimeForFlexConsumption"
                    $message += "The specified Runtime '$Runtime' is not valid for Flex Consumption. "
                    $message += "Supported runtimes are: $($FlexConsumptionSupportedRuntimes -join ', '). Learn more about supported runtimes and versions for Flex Consumption: aka.ms/FunctionsStackUpgrade."
                    $exception = [System.InvalidOperationException]::New($message)
                    ThrowTerminatingError -ErrorId $errorId `
                                          -ErrorMessage $message `
                                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                          -Exception $exception
                }

                $runtimeInfo = $null
                $hasDefaultVersion = $false

                if ([string]::IsNullOrEmpty($RuntimeVersion))
                {
                    $runtimeInfo = Get-FlexFunctionAppRuntime -Location $FlexConsumptionLocation -Runtime $Runtime -DefaultOrLatest:$true
                    $hasDefaultVersion = $true

                    $RuntimeVersion = $runtimeInfo.Version
                    Write-Warning "RuntimeVersion not specified. Setting default value to '$RuntimeVersion'. $SetDefaultValueParameterWarningMessage"
                }
                else
                {
                    # Get runtime info for specified version. If not available, Get-FlexFunctionAppRuntime will error out.
                    $runtimeInfo =  Get-FlexFunctionAppRuntime -Location $FlexConsumptionLocation -Runtime $Runtime -Version $RuntimeVersion
                }

                # Validate EndOfLifeDate
                if ($runtimeInfo.EndOfLifeDate -and (-not $hasDefaultVersion))
                {
                    $defaultRuntimeInfo = Get-FlexFunctionAppRuntime -Location $FlexConsumptionLocation -Runtime $Runtime -DefaultOrLatest:$true

                    Validate-EndOfLifeDate -EndOfLifeDate $runtimeInfo.EndOfLifeDate `
                                           -Runtime $Runtime `
                                           -RuntimeVersion $RuntimeVersion `
                                           -DefaultRuntimeVersion $defaultRuntimeInfo.Version
                }

                # Validate and set AlwaysReady configuration
                if ($AlwaysReady -and $AlwaysReady.Count -gt 0)
                {
                    $ALWAYSREADY_NAME = 'name'
                    $ALWAYSREADY_INSTANCECOUNT = 'instanceCount'

                    foreach ($entry in $AlwaysReady)
                    {
                        # Ensure required keys exist
                        if (-not ($entry.ContainsKey($ALWAYSREADY_NAME) -and $entry.ContainsKey($ALWAYSREADY_INSTANCECOUNT)))
                        {
                            $errorMessage = "Each hashtable in AlwaysReady must contain '$ALWAYSREADY_NAME' and '$ALWAYSREADY_INSTANCECOUNT' keys."
                            $exception = [System.InvalidOperationException]::New($errorMessage)
                            ThrowTerminatingError -ErrorId "InvalidAlwaysReadyConfiguration" `
                                                  -ErrorMessage $errorMessage `
                                                  -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                                  -Exception $exception
                        }

                        # Validate that Name is a non-empty string
                        if ([string]::IsNullOrWhiteSpace($entry[$ALWAYSREADY_NAME]))
                        {
                            $errorMessage = "Name in AlwaysReady must be a non-empty string."
                            $exception = [System.InvalidOperationException]::New($errorMessage)
                            ThrowTerminatingError -ErrorId "InvalidAlwaysReadyName" `
                                                    -ErrorMessage $errorMessage `
                                                    -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                                    -Exception $exception
                        }

                        # Validate InstanceCount is a non-negative integer (single-parse + combined check)
                        [int]$parsedInstanceCount = 0
                        $rawInstanceCount = $entry[$ALWAYSREADY_INSTANCECOUNT]

                        if (-not ([int]::TryParse($rawInstanceCount, [ref]$parsedInstanceCount) -and $parsedInstanceCount -ge 0))
                        {
                            $errorMessage = "InstanceCount in AlwaysReady must be a non-negative integer."
                            $exception    = [System.InvalidOperationException]::new($errorMessage)
                            ThrowTerminatingError -ErrorId "InvalidAlwaysReadyInstanceCount" `
                                                  -ErrorMessage $errorMessage `
                                                  -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                                  -Exception $exception
                        }
                    }
                    $functionAppDef.ScaleAndConcurrencyAlwaysReady = $AlwaysReady
                }

                # Set scaling information
                $maximumInstanceCountValue = Validate-MaximumInstanceCount -SkuMaximumInstanceCount $runtimeInfo.Sku.maximumInstanceCount -MaximumInstanceCount $MaximumInstanceCount 
                $functionAppDef.ScaleAndConcurrencyMaximumInstanceCount = $maximumInstanceCountValue

                $instanceMemoryMBValue = Validate-InstanceMemoryMB -SkuInstanceMemoryMB $runtimeInfo.Sku.instanceMemoryMB -InstanceMemoryMB $InstanceMemoryMB
                $functionAppDef.ScaleAndConcurrencyInstanceMemoryMB = $instanceMemoryMBValue

                if ($HttpPerInstanceConcurrency -gt 0)
                {
                    $functionAppDef.HttpPerInstanceConcurrency = $HttpPerInstanceConcurrency
                }

                # Create Flex Consumption App Service Plan
                $planName = New-PlanName -ResourceGroupName $ResourceGroupName
                if ($WhatIfPreference.IsPresent)
                {
                    Write-Verbose "WhatIf: Creating Flex Consumption App Service Plan '$planName' in resource group '$ResourceGroupName' at location '$FlexConsumptionLocation'..."
                    $planInfo = New-Object PSObject -Property @{
                        Id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/serverfarms/$planName"
                    }
                }
                else
                {
                    $planInfo = New-FlexConsumptionAppPlan -Name $PlanName `
                                                           -ResourceGroupName $ResourceGroupName `
                                                           -Location $FlexConsumptionLocation `
                                                           -EnableZoneRedundancy:$EnableZoneRedundancy `
                                                           @params
                    $flexConsumptionPlanCreated = $true
                }

                $functionAppDef.ServerFarmId = $planInfo.Id
                $functionAppDef.Location = $FlexConsumptionLocation

                # Validate Deployment Storage
                if (-not $DeploymentStorageName) {
                    $DeploymentStorageName = $StorageAccountName
                }

                if (-not $DeploymentStorageContainerName)
                {
                    $useTestData = ($env:FunctionsTestMode -and $env:FunctionsUseFlexStackTestData)
                    # Generate a unique container name
                    $tempName = $Name -replace '[^a-zA-Z0-9]', ''
                    $normalizedName = $tempName.Substring(0, [Math]::Min(32, $tempName.Length))
                    $normalizedName = $normalizedName.ToLower()

                    if ($useTestData)
                    {
                        $randomSuffix = 0
                    }
                    else
                    {
                        $randomSuffix = Get-Random -Minimum 0 -Maximum 9999999
                    }

                    $DeploymentStorageContainerName = "app-package-$normalizedName-{0:D7}" -f $randomSuffix

                    if ($useTestData)
                    {
                        Write-Verbose "Setting DeploymentStorageContainerName to: '$DeploymentStorageContainerName'." -Verbose
                    }
                }

                $StorageAccountInfo = Get-StorageAccountInfo -Name $DeploymentStorageName @params

                # If container does not exist, create it
                $container = Az.Functions.internal\Get-AzBlobContainer -ContainerName $DeploymentStorageContainerName `
                                                                       -AccountName $DeploymentStorageName `
                                                                       -ResourceGroupName $ResourceGroupName `
                                                                       -ErrorAction SilentlyContinue `
                                                                       @params
                if (-not $container)
                {
                    if ($WhatIfPreference.IsPresent)
                    {
                        Write-Verbose "WhatIf: Creating container '$DeploymentStorageContainerName' in storage account '$DeploymentStorageName'..."
                        $container = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20190401.BlobContainer
                    }
                    else
                    {
                        # Create blob container
                        $maxNumberOfTries = 3
                        $tries = 1
                        $myError = $null
                        while ($true)
                        {
                            try
                            {
                                $container = Az.Functions.internal\New-AzBlobContainer -ContainerName $DeploymentStorageContainerName `
                                                                                       -AccountName $DeploymentStorageName `
                                                                                       -ResourceGroupName $ResourceGroupName `
                                                                                       -ContainerPropertyPublicAccess None `
                                                                                       -ErrorAction Stop `
                                                                                       @params
                                if ($container)
                                {
                                    $flexConsumptionStorageContainerCreated = $true
                                    break
                                }
                            }
                            catch
                            {
                                # Ignore the failure and continue
                                $myError = $_
                            }

                            if ($tries -ge $maxNumberOfTries)
                            {
                                break
                            }

                            # Wait for 2^(tries-1) seconds between retries. In this case, it would be 1, 2, and 4 seconds, respectively.
                            $waitInSeconds = [Math]::Pow(2, $tries - 1)
                            Start-Sleep -Seconds $waitInSeconds

                            $tries++
                        }

                        if (-not $container)
                        {
                            $errorMessage = "Failed to create blob container '$DeploymentStorageContainerName' in storage account '$DeploymentStorageName'."
                            if ($myError.Exception.Message)
                            {
                                $errorMessage += " Error details: $($myError.Exception.Message)"
                            }

                            $exception = [System.InvalidOperationException]::New($errorMessage)
                            ThrowTerminatingError -ErrorId "FailedToCreateBlobContainer" `
                                                  -ErrorMessage $errorMessage `
                                                  -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                                  -Exception $exception
                        }
                    }
                }

                # Set storage type and value
                $blobContainerUrl = "$($StorageAccountInfo.PrimaryEndpointBlob)$DeploymentStorageContainerName"
                $functionAppDef.StorageType = "blobContainer"
                $functionAppDef.StorageValue = $blobContainerUrl

                # Validate DeploymentStorageAuthType
                if (-not $DeploymentStorageAuthType)
                {
                    $DeploymentStorageAuthType = 'StorageAccountConnectionString'
                }

                $functionAppDef.AuthenticationType = $DeploymentStorageAuthType

                # Set deployment storage authentication
                if ($DeploymentStorageAuthType -eq "SystemAssignedIdentity")
                {
                    if ($DeploymentStorageAuthValue)
                    {
                        $errorMessage = "-DeploymentStorageAuthValue is only valid when -DeploymentStorageAuthType is UserAssignedIdentity or StorageAccountConnectionString."
                        $exception = [System.InvalidOperationException]::New($errorMessage)
                        ThrowTerminatingError -ErrorId $errorId `
                                            -ErrorMessage $errorMessage `
                                            -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                            -Exception $exception
                    }
                }
                elseif ($DeploymentStorageAuthType -eq "StorageAccountConnectionString")
                {
                    if (-not $DeploymentStorageAuthValue)
                    {
                        # Get connection string for deployment storage
                        $DeploymentStorageAuthValue = GetConnectionString -StorageAccountName $DeploymentStorageName @params
                    }

                    $DEPLOYMENT_STORAGE_CONNECTION_STRING = 'DEPLOYMENT_STORAGE_CONNECTION_STRING'

                    $functionAppDef.AuthenticationStorageAccountConnectionStringName = $DEPLOYMENT_STORAGE_CONNECTION_STRING
                    $appSettings.Add((NewAppSetting -Name $DEPLOYMENT_STORAGE_CONNECTION_STRING -Value $DeploymentStorageAuthValue))
                }
                elseif ($DeploymentStorageAuthType -eq "UserAssignedIdentity")
                {
                    if (-not $DeploymentStorageAuthValue)
                    {
                        $errorMessage = "IdentityID is required for UserAssigned identity"
                        $exception = [System.InvalidOperationException]::New($errorMessage)
                        ThrowTerminatingError -ErrorId "IdentityIDIsRequiredForUserAssignedIdentity" `
                                                -ErrorMessage $errorMessage `
                                                -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                                -Exception $exception
                    }

                    $identity = Resolve-UserAssignedIdentity -IdentityResourceId $DeploymentStorageAuthValue @params
                    $functionAppDef.AuthenticationUserAssignedIdentityResourceId = $identity.Id
                }

                # Set runtime information
                $functionAppDef.RuntimeName = $runtimeInfo.Sku.functionAppConfigProperties.runtime.name
                $functionAppDef.RuntimeVersion = $runtimeInfo.Sku.functionAppConfigProperties.runtime.version
            }

            # Validate storage account and get connection string
            $connectionString = GetConnectionString -StorageAccountName $StorageAccountName @params
            $appSettings.Add((NewAppSetting -Name 'AzureWebJobsStorage' -Value $connectionString))

            if (-not ($functionAppIsCustomDockerImage -or $environmentForContainerApp -or $functionAppIsFlexConsumption))
            {
                $appSettings.Add((NewAppSetting -Name 'FUNCTIONS_EXTENSION_VERSION' -Value "~$FunctionsVersion"))
            }

            # If plan is not consumption, elastic premium or a container app environment, set always on
            $planIsElasticPremium = $servicePlan.SkuTier -eq 'ElasticPremium'
            if ((-not $consumptionPlan) -and (-not $planIsElasticPremium) -and (-not $Environment) -and (-not $functionAppIsFlexConsumption))
            {
                $siteConfig.AlwaysOn = $true
            }

            # If plan is Elastic Premium or Consumption (Windows or Linux), we need these app settings
            if ($planIsElasticPremium -or $consumptionPlan)
            {
                $appSettings.Add((NewAppSetting -Name 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING' -Value $connectionString))

                $shareName = GetShareName -FunctionAppName $Name
                $appSettings.Add((NewAppSetting -Name 'WEBSITE_CONTENTSHARE' -Value $shareName))
            }

            # Set up Dashboard if no ApplicationInsights
            if ($DisableApplicationInsights -and (-not $functionAppIsFlexConsumption))
            {
                $appSettings.Add((NewAppSetting -Name 'AzureWebJobsDashboard' -Value $connectionString))
            }

            # Set up Application Insights
            if (-not $DisableApplicationInsights)
            {
                if ($ApplicationInsightsKey)
                {
                    $appSettings.Add((NewAppSetting -Name 'APPINSIGHTS_INSTRUMENTATIONKEY' -Value $ApplicationInsightsKey))
                }
                elseif ($ApplicationInsightsName)
                {
                    $appInsightsProject = GetApplicationInsightsProject -Name $ApplicationInsightsName @params
                    if (-not $appInsightsProject)
                    {
                        $errorMessage = "Failed to get application insights project name '$ApplicationInsightsName'. Please make sure the project exist."
                        $exception = [System.InvalidOperationException]::New($errorMessage)
                        ThrowTerminatingError -ErrorId "ApplicationInsightsProjectNotFound" `
                                            -ErrorMessage $errorMessage `
                                            -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                            -Exception $exception
                    }

                    $appSettings.Add((NewAppSetting -Name 'APPLICATIONINSIGHTS_CONNECTION_STRING' -Value $appInsightsProject.ConnectionString))
                }
                else
                {
                    if ($WhatIfPreference.IsPresent)
                    {
                        Write-Verbose "WhatIf: Creating Application Insights '$Name' in resource group '$ResourceGroupName' at location '$($functionAppDef.Location)'..."
                        # Create a mock object for WhatIf to avoid null reference issues
                        $newAppInsightsProject = New-Object PSObject -Property @{
                            ConnectionString = "InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://placeholder.applicationinsights.azure.com/"
                            Name = $Name
                        }
                        $appSettings.Add((NewAppSetting -Name 'APPLICATIONINSIGHTS_CONNECTION_STRING' -Value $newAppInsightsProject.ConnectionString))
                    }
                    else
                    {
                        # Create the Application Insights project
                        $newAppInsightsProject = CreateApplicationInsightsProject -ResourceGroupName $resourceGroupName `
                                                                                  -ResourceName $Name `
                                                                                  -Location $functionAppDef.Location `
                                                                                  @params
                        if ($newAppInsightsProject)
                        {
                            $appSettings.Add((NewAppSetting -Name 'APPLICATIONINSIGHTS_CONNECTION_STRING' -Value $newAppInsightsProject.ConnectionString))
                            $appInsightCreated = $true
                        }
                        else
                        {
                            $warningMessage = "Unable to create the Application Insights for the function app. Creation of Application Insights will help you monitor and diagnose your function apps in the Azure Portal. `r`n"
                            $warningMessage += "Use the 'New-AzApplicationInsights' cmdlet or the Azure Portal to create a new Application Insights project. After that, use the 'Update-AzFunctionApp' cmdlet to update Application Insights for your function app."
                            Write-Warning $warningMessage
                        }
                    }
                }
            }

            if ($Tag.Count -gt 0)
            {
                $resourceTag = NewResourceTag -Tag $Tag
                $functionAppDef.Tag = $resourceTag
            }

            # Add user app settings
            if ($AppSetting.Count -gt 0)
            {
                foreach ($keyName in $AppSetting.Keys)
                {
                    $appSettings.Add((NewAppSetting -Name $keyName -Value $AppSetting[$keyName]))
                }
            }

            # Set app settings and site configuration
            $siteConfig.AppSetting = $appSettings
            $functionAppDef.Config = $siteConfig
            $PSBoundParameters.Add("SiteEnvelope", $functionAppDef)  | Out-Null

            if ($PsCmdlet.ShouldProcess($Name, "Creating function app"))
            {
                # Save the ErrorActionPreference
                $currentErrorActionPreference = $ErrorActionPreference
                $ErrorActionPreference = 'Stop'

                $exceptionThrown = $false

                try
                {
                    Az.Functions.internal\New-AzFunctionApp @PSBoundParameters
                    $functionAppCreatedSuccessfully = $true
                }
                catch
                {
                    $exceptionThrown = $true

                    $errorMessage = GetErrorMessage -Response $_

                    if ($errorMessage)
                    {
                        $exception = [System.InvalidOperationException]::New($errorMessage)
                        ThrowTerminatingError -ErrorId "FailedToCreateFunctionApp" `
                                                -ErrorMessage $errorMessage `
                                                -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                                -Exception $exception
                    }

                    throw $_
                }
                finally
                {
                    # Reset the ErrorActionPreference
                    $ErrorActionPreference = $currentErrorActionPreference
                }

                if (-not $exceptionThrown)
                {
                    if ($consumptionPlan -and $OSIsLinux)
                    {
                        $message = "Your Linux function app '$Name', that uses a consumption plan has been successfully created but is not active until content is published using Azure Portal or the Functions Core Tools."
                        Write-Verbose $message -Verbose
                    }
                }
            }
        }
        finally
        {
            # Cleanup created resources in case of failure
            if (-not $functionAppCreatedSuccessfully)
            {
                if ($flexConsumptionPlanCreated)
                {
                    Az.Functions\Remove-AzFunctionAppPlan -ResourceGroupName $ResourceGroupName -Name $planName @params -Force
                }
                if ($flexConsumptionStorageContainerCreated)
                {
                    Az.Functions.internal\Remove-AzBlobContainer -ResourceGroupName $ResourceGroupName -AccountName $DeploymentStorageName -ContainerName $DeploymentStorageContainerName @params
                }

                if ($appInsightCreated -and ($null -ne $newAppInsightsProject))
                {
                    $ApplicationInsightsName = $newAppInsightsProject.Name
                    Az.Functions.internal\Remove-AzAppInsights -ResourceGroupName $ResourceGroupName -ResourceName $ApplicationInsightsName @params
                }
            }
        }
    }
}

# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBbrg+xpx1VwgaG
# j15vRd3gncB02/BaNiINdcTm4gifAaCCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
# 7A5ZL83XAAAAAASFMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjUwNjE5MTgyMTM3WhcNMjYwNjE3MTgyMTM3WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDASkh1cpvuUqfbqxele7LCSHEamVNBfFE4uY1FkGsAdUF/vnjpE1dnAD9vMOqy
# 5ZO49ILhP4jiP/P2Pn9ao+5TDtKmcQ+pZdzbG7t43yRXJC3nXvTGQroodPi9USQi
# 9rI+0gwuXRKBII7L+k3kMkKLmFrsWUjzgXVCLYa6ZH7BCALAcJWZTwWPoiT4HpqQ
# hJcYLB7pfetAVCeBEVZD8itKQ6QA5/LQR+9X6dlSj4Vxta4JnpxvgSrkjXCz+tlJ
# 67ABZ551lw23RWU1uyfgCfEFhBfiyPR2WSjskPl9ap6qrf8fNQ1sGYun2p4JdXxe
# UAKf1hVa/3TQXjvPTiRXCnJPAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUuCZyGiCuLYE0aU7j5TFqY05kko0w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwNTM1OTAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBACjmqAp2Ci4sTHZci+qk
# tEAKsFk5HNVGKyWR2rFGXsd7cggZ04H5U4SV0fAL6fOE9dLvt4I7HBHLhpGdE5Uj
# Ly4NxLTG2bDAkeAVmxmd2uKWVGKym1aarDxXfv3GCN4mRX+Pn4c+py3S/6Kkt5eS
# DAIIsrzKw3Kh2SW1hCwXX/k1v4b+NH1Fjl+i/xPJspXCFuZB4aC5FLT5fgbRKqns
# WeAdn8DsrYQhT3QXLt6Nv3/dMzv7G/Cdpbdcoul8FYl+t3dmXM+SIClC3l2ae0wO
# lNrQ42yQEycuPU5OoqLT85jsZ7+4CaScfFINlO7l7Y7r/xauqHbSPQ1r3oIC+e71
# 5s2G3ClZa3y99aYx2lnXYe1srcrIx8NAXTViiypXVn9ZGmEkfNcfDiqGQwkml5z9
# nm3pWiBZ69adaBBbAFEjyJG4y0a76bel/4sDCVvaZzLM3TFbxVO9BQrjZRtbJZbk
# C3XArpLqZSfx53SuYdddxPX8pvcqFuEu8wcUeD05t9xNbJ4TtdAECJlEi0vvBxlm
# M5tzFXy2qZeqPMXHSQYqPgZ9jvScZ6NwznFD0+33kbzyhOSz/WuGbAu4cHZG8gKn
# lQVT4uA2Diex9DMs2WHiokNknYlLoUeWXW1QrJLpqO82TLyKTbBM/oZHAdIc0kzo
# STro9b3+vjn2809D0+SOOCVZMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAASFXpnsDlkvzdcAAAAABIUwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHECOJR8v4B746BgTULnOQl2
# xWUtW8pCoOu9CtDhyWzfMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAaBMzYQnvsCfr3UFZbhLp7hKiRzJiv2A91GWIUY1IzT3DBgPKqpJs+YMw
# vKdd6LDoNU5ZsG2zdhVTatZ0/6f2BVFceiy2Dc6Tjj9dZUOXRevBQx+CI+cIbRLf
# v9WiNQSaJOhHYofgqYr+Ea7SWwIV/j2h4Ov2M7t2WbUVI1IHS7FeolR/tbc04x+3
# wvzjvD0NzQKsG1KNlnxBU391022LxtvyJwurVsxQ6wIxNBK7eXia32dNbrDlJ4w2
# 8CJRNLNfDLmuCgBeSN4dfC1iE0ckvqZ5bdVjJ4FU7qQJQkghCfwxKO/RlMWoMzRk
# qnDsxZqHfNUad0SRJ0fHTSzk953Z96GCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCBYXVlky0xDGeRmpGNqWhxde9mbepbljG3Yms54blRMkgIGaW/ZuyU9
# GBMyMDI2MDEyNzA3NDAxMi4yNDZaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MzMwMy0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAg9XmkcUQOZG5gABAAACDzANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQz
# MDRaFw0yNjA0MjIxOTQzMDRaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MzMwMy0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCl6DTurxf66o73G0A2yKo1/nYvITBQsd50F52SQzo2
# cSrt+EDEFCDlSxZzWJD7ujQ1Z1dMbMT6YhK7JUvwxQ+LkQXv2k/3v3xw8xJ2mhXu
# wbT+s1WOL0+9g9AOEAAM6WGjCzI/LZq3/tzHr56in/Z++o/2soGhyGhKMDwWl4J4
# L1Fn8ndtoM1SBibPdqmwmPXpB9QtaP+TCOC1vAaGQOdsqXQ8AdlK6Vuk9yW9ty7S
# 0kRP1nXkFseM33NzBu//ubaoJHb1ceYPZ4U4EOXBHi/2g09WRL9QWItHjPGJYjuJ
# 0ckyrOG1ksfAZWP+Bu8PXAq4s1Ba/h/nXhXAwuxThpvaFb4T0bOjYO/h2LPRbdDM
# cMfS9Zbhq10hXP6ZFHR0RRJ+rr5A8ID9l0UgoUu/gNvCqHCMowz97udo7eWODA7L
# aVv81FHHYw3X5DSTUqJ6pwP+/0lxatxajbSGsm267zqVNsuzUoF2FzPM+YUIwiOp
# gQvvjYIBkB+KUwZf2vRIPWmhAEzWZAGTox/0vj4eHgxwER9fpThcsbZGSxx0nL54
# Hz+L36KJyEVio+oJVvUxm75YEESaTh1RnL0Dls91sBw6mvKrO2O+NCbUtfx+cQXY
# S0JcWZef810BW9Bn/eIvow3Kcx0dVuqDfIWfW7imeTLAK9QAEk+oZCJzUUTvhh2h
# YQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFJnUMQ2OtyAhLR/MD2qtJ9lKRP9ZMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQBTowbo1bUE7fXTy+uW9m58qGEXRBGVMEQi
# FEfSui1fhN7jS+kSiN0SR5Kl3AuV49xOxgHo9+GIne5Mpg5n4NS5PW8nWIWGj/8j
# kE3pdJZSvAZarXD4l43iMNxDhdBZqVCkAYcdFVZnxdy+25MRY6RfaGwkinjnYNFA
# 6DYL/1cxw6Ya4sXyV7FgPdMmxVpffnPEDFv4mcVx3jvPZod7gqiDcUHbyV1gaND3
# PejyJ1MGfBYbAQxsynLX1FUsWLwKsNPRJjynwlzBT/OQbxnzkjLibi4h4dOwcN+H
# 4myDtUSnYq9Xf4YvFlZ+mJs5Ytx4U9JVCyW/WERtIEieTvTRgvAYj/4Mh1F2Elf8
# cdILgzi9ezqYefxdsBD8Vix35yMC5LTnDUoyVVulUeeDAJY8+6YBbtXIty4phIki
# hiIHsyWVxW2YGG6A6UWenuwY6z9oBONvMHlqtD37ZyLn0h1kCkkp5kcIIhMtpzEc
# PkfqlkbDVogMoWy80xulxt64P4+1YIzkRht3zTO+jLONu1pmBt+8EUh7DVct/33t
# uW5NOSx56jXQ1TdOdFBpgcW8HvJii8smQ1TQP42HNIKIJY5aiMkK9M2HoxYrQy2M
# oHNOPySsOzr3le/4SDdX67uobGkUNerlJKzKpTR5ZU0SeNAu5oCyDb6gdtTiaN50
# lCC6m44sXjCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
# hvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# MjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAy
# MDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25Phdg
# M/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPF
# dvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6
# GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBp
# Dco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50Zu
# yjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3E
# XzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0
# lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1q
# GFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ
# +QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PA
# PBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkw
# EgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxG
# NSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARV
# MFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAK
# BggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvX
# zpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
# cGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
# KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG
# 9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0x
# M7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmC
# VgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449
# xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wM
# nosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDS
# PeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2d
# Y3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxn
# GSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+Crvs
# QWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokL
# jzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNQ
# MIICOAIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjMzMDMtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQBe
# tIzj2C/MkdiI03EyNsCtSOMdWqCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7SLo4zAiGA8yMDI2MDEyNzA3MzM1
# NVoYDzIwMjYwMTI4MDczMzU1WjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDtIujj
# AgEAMAoCAQACAiKYAgH/MAcCAQACAhM/MAoCBQDtJDpjAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBAEF7jm4dPPuqJ01LMah169ODWtFXON/u8XJL2BIiS8hj
# r5w3rMpcP+g6SV1N52KnegjHTJQwxQObgapPnqu3VwWhvhxz1ZVoGUwL53fLVk7u
# hjuDz+EATLJnoHhsrlPG3C9Jb0TQBk0ApTiyiTPgPjUfN9nZ+XuBZIQ+ZChy7AMn
# ph/bSYi+00CDwCqWtC2mQtsMmsv3kpUjF+1M1Wlm/KZedgOnpiBtcQ9SgX9ar+XO
# BLBNVg1Ap8JL4VxNd5BiFJIp3vrnoiYklgbGgJMBCTGrjG2n9Hygqub6wAkkpDK1
# HPqkcpAbIbaYsayOl+RLlDaJYmKr7HlIKT2E1jnYkfQxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAg9XmkcUQOZG5gABAAAC
# DzANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCBzhYD7beJkkHs8csPy7fjCH9rkxiO47330PLxO5WSv
# pjCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIN1Hd5UmKnm7FW7xP3niGsfH
# Jt4xR8Xu+MxgXXc0iqn4MIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIPV5pHFEDmRuYAAQAAAg8wIgQge/JnU6uxVm07iuw+6H8NSmKK
# rgPeANney7PToNM2MaEwDQYJKoZIhvcNAQELBQAEggIAj3EdIekXhmBtKcL0GrN8
# twuoQOJkqI6WXGAV1R7OAo37oWfYxPHcETwwd1pPLAqPw6NvHXYnbXd6udXTWAsx
# BvYHJUCnqmXc4gBXHIXmO2kGvEUcZTQg21B8vJL4Ga4Rte5wAKyumBPRvSBp1Hfd
# RzYIW+ShJRB3CQDMO8uNFbqCRS82cxaB/bfYuySDIXJm7NVXreYmUdk3FOZvaUMm
# rRSQdi6QV6u1rFnkazF0kLiL3PdtOZVzsPWRY9CDKmEwQCY/F3EgE2LZlSDWg4pU
# wFHX3z0FtkAcPdE0qa8TEngKZJhMNlyl9LvKzl4SVp7Bm5KWyyGribKM+edwOODV
# hww28QqULWg1FnGHFHXw33MvAN/Qw2kHUSaztKAaYrTAN5w9gCgkJz8hrgJpirS3
# /otX+jy6c7JRWx3v3UOhKiXgUqasENAJuY40xlleSlZ8T0Ej7KAGP0YpNttxnFT3
# C16bkHtK+N1YPbSYVtiJMtfT48AMobwD1FI5gadqBM+PMTepQdlpjScxclqx7jeF
# NMvTdtay/rqf8uqu53bRtcwHXuucPhAHG6U6eYloQy77xIDuRkLqcZaA6uv76mcW
# /nB8dvHOrUfcaTkUZieC6s52to98FnGsLiOXDLWk81izoDHIrGBio0Kb8etxWfqg
# oe6R1lSXLs3CYsgZRB39tqk=
# SIG # End signature block
