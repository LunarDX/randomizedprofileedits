
# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.Synopsis
Updates the alert rule.
.Description
Updates the alert rule.

.Link
https://learn.microsoft.com/powershell/module/az.securityinsights/Update-azsentinelalertrule
#>
function Update-AzSentinelAlertRule {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.AlertRule])]
    [CmdletBinding(DefaultParameterSetName = 'UpdateScheduled', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(ParameterSetName = 'UpdateFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # Gets subscription credentials which uniquely identify Microsoft Azure subscription.
        # The subscription ID forms part of the URI for every service call.
        ${SubscriptionId},
        
        [Parameter(ParameterSetName = 'UpdateFusionMLTI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateNRT', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateScheduled', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [System.String]
        # The Resource Group Name.
        ${ResourceGroupName},

        [Parameter(ParameterSetName = 'UpdateFusionMLTI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateNRT', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateScheduled', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [System.String]
        # The name of the workspace.
        ${WorkspaceName},

        [Parameter(ParameterSetName = 'UpdateFusionMLTI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateNRT', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateScheduled', Mandatory)]
        #[Alias('RuleId')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [System.String]
        # The name of Operational Insights Resource Provider.
        ${RuleId},

        [Parameter(ParameterSetName = 'UpdateViaIdentityFusionMLTI', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled', Mandatory, ValueFromPipeline)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.ISecurityInsightsIdentity]
        # Identity Parameter
        # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
        ${InputObject},

        [Parameter(ParameterSetName = 'UpdateFusionMLTI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityFusionMLTI', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${FusionMLorTI},

        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${MicrosoftSecurityIncidentCreation},

        [Parameter(ParameterSetName = 'UpdateNRT', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${NRT},

        [Parameter(ParameterSetName = 'UpdateScheduled', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${Scheduled},

        [Parameter(ParameterSetName = 'UpdateFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AlertRuleTemplateName},
        
        [Parameter(ParameterSetName = 'UpdateFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${Enabled},

        [Parameter(ParameterSetName = 'UpdateFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityFusionMLTI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${Disabled},

        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Description},

        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String[]]
        ${DisplayNamesFilter},

        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String[]]
        ${DisplayNamesExcludeFilter},


        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.MicrosoftSecurityProductName])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.MicrosoftSecurityProductName]
        ${ProductFilter},
            
        [Parameter(ParameterSetName = 'UpdateMicrosoftSecurityIncidentCreation')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftSecurityIncidentCreation')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AlertSeverity[]]
        #High, Medium, Low, Informational
        ${SeveritiesFilter},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Query},
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${DisplayName},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = 'New-TimeSpan -Hours 5')]
        [System.TimeSpan]
        ${SuppressionDuration},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${SuppressionEnabled},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AlertSeverity])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AlertSeverity]
        ${Severity},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AttackTactic])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AttackTactic]
        [System.String[]]
        ${Tactic},
            
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${CreateIncident},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${GroupingConfigurationEnabled},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Switch]
        ${ReOpenClosedIncident},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = 'New-TimeSpan -Hours 5')]
        [System.TimeSpan]
        ${LookbackDuration},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = '"AllEntities"')]
        [ValidateSet('AllEntities', 'AnyAlert', 'Selected')]
        [System.String]
        ${MatchingMethod},
            
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AlertDetail])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.AlertDetail[]]
        ${GroupByAlertDetail}, 
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [string[]] 
        ${GroupByCustomDetail},
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.EntityMappingType])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.EntityMappingType[]]
        ${GroupByEntity},
    
        
        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        #'Account', 'Host', 'IP', 'Malware', 'File', 'Process', 'CloudApplication', 'DNS', 'AzureResource', 'FileHash', 'RegistryKey', 'RegistryValue', 'SecurityGroup', 'URL', 'Mailbox', 'MailCluster', 'MailMessage', 'SubmissionMail'
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.EntityMapping[]]
        ${EntityMapping},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AlertDescriptionFormat},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AlertDisplayNameFormat},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AlertSeverityColumnName},

        [Parameter(ParameterSetName = 'UpdateNRT')]
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityNRT')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AlertTacticsColumnName},


        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.TimeSpan]
        ${QueryFrequency},

        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.TimeSpan]
        ${QueryPeriod},

        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.TriggerOperator])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.TriggerOperator]
        ${TriggerOperator},
        
        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [int]
        ${TriggerThreshold},

        [Parameter(ParameterSetName = 'UpdateScheduled')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityUpdateScheduled')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.EventGroupingAggregationKind])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.EventGroupingAggregationKind]
        ${EventGroupingSettingAggregationKind},
            
        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command as a job
        ${AsJob},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Run the command asynchronously
        ${NoWait},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process {
        try {
            $null = $PSBoundParameters.Remove('FusionMLorTI')
            $null = $PSBoundParameters.Remove('MicrosoftSecurityIncidentCreation')
            $null = $PSBoundParameters.Remove('NRT')
            $null = $PSBoundParameters.Remove('Scheduled')
            #Handle Get
            $GetPSBoundParameters = @{}
            if($PSBoundParameters['InputObject']){
                $GetPSBoundParameters.Add('InputObject', $PSBoundParameters['InputObject'])
            }
            else {
                $GetPSBoundParameters.Add('ResourceGroupName', $PSBoundParameters['ResourceGroupName'])
                $GetPSBoundParameters.Add('WorkspaceName', $PSBoundParameters['WorkspaceName'])
                $GetPSBoundParameters.Add('RuleId', $PSBoundParameters['RuleId'])
            }
            $AlertRule = Az.SecurityInsights\Get-AzSentinelAlertRule @GetPSBoundParameters

            #Fusion
            if ($AlertRule.Kind -eq 'Fusion'){
                If($PSBoundParameters['AlertTemplateName']){
                    $AlertRule.AlertRuleTemplateName = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
            }
            #MSIC
            if($AlertRule.Kind -eq 'MicrosoftSecurityIncidentCreation'){
                If($PSBoundParameters['AlertRuleTemplateName']){
                    $AlertRule.AlertRuleTemplateName = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
                
                If($PSBoundParameters['Description']){
                    $AlertRule.Description = $PSBoundParameters['Description']
                    $null = $PSBoundParameters.Remove('Description')
                }
                
                If($PSBoundParameters['DisplayNamesFilter']){
                    $AlertRule.DisplayNamesFilter = $PSBoundParameters['DisplayNamesFilter']
                    $null = $PSBoundParameters.Remove('DisplayNamesFilter')
                }
                
                If($PSBoundParameters['DisplayNamesExcludeFilter']){
                    $AlertRule.DisplayNamesExcludeFilter = $PSBoundParameters['DisplayNamesExcludeFilter']
                    $null = $PSBoundParameters.Remove('DisplayNamesExcludeFilter')
                }
                
                If($PSBoundParameters['ProductFilter']){
                    $AlertRule.ProductFilter = $PSBoundParameters['ProductFilter']
                    $null = $PSBoundParameters.Remove('ProductFilter')
                }

                If($PSBoundParameters['SeveritiesFilter']){
                    $Parameter.SeveritiesFilter = $PSBoundParameters['SeveritiesFilter']
                    $null = $PSBoundParameters.Remove('SeveritiesFilter')
                }
            }
            #ML
            if ($AlertRule.Kind -eq 'MLBehaviorAnalytics'){
                If($PSBoundParameters['AlertRuleTemplateName']){
                    $AlertRule.AlertRuleTemplateName = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
            }

            #NRT
            if($AlertRule.Kind -eq 'NRT'){
                If($PSBoundParameters['AlertRuleTemplateName']){
                    $AlertRule.Enabled = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
                
                If($PSBoundParameters['Description']){
                    $AlertRule.Description = $PSBoundParameters['Description']
                    $null = $PSBoundParameters.Remove('Description')
                }
                
                If($PSBoundParameters['Query']){
                    $AlertRule.Query = $PSBoundParameters['Query']
                    $null = $PSBoundParameters.Remove('Query')
                }

                If($PSBoundParameters['DisplayName']){
                    $AlertRule.DisplayName = $PSBoundParameters['DisplayName']
                    $null = $PSBoundParameters.Remove('DisplayName')
                }

                If($PSBoundParameters['SuppressionDuration']){
                    $AlertRule.SuppressionDuration = $PSBoundParameters['SuppressionDuration']
                    $null = $PSBoundParameters.Remove('SuppressionDuration')
                }

                If($PSBoundParameters['SuppressionEnabled']){
                    $AlertRule.SuppressionEnabled = $true
                    $null = $PSBoundParameters.Remove('SuppressionEnabled')
                }
                else{
                    $AlertRule.SuppressionEnabled = $false
                }
                
                If($PSBoundParameters['Severity']){
                    $AlertRule.Severity = $PSBoundParameters['Severity']
                    $null = $PSBoundParameters.Remove('Severity')
                }
                
                If($PSBoundParameters['Tactic']){
                    $AlertRule.Tactic = $PSBoundParameters['Tactic']
                    $null = $PSBoundParameters.Remove('Tactic')
                }
                
                If($PSBoundParameters['IncidentConfigurationCreateIncident']){
                    $AlertRule.IncidentConfigurationCreateIncident = $true
                    $null = $PSBoundParameters.Remove('IncidentConfigurationCreateIncident')
                }
                else{
                    $AlertRule.IncidentConfigurationCreateIncident = $false
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.GroupingConfigurationEnabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                else{
                    $AlertRule.GroupingConfigurationEnabled = $false
                }
                
                If($PSBoundParameters['ReOpenClosedIncident']){
                    $AlertRule.GroupingConfigurationReOpenClosedIncident = $true
                    $null = $PSBoundParameters.Remove('ReOpenClosedIncident')
                }
                else{
                    $AlertRule.GroupingConfigurationReOpenClosedIncident = $false
                }
                
                If($PSBoundParameters['LookbackDuration']){
                    $AlertRule.GroupingConfigurationLookbackDuration = $PSBoundParameters['LookbackDuration']
                    $null = $PSBoundParameters.Remove('LookbackDuration')
                }

                If($PSBoundParameters['MatchingMethod']){
                    $AlertRule.GroupingConfigurationMatchingMethod = $PSBoundParameters['MatchingMethod']
                    $null = $PSBoundParameters.Remove('MatchingMethod')
                }

                If($PSBoundParameters['GroupByAlertDetail']){
                    $AlertRule.GroupingConfigurationGroupByAlertDetail = $PSBoundParameters['GroupByAlertDetail']
                    $null = $PSBoundParameters.Remove('GroupByAlertDetail')
                }

                If($PSBoundParameters['GroupByCustomDetail']){
                    $AlertRule.GroupingConfigurationGroupByCustomDetail = $PSBoundParameters['GroupByCustomDetail']
                    $null = $PSBoundParameters.Remove('GroupByCustomDetail')
                }
                
                If($PSBoundParameters['GroupByEntity']){
                    $AlertRule.GroupingConfigurationGroupByEntity = $PSBoundParameters['GroupByEntity']
                    $null = $PSBoundParameters.Remove('GroupByEntity')
                }

                If($PSBoundParameters['EntityMapping']){
                    $AlertRule.EntityMapping = $PSBoundParameters['EntityMapping']
                    $null = $PSBoundParameters.Remove('EntityMapping')
                }

                If($PSBoundParameters['AlertDescriptionFormat']){
                    $AlertRule.AlertDetailOverrideAlertDescriptionFormat = $PSBoundParameters['AlertDescriptionFormat']
                    $null = $PSBoundParameters.Remove('AlertDescriptionFormat')
                }

                If($PSBoundParameters['AlertDisplayNameFormat']){
                    $AlertRule.AlertDetailOverrideAlertDisplayNameFormat = $PSBoundParameters['AlertDisplayNameFormat']
                    $null = $PSBoundParameters.Remove('AlertDisplayNameFormat')
                }

                If($PSBoundParameters['AlertSeverityColumnName']){
                    $AlertRule.AlertDetailOverrideAlertSeverityColumnName = $PSBoundParameters['AlertSeverityColumnName']
                    $null = $PSBoundParameters.Remove('AlertSeverityColumnName')
                }

                If($PSBoundParameters['AlertTacticsColumnName']){
                    $AlertRule.AlertDetailOverrideAlertTacticsColumnName = $PSBoundParameters['AlertTacticsColumnName']
                    $null = $PSBoundParameters.Remove('AlertTacticsColumnName')
                }
                
            }
            #Scheduled
            if ($AlertRule.Kind -eq 'Scheduled'){
                If($PSBoundParameters['AlertRuleTemplateName']){
                    $AlertRule.Enabled = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }
                
                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
                
                If($PSBoundParameters['Description']){
                    $AlertRule.Description = $PSBoundParameters['Description']
                    $null = $PSBoundParameters.Remove('Description')
                }
                
                If($PSBoundParameters['Query']){
                    $AlertRule.Query = $PSBoundParameters['Query']
                    $null = $PSBoundParameters.Remove('Query')
                }

                If($PSBoundParameters['DisplayName']){
                    $AlertRule.DisplayName = $PSBoundParameters['DisplayName']
                    $null = $PSBoundParameters.Remove('DisplayName')
                }

                If($PSBoundParameters['SuppressionDuration']){
                    $AlertRule.SuppressionDuration = $PSBoundParameters['SuppressionDuration']
                    $null = $PSBoundParameters.Remove('SuppressionDuration')
                }

                If($PSBoundParameters['SuppressionEnabled']){
                    $AlertRule.SuppressionEnabled = $true
                    $null = $PSBoundParameters.Remove('SuppressionEnabled')
                }
                else{
                    $AlertRule.SuppressionEnabled = $false
                }
                
                If($PSBoundParameters['Severity']){
                    $AlertRule.Severity = $PSBoundParameters['Severity']
                    $null = $PSBoundParameters.Remove('Severity')
                }

                If($PSBoundParameters['Tactic']){
                    $AlertRule.Tactic = $PSBoundParameters['Tactic']
                    $null = $PSBoundParameters.Remove('Tactic')
                }
                
                If($PSBoundParameters['CreateIncident']){
                    $AlertRule.IncidentConfigurationCreateIncident = $true
                    $null = $PSBoundParameters.Remove('CreateIncident')
                }
                else{
                    $AlertRule.IncidentConfigurationCreateIncident = $false
                }
                
                If($PSBoundParameters['GroupingConfigurationEnabled']){
                    $AlertRule.GroupingConfigurationEnabled = $true
                    $null = $PSBoundParameters.Remove('GroupingConfigurationEnabled')
                }
                else{
                    $AlertRule.GroupingConfigurationEnabled = $false
                }
                
                If($PSBoundParameters['ReOpenClosedIncident']){
                    $AlertRule.GroupingConfigurationReOpenClosedIncident = $PSBoundParameters['ReOpenClosedIncident']
                    $null = $PSBoundParameters.Remove('ReOpenClosedIncident')
                }
                else{
                    $AlertRule.GroupingConfigurationReOpenClosedIncident = $false
                }
                
                If($PSBoundParameters['LookbackDuration']){
                    $AlertRule.GroupingConfigurationLookbackDuration = $PSBoundParameters['LookbackDuration']
                    $null = $PSBoundParameters.Remove('LookbackDuration')
                }

                If($PSBoundParameters['MatchingMethod']){
                    $AlertRule.GroupingConfigurationMatchingMethod = $PSBoundParameters['MatchingMethod']
                    $null = $PSBoundParameters.Remove('MatchingMethod')
                }

                If($PSBoundParameters['GroupByAlertDetail']){
                    $AlertRule.GroupingConfigurationGroupByAlertDetail = $PSBoundParameters['GroupByAlertDetail']
                    $null = $PSBoundParameters.Remove('GroupByAlertDetail')
                }

                If($PSBoundParameters['GroupByCustomDetail']){
                    $AlertRule.GroupingConfigurationGroupByCustomDetail = $PSBoundParameters['GroupByCustomDetail']
                    $null = $PSBoundParameters.Remove('GroupByCustomDetail')
                }
                
                If($PSBoundParameters['GroupByEntity']){
                    $AlertRule.GroupingConfigurationGroupByEntity = $PSBoundParameters['GroupByEntity']
                    $null = $PSBoundParameters.Remove('GroupByEntity')
                }

                If($PSBoundParameters['EntityMapping']){
                    $AlertRule.EntityMapping = $PSBoundParameters['EntityMapping']
                    $null = $PSBoundParameters.Remove('EntityMapping')
                }

                If($PSBoundParameters['AlertDescriptionFormat']){
                    $AlertRule.AlertDetailOverrideAlertDescriptionFormat = $PSBoundParameters['AlertDescriptionFormat']
                    $null = $PSBoundParameters.Remove('AlertDescriptionFormat')
                }

                If($PSBoundParameters['AlertDisplayNameFormat']){
                    $AlertRule.AlertDetailOverrideAlertDisplayNameFormat = $PSBoundParameters['AlertDisplayNameFormat']
                    $null = $PSBoundParameters.Remove('AlertDisplayNameFormat')
                }

                If($PSBoundParameters['AlertSeverityColumnName']){
                    $AlertRule.AlertDetailOverrideAlertSeverityColumnName = $PSBoundParameters['AlertSeverityColumnName']
                    $null = $PSBoundParameters.Remove('AlertSeverityColumnName')
                }

                If($PSBoundParameters['AlertTacticsColumnName']){
                    $AlertRule.AlertDetailOverrideAlertTacticsColumnName = $PSBoundParameters['AlertTacticsColumnName']
                    $null = $PSBoundParameters.Remove('AlertTacticsColumnName')
                }

                If($PSBoundParameters['QueryFrequency']){
                    $AlertRule.QueryFrequency = $PSBoundParameters['QueryFrequency']
                    $null = $PSBoundParameters.Remove('QueryFrequency')
                }

                If($PSBoundParameters['QueryPeriod']){
                    $AlertRule.QueryPeriod = $PSBoundParameters['QueryPeriod']
                    $null = $PSBoundParameters.Remove('QueryPeriod')
                }

                If($PSBoundParameters['TriggerOperator']){
                    $AlertRule.TriggerOperator = $PSBoundParameters['TriggerOperator']
                    $null = $PSBoundParameters.Remove('TriggerOperator')
                }

                If($null -ne $PSBoundParameters['TriggerThreshold']){
                    $AlertRule.TriggerThreshold = $PSBoundParameters['TriggerThreshold']
                    $null = $PSBoundParameters.Remove('TriggerThreshold')
                }

                If($PSBoundParameters['EventGroupingSettingAggregationKind']){
                    $AlertRule.EventGroupingSettingAggregationKind = $PSBoundParameters['EventGroupingSettingAggregationKind']
                    $null = $PSBoundParameters.Remove('EventGroupingSettingAggregationKind')
                }
            }
            #TI
            if ($AlertRule.Kind -eq 'ThreatIntelligence'){
                If($PSBoundParameters['AlertRuleTemplateName']){
                    $AlertRule.AlertRuleTemplateName = $PSBoundParameters['AlertRuleTemplateName']
                    $null = $PSBoundParameters.Remove('AlertRuleTemplateName')
                }

                If($PSBoundParameters['Enabled']){
                    $AlertRule.Enabled = $true
                    $null = $PSBoundParameters.Remove('Enabled')
                }
                if($PSBoundParameters['Disabled']) {
                    $AlertRule.Enabled = $false
                    $null = $PSBoundParameters.Remove('Disabled')
                }
            }
            
            $null = $PSBoundParameters.Add('AlertRule', $AlertRule) 

            Az.SecurityInsights.internal\Update-AzSentinelAlertRule @PSBoundParameters
        }
        catch {
            throw
        }
    }
}

# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCABPsycJ7BsYY2E
# kLPOfFIMTvaLzczMlBCUSLq8EWnuQ6CCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHvL1/dnSgtlnyAvjmL+ba/3
# Cb7j+Qay4EsCYNCqSwfOMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAPLUrIZxhfD3OL8y3NQ8nGu2XNfha7Ex9TODzGGHuOZmRvXqizL0gin36
# xlAaZz9IASav0mUlHtmTjHqEA/NP9qRSRHefa5u2pgPsQLvRwT8bxzf4ZPmfQ1RS
# P9kIjqisTGs8Dtpd/XYG2AfVPOPi4I9R+GJAhYJ4+O4aCcgyTvYAR2FmvKLQeuIb
# 3pxIVA8LqIQUVphXt78A8h6Ek6y0ATAwD8vxnXtFA/NLZdV6RG2iavDWN9xIpsKz
# nNKsd4UJ0pyntsD9Mk/9AcxdPnjiBDBfjzdAA+e+8LDSrb2EK4bk3P7tXWRNVxOA
# JoZej2GFlUgDH6mRy5tLFqHp8Y93h6GCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCBR0Stt/UXLKOs6qip7ogMffARK0SlB/Ta3rvnYXMh2jwIGaMLIk0ed
# GBMyMDI1MTAwOTEyNDUwNy40MDJaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTkzNS0w
# M0UwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgy5ZOM1nOz0rgABAAACDDANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQz
# MDBaFw0yNjA0MjIxOTQzMDBaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046QTkzNS0wM0UwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDKAVYmPeRtga/U6jzqyqLD0MAool23gcBN58+Z/Xsk
# YwNJsZ+O+wVyQYl8dPTK1/BC2xAic1m+JvckqjVaQ32KmURsEZotirQY4PKVW+eX
# wRt3r6szgLuic6qoHlbXox/l0HJtgURkzDXWMkKmGSL7z8/crqcvmYqv8t/slAF4
# J+mpzb9tMFVmjwKXONVdRwg9Q3WaPZBC7Wvoi7PRIN2jgjSBnHYyAZSlstKNrpYb
# 6+Gu6oSFkQzGpR65+QNDdkP4ufOf4PbOg3fb4uGPjI8EPKlpwMwai1kQyX+fgcgC
# oV9J+o8MYYCZUet3kzhhwRzqh6LMeDjaXLP701SXXiXc2ZHzuDHbS/sZtJ3627cV
# pClXEIUvg2xpr0rPlItHwtjo1PwMCpXYqnYKvX8aJ8nawT9W8FUuuyZPG1852+q4
# jkVleKL7x+7el8ETehbdkwdhAXyXimaEzWetNNSmG/KfHAp9czwsL1vKr4Rgn+pI
# IkZHuomdf5e481K+xIWhLCPdpuV87EqGOK/jbhOnZEqwdvA0AlMaLfsmCemZmupe
# jaYuEk05/6cCUxgF4zCnkJeYdMAP+9Z4kVh7tzRFsw/lZSl2D7EhIA6Knj6RffH2
# k7YtSGSv86CShzfiXaz9y6sTu8SGqF6ObL/eu/DkivyVoCfUXWLjiSJsrS63D0EH
# HQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFHUORSH/sB/rQ/beD0l5VxQ706GIMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQDZMPr4gVmwwf4GMB5ZfHSr34uhug6yzu4H
# UT+JWMZqz9uhLZBoX5CPjdKJzwAVvYoNuLmS0+9lA5S74rvKqd/u9vp88VGk6U7g
# MceatdqpKlbVRdn2ZfrMcpI4zOc6BtuYrzJV4cEs1YmX95uiAxaED34w02BnfuPZ
# XA0edsDBbd4ixFU8X/1J0DfIUk1YFYPOrmwmI2k16u6TcKO0YpRlwTdCq9vO0eEI
# ER1SLmQNBzX9h2ccCvtgekOaBoIQ3ZRai8Ds1f+wcKCPzD4qDX3xNgvLFiKoA6ZS
# G9S/yOrGaiSGIeDy5N9VQuqTNjryuAzjvf5W8AQp31hV1GbUDOkbUdd+zkJWKX4F
# mzeeN52EEbykoWcJ5V9M4DPGN5xpFqXy9aO0+dR0UUYWuqeLhDyRnVeZcTEu0xgm
# o+pQHauFVASsVORMp8TF8dpesd+tqkkQ8VNvI20oOfnTfL+7ZgUMf7qNV0ll0Wo5
# nlr1CJva1bfk2Hc5BY1M9sd3blBkezyvJPn4j0bfOOrCYTwYsNsjiRl/WW18NOpi
# wqciwFlUNqtWCRMzC9r84YaUMQ82Bywk48d4uBon5ZA8pXXS7jwJTjJj5USeRl9v
# jT98PDZyCFO2eFSOFdDdf6WBo/WZUA2hGZ0q+J7j140fbXCfOUIm0j23HaAV0ckD
# S/nmC/oF1jCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkE5MzUtMDNFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDv
# u8hkhEMt5Z8Ldefls7z1LVU8pqCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7JIswjAiGA8yMDI1MTAwOTEyNDQ1
# MFoYDzIwMjUxMDEwMTI0NDUwWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDskizC
# AgEAMAoCAQACAhpJAgH/MAcCAQACAhNgMAoCBQDsk35CAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBAHg1BuApPW4kMJjaR5mUCCFOgd1NsAcrKT+I3U4sQyqC
# +PloX4+sJnBCmwQ9vRq4PUBOcUNX3wvwruKZjTJRSZ8ZyRP39vsAe3kOgE3jYiNK
# XfPTE+oDP0p8RaKCyfBvD7dwXlEOhLt39QtobbP0+mzawUkz4BMSLrIqREWlDgbV
# R3SvE+aRhGsPlAjT5914Fm7faDgWMJ7rn7JvmKDeyETXP1jDs1y76MsPmRFtvtnX
# lMw9fKoIJSYap3aHZx4SpitCMrY/99fI7BGW+2h2ZzAlCqujw02KVUSKhXM35AWD
# Vz8Qi8I0HYl1d5Z77mXkBQbRK/S1Dc/O/fJkssEXYTwxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgy5ZOM1nOz0rgABAAAC
# DDANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCBL0M39x26OFp8fllHXmso9hTz0TTUaqnQEfYf6VwDx
# zTCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EINUo17cFMZN46MI5NfIAg9Ux
# 5cO5xM9inre5riuOZ8ItMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIMuWTjNZzs9K4AAQAAAgwwIgQgYvnG3KK/83PE+wvpWmDvU6ra
# 5Ce8PVLjIdtNhMBXiDMwDQYJKoZIhvcNAQELBQAEggIABh/HqrFihJ0LRVBw10+t
# 52G5llVOefxxNk2/JR8qj+LriH9Zwdl+hGVkp6HP8UEGKhxo/u0KKacJ0Ctp2UDC
# DvHKvF3hVOlmP0KLViyGlbyck8qPpbCIg0v8Gmk7J+8yERYD2lB5HlhQNqXew4xJ
# 6PmsiOQj/ueVVtGRedhsA5S0ohkIL4lZwz5FXEEG25HgWokTZQSX/V6Zr+x4CgVI
# DrszkMhuN6TmcSxvpEaTrum7hfURMX21w7TvCR8WLSrQL8roRXEw49oDUTpPqY7x
# zdnV11kgm4pXiis9cXf1pahmbKJlNRKiLSUs2+gdp6VVDBPNfYpMA+1GC1mKtvf6
# nOWkpf91WWG0EFgZGOXmuG5hoJ9/TabqyBBuWw7F7W0hQSroAKk9Dk/Xd4VEGHsw
# 2/1w9EbRt2KFZEyJk+UIY/IlL45X9pkFvATG39M1ABVseanKUnFzZLoxrtzrpVmg
# Ex7SQAA42uOby0fPhDc8nQvS4fqKyLVAvtCr2kGIYhMf66BrTv3l+sDiq3ItR6Tf
# Sh4FPcxj9IVr2NOA2RnvaUvsu8Fb8G8+o7xTfIu1u3vSTGhAwO3vn1ktzpXxUERu
# 9BVi4ltxUjAbRmdvYVYWc6XYOvH21zGJQzfDiBy7AJ1Xgcppa8ojGiYalEFVam3y
# rlHocUPAM44tQJ0pswexW9g=
# SIG # End signature block
