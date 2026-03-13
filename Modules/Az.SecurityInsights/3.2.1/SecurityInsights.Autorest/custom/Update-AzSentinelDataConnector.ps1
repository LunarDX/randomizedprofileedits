
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
Updates the data connector.
.Description
Updates the data connector.

.Link
https://learn.microsoft.com/powershell/module/az.securityinsights/update-azsentineldataconnector
#>
function Update-AzSentinelDataConnector {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.DataConnector])]
    [CmdletBinding(DefaultParameterSetName = 'UpdateAADAATP', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesCloudTrail')]
        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesS3')]
        [Parameter(ParameterSetName = 'UpdateAADAATP')]    
        [Parameter(ParameterSetName = 'UpdateAzureSecurityCenter')]
        [Parameter(ParameterSetName = 'UpdateDynamics365')]
        #[Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftCloudAppSecurity')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftDefenderAdvancedThreatProtection')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatProtection')]
        [Parameter(ParameterSetName = 'UpdateOffice365')]
        [Parameter(ParameterSetName = 'UpdateOfficeATP')]
        [Parameter(ParameterSetName = 'UpdateOfficeIRM')]
        [Parameter(ParameterSetName = 'UpdateThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # Gets subscription credentials which uniquely identify Microsoft Azure subscription.
        # The subscription ID forms part of the URI for every service call.
        ${SubscriptionId},

        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesCloudTrail', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesS3', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateAADAATP', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateAzureSecurityCenter', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateDynamics365', Mandatory)]
        #[Parameter(ParameterSetName = 'UpdateGenericUI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftCloudAppSecurity', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftDefenderAdvancedThreatProtection', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatIntelligence', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatProtection', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateOffice365', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateOfficeATP', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateOfficeIRM', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateThreatIntelligence', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [System.String]
        # The Resource Group Name.
        ${ResourceGroupName},

        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesCloudTrail', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesS3', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateAADAATP', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateAzureSecurityCenter', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateDynamics365', Mandatory)]
        #[Parameter(ParameterSetName = 'UpdateGenericUI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftCloudAppSecurity', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftDefenderAdvancedThreatProtection', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatIntelligence', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatProtection', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateOffice365', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateOfficeATP', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateOfficeIRM', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateThreatIntelligence', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [System.String]
        # The name of the workspace.
        ${WorkspaceName},

        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesCloudTrail', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesS3', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateAADAATP', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateAzureSecurityCenter', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateDynamics365', Mandatory)]
        #[Parameter(ParameterSetName = 'UpdateGenericUI', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftCloudAppSecurity', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftDefenderAdvancedThreatProtection', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatIntelligence', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatProtection', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateOffice365', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateOfficeATP', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateOfficeIRM', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateThreatIntelligence', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [System.String]
        # The Id of the Data Connector.
        ${Id},

        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesCloudTrail', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesS3', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAADAATP', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAzureSecurityCenter', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityDynamics365', Mandatory, ValueFromPipeline)]
        #[Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftCloudAppSecurity', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftDefenderAdvancedThreatProtection', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatIntelligence', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatProtection', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOffice365', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOfficeATP', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOfficeIRM', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligence', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligenceTaxii', Mandatory, ValueFromPipeline)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.ISecurityInsightsIdentity]
        # Identity Parameter
        # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
        ${InputObject},

        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesCloudTrail', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesCloudTrail', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${AWSCloudTrail},
        
        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesS3', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesS3', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${AWSS3},
        
        [Parameter(ParameterSetName = 'UpdateAADAATP', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAADAATP', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${AzureADorAATP},
        
        [Parameter(ParameterSetName = 'UpdateAzureSecurityCenter', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAzureSecurityCenter', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${AzureSecurityCenter},
        
        [Parameter(ParameterSetName = 'UpdateDynamics365', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityDynamics365', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${Dynamics365},
        
        #[Parameter(ParameterSetName = 'UpdateGenericUI', Mandatory)]
        #[Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI', Mandatory)]
        #[Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        #[System.Management.Automation.SwitchParameter]
        #${GenericUI},
        
        [Parameter(ParameterSetName = 'UpdateMicrosoftCloudAppSecurity', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftCloudAppSecurity', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${CloudAppSecurity},
        
        [Parameter(ParameterSetName = 'UpdateMicrosoftDefenderAdvancedThreatProtection', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftDefenderAdvancedThreatProtection', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${DefenderATP},

        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatIntelligence', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatIntelligence', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${MicrosoftTI},
        
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatProtection', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatProtection', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${MicrosoftThreatProtection},
        
        [Parameter(ParameterSetName = 'UpdateOffice365', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOffice365', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${Office365},
        
        [Parameter(ParameterSetName = 'UpdateOfficeATP', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOfficeATP', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${OfficeATP},
        
        [Parameter(ParameterSetName = 'UpdateOfficeIRM', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOfficeIRM', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${OfficeIRM},
        
        [Parameter(ParameterSetName = 'UpdateThreatIntelligence', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligence', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${ThreatIntelligence},
        
        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii', Mandatory)]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligenceTaxii', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${ThreatIntelligenceTaxii},

        [Parameter(ParameterSetName = 'UpdateAADAATP')]
        [Parameter(ParameterSetName = 'UpdateDynamics365')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftCloudAppSecurity')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftDefenderAdvancedThreatProtection')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatProtection')]
        [Parameter(ParameterSetName = 'UpdateOffice365')]
        [Parameter(ParameterSetName = 'UpdateOfficeATP')]
        [Parameter(ParameterSetName = 'UpdateOfficeIRM')]
        [Parameter(ParameterSetName = 'UpdateThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesCloudTrail')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesS3')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAADAATP')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAzureSecurityCenter')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityDynamics365')]
        #[Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftCloudAppSecurity')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftDefenderAdvancedThreatProtection')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatProtection')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOffice365')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOfficeATP')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOfficeIRM')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligenceTaxii')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = '(Get-AzContext).Tenant.Id')]
        [System.String]
        # The TenantId.
        ${TenantId},

        [Parameter(ParameterSetName = 'UpdateAzureSecurityCenter')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAzureSecurityCenter')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        # ASC Subscription Id.
        ${ASCSubscriptionId},

        [Parameter(ParameterSetName = 'UpdateAADAATP')]
        [Parameter(ParameterSetName = 'UpdateAzureSecurityCenter')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftCloudAppSecurity')]
        [Parameter(ParameterSetName = 'UpdateMicrosoftDefenderAdvancedThreatProtection')]
        [Parameter(ParameterSetName = 'UpdateOfficeATP')]
        [Parameter(ParameterSetName = 'UpdateOfficeIRM')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAADAATP')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAzureSecurityCenter')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftCloudAppSecurity')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftDefenderAdvancedThreatProtection')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOfficeATP')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOfficeIRM')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Alerts},

        [Parameter(ParameterSetName = 'UpdateDynamics365')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityDynamics365')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${CommonDataServiceActivity},

        [Parameter(ParameterSetName = 'UpdateMicrosoftCloudAppSecurity')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftCloudAppSecurity')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${DiscoveryLog},

        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatIntelligence')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${BingSafetyPhishinURL},

        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatIntelligence')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [ValidateSet('OneDay', 'OneWeek', 'OneMonth', 'All')]
        [System.String]
        ${BingSafetyPhishingUrlLookbackPeriod},

        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatIntelligence')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${MicrosoftEmergingThreatFeed},

        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatIntelligence')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [ValidateSet('OneDay', 'OneWeek', 'OneMonth', 'All')]
        [System.String]
        ${MicrosoftEmergingThreatFeedLookbackPeriod},

        [Parameter(ParameterSetName = 'UpdateMicrosoftThreatProtection')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityMicrosoftThreatProtection')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Incident},

        [Parameter(ParameterSetName = 'UpdateOffice365')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOffice365')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Exchange},

        [Parameter(ParameterSetName = 'UpdateOffice365')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOffice365')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${SharePoint},

        [Parameter(ParameterSetName = 'UpdateOffice365')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityOffice365')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Teams},

        [Parameter(ParameterSetName = 'UpdateThreatIntelligence')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligence')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Indicator},

        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligenceTaxii')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${WorkspaceId},

        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligenceTaxii')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${FriendlyName},

        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${APIRootURL},

        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligenceTaxii')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${CollectionId},

        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligenceTaxii')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${UserName},

        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligenceTaxii')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Password},

        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligenceTaxii')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [ValidateSet('OneDay', 'OneWeek', 'OneMonth', 'All')]
        [System.String]
        ${TaxiiLookbackPeriod},

        [Parameter(ParameterSetName = 'UpdateThreatIntelligenceTaxii')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityThreatIntelligenceTaxii')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.PollingFrequency])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.PollingFrequency]
        ${PollingFrequency},

        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesCloudTrail')]
        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesS3')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesCloudTrail')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesS3')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${AWSRoleArn},

        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesCloudTrail')]
        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesS3')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesCloudTrail')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesS3')]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Support.DataTypeState])]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${Log},

        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesS3')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesS3')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [String[]]
        ${SQSURL},

        [Parameter(ParameterSetName = 'UpdateAmazonWebServicesS3')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityAmazonWebServicesS3')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${DetinationTable},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${UiConfigTitle},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${UiConfigPublisher},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${UiConfigDescriptionMarkdown},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${UiConfigCustomImage},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [System.String]
        ${UiConfigGraphQueriesTableName},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.GraphQueries[]]
        ${UiConfigGraphQuery},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.SampleQueries[]]
        ${UiConfigSampleQuery},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.LastDataReceivedDataType[]]
        ${UiConfigDataType},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.ConnectivityCriteria[]]
        ${UiConfigConnectivityCriterion},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Bool]
        ${AvailabilityIsPreview},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Runtime.DefaultInfo(Script = 1)]
        [Int]
        ${AvailabilityStatus},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.PermissionsResourceProviderItem[]] 
        ${PermissionResourceProvider},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.PermissionsCustomsItem[]]
        ${PermissionCustom},

        [Parameter(ParameterSetName = 'UpdateGenericUI')]
        [Parameter(ParameterSetName = 'UpdateViaIdentityGenericUI')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Category('Body')]
        [Microsoft.Azure.PowerShell.Cmdlets.SecurityInsights.Models.Api20210901Preview.InstructionSteps[]]
        ${UiConfigInstructionStep},

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
            #Handle Get
            $GetPSBoundParameters = @{}
            if ($PSBoundParameters['InputObject']) {
                $GetPSBoundParameters.Add('InputObject', $PSBoundParameters['InputObject'])
            }
            else {
                $GetPSBoundParameters.Add('ResourceGroupName', $PSBoundParameters['ResourceGroupName'])
                $GetPSBoundParameters.Add('WorkspaceName', $PSBoundParameters['WorkspaceName'])
                $GetPSBoundParameters.Add('Id', $PSBoundParameters['Id'])
            }
            $DataConnector = Az.SecurityInsights\Get-AzSentinelDataConnector @GetPSBoundParameters


            if ($DataConnector.Kind -eq 'AzureActiveDirectory') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }
                If ($PSBoundParameters['Alerts']) {
                    $DataConnector.AlertState = $PSBoundParameters['Alerts']
                    $null = $PSBoundParameters.Remove('Alerts')
                }

                $null = $PSBoundParameters.Remove('AzureADorAATP')
            }
            if ($DataConnector.Kind -eq 'AzureAdvancedThreatProtection') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }
                If ($PSBoundParameters['Alerts']) {
                    $DataConnector.AlertState = $PSBoundParameters['Alerts']
                    $null = $PSBoundParameters.Remove('Alerts')
                }
                $null = $PSBoundParameters.Remove('AzureADorAATP')
            }
            if ($DataConnector.Kind -eq 'Dynamics365') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }

                If ($PSBoundParameters['CommonDataServiceActivity']) {
                    $DataConnector.Dynamics365CdActivityState = $PSBoundParameters['CommonDataServiceActivity']
                    $null = $PSBoundParameters.Remove('CommonDataServiceActivity')
                }
                $null = $PSBoundParameters.Remove('Dynamics365')
            }
            if ($DataConnector.Kind -eq 'MicrosoftCloudAppSecurity') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }

                If ($PSBoundParameters['Alerts']) {
                    $DataConnector.DataTypeAlertState = $PSBoundParameters['Alerts']
                    $null = $PSBoundParameters.Remove('Alerts')
                }

                If ($PSBoundParameters['DiscoveryLog']) {
                    $DataConnector.DiscoveryLogState = $PSBoundParameters['DiscoveryLog']
                    $null = $PSBoundParameters.Remove('DiscoveryLog')
                }
                $null = $PSBoundParameters.Remove('CloudAppSecurity')
            }
            if ($DataConnector.Kind -eq 'MicrosoftDefenderAdvancedThreatProtection') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }

                If ($PSBoundParameters['Alerts']) {
                    $DataConnector.AlertState = $PSBoundParameters['Alerts']
                    $null = $PSBoundParameters.Remove('Alerts')
                }
                $null = $PSBoundParameters.Remove('DefenderATP')
            }
            if ($DataConnector.Kind -eq 'MicrosoftThreatIntelligence') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }
                
                If ($PSBoundParameters['BingSafetyPhishinURL']) {
                    $DataConnector.BingSafetyPhishingUrlState = $PSBoundParameters['BingSafetyPhishinURL']
                    $null = $PSBoundParameters.Remove('BingSafetyPhishinURL')
                }

                If ($PSBoundParameters['BingSafetyPhishingUrlLookbackPeriod']) {
                    if ($PSBoundParameters['BingSafetyPhishingUrlLookbackPeriod'] -eq 'OneDay') {
                        $DataConnector.BingSafetyPhishingUrlLookbackPeriod = ((Get-Date).AddDays(-1).ToUniversalTime() | Get-DAte -Format yyyy-MM-ddTHH:mm:ss.fffZ).ToString()
                    }
                    elseif ($PSBoundParameters['BingSafetyPhishingUrlLookbackPeriod'] -eq 'OneWeek') {
                        $DataConnector.BingSafetyPhishingUrlLookbackPeriod = ((Get-Date).AddDays(-7).ToUniversalTime() | Get-DAte -Format yyyy-MM-ddTHH:mm:ss.fffZ).ToString()
                    }
                    elseif ($PSBoundParameters['BingSafetyPhishingUrlLookbackPeriod'] -eq 'OneMonth') {
                        $DataConnector.BingSafetyPhishingUrlLookbackPeriod = ((Get-Date).AddMonths(-1).ToUniversalTime() | Get-DAte -Format yyyy-MM-ddTHH:mm:ss.fffZ).ToString()
                    }
                    elseif ($PSBoundParameters['BingSafetyPhishingUrlLookbackPeriod'] -eq 'All') {
                        $DataConnector.BingSafetyPhishingUrlLookbackPeriod = "1970-01-01T00:00:00.000Z"
                    }
                    $null = $PSBoundParameters.Remove('BingSafetyPhishingUrlLookbackPeriod')
                }
                
                If ($PSBoundParameters['MicrosoftEmergingThreatFeed']) {
                    $DataConnector.MicrosoftEmergingThreatFeedState = $PSBoundParameters['MicrosoftEmergingThreatFeed']
                    $null = $PSBoundParameters.Remove('MicrosoftEmergingThreatFeed')
                }
                
                If ($PSBoundParameters['MicrosoftEmergingThreatFeedLookbackPeriod']) {
                    if ($PSBoundParameters['MicrosoftEmergingThreatFeedLookbackPeriod'] -eq 'OneDay') {
                        $DataConnector.MicrosoftEmergingThreatFeedLookbackPeriod = ((Get-Date).AddDays(-1).ToUniversalTime() | Get-DAte -Format yyyy-MM-ddTHH:mm:ss.fffZ).ToString()
                    }
                    elseif ($PSBoundParameters['MicrosoftEmergingThreatFeedLookbackPeriod'] -eq 'OneWeek') {
                        $DataConnector.MicrosoftEmergingThreatFeedLookbackPeriod = ((Get-Date).AddDays(-7).ToUniversalTime() | Get-DAte -Format yyyy-MM-ddTHH:mm:ss.fffZ).ToString()
                    }
                    elseif ($PSBoundParameters['MicrosoftEmergingThreatFeedLookbackPeriod'] -eq 'OneMonth') {
                        $DataConnector.MicrosoftEmergingThreatFeedLookbackPeriod = ((Get-Date).AddMonths(-1).ToUniversalTime() | Get-DAte -Format yyyy-MM-ddTHH:mm:ss.fffZ).ToString()
                    }
                    elseif ($PSBoundParameters['MicrosoftEmergingThreatFeedLookbackPeriod'] -eq 'All') {
                        $DataConnector.MicrosoftEmergingThreatFeedLookbackPeriod = "1970-01-01T00:00:00.000Z"
                    }
                    $null = $PSBoundParameters.Remove('MicrosoftEmergingThreatFeedLookbackPeriod')
                }
                $null = $PSBoundParameters.Remove('MicrosoftTI')
            }
            if ($DataConnector.Kind -eq 'MicrosoftThreatProtection') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }

                If ($PSBoundParameters['Incident']) {
                    $DataConnector.IncidentState = $PSBoundParameters['Incident']
                    $null = $PSBoundParameters.Remove('Incident')
                }
                $null = $PSBoundParameters.Remove('MicrosoftThreatProtection')
            }
            if ($DataConnector.Kind -eq 'Office365') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }

                If ($PSBoundParameters['Exchange']) {
                    $DataConnector.ExchangeState = $PSBoundParameters['Exchange']
                    $null = $PSBoundParameters.Remove('Exchange')
                }

                If ($PSBoundParameters['SharePoint']) {
                    $DataConnector.SharePointState = $PSBoundParameters['SharePoint']
                    $null = $PSBoundParameters.Remove('SharePoint')
                }

                If ($PSBoundParameters['Teams']) {
                    $DataConnector.TeamState = $PSBoundParameters['Teams']
                    $null = $PSBoundParameters.Remove('Teams')
                }
                $null = $PSBoundParameters.Remove('Office365')
            }
            if ($DataConnector.Kind -eq 'OfficeATP') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }
                
                If ($PSBoundParameters['Alerts']) {
                    $DataConnector.AlertState = $PSBoundParameters['Alerts']
                    $null = $PSBoundParameters.Remove('Alerts')
                }
                $null = $PSBoundParameters.Remove('OfficeATP')
            }
            if ($DataConnector.Kind -eq 'OfficeIRM') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }
                
                If ($PSBoundParameters['Alerts']) {
                    $DataConnector.AlertState = $PSBoundParameters['Alerts']
                    $null = $PSBoundParameters.Remove('Alerts')
                }
                $null = $PSBoundParameters.Remove('OfficeIRM')
            }
            if ($DataConnector.Kind -eq 'ThreatIntelligence') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }
                
                If ($PSBoundParameters['Indicator']) {
                    $DataConnector.IndicatorState = $PSBoundParameters['Indicator']
                    $null = $PSBoundParameters.Remove('Indicator')
                }
                $null = $PSBoundParameters.Remove('ThreatIntelligence')
            }
            if ($DataConnector.Kind -eq 'ThreatIntelligenceTaxii') {
                If ($PSBoundParameters['TenantId']) {
                    $DataConnector.TenantId = $PSBoundParameters['TenantId']
                    $null = $PSBoundParameters.Remove('TenantId')
                }

                If ($PSBoundParameters['FriendlyName']) {
                    $DataConnector.FriendlyName = $PSBoundParameters['FriendlyName']
                    $null = $PSBoundParameters.Remove('FriendlyName')
                }

                If ($PSBoundParameters['APIRootURL']) {
                    $DataConnector.TaxiiServer = $PSBoundParameters['APIRootURL']
                    $null = $PSBoundParameters.Remove('APIRootURL')
                }

                If ($PSBoundParameters['CollectionId']) {
                    $DataConnector.CollectionId = $PSBoundParameters['CollectionId']
                    $null = $PSBoundParameters.Remove('CollectionId')
                }

                If ($PSBoundParameters['UserName']) {
                    $DataConnector.UserName = $PSBoundParameters['UserName']
                    $null = $PSBoundParameters.Remove('UserName')
                }

                If ($PSBoundParameters['Password']) {
                    $DataConnector.Password = $PSBoundParameters['Password']
                    $null = $PSBoundParameters.Remove('Password')
                }

                If ($PSBoundParameters['WorkspaceId']) {
                    $DataConnector.WorkspaceId = $PSBoundParameters['WorkspaceId']
                    $null = $PSBoundParameters.Remove('WorkspaceId')
                }
                
                if ($PSBoundParameters['PollingFrequency']) {
                    if ($PSBoundParameters['PollingFrequency'] -eq 'OnceADay') {
                        $DataConnector.PollingFrequency = "OnceADay"
                    }
                    elseif ($PSBoundParameters['PollingFrequency'] -eq 'OnceAMinute') {
                        $DataConnector.PollingFrequency = "OnceAMinute"
                    }
                    elseif ($PSBoundParameters['PollingFrequency'] -eq 'OnceAnHour') {
                        $DataConnector.PollingFrequency = "OnceAnHour"
                    }
                    $null = $PSBoundParameters.Remove('PollingFrequency')
                }
                $null = $PSBoundParameters.Remove('ThreatIntelligenceTaxii')
            }
            if ($DataConnector.Kind -eq 'AzureSecurityCenter') {
                If ($PSBoundParameters['ASCSubscriptionId']) {
                    $DataConnector.SubscriptionId = $PSBoundParameters['ASCSubscriptionId']
                    $null = $PSBoundParameters.Remove('ASCSubscriptionId')
                }

                If ($PSBoundParameters['Alerts']) {
                    $DataConnector.AlertState = $PSBoundParameters['Alerts']
                    $null = $PSBoundParameters.Remove('Alerts')
                }
                $null = $PSBoundParameters.Remove('AzureSecurityCenter')
            }
            if ($DataConnector.Kind -eq 'AmazonWebServicesCloudTrail') {
                If ($PSBoundParameters['AWSRoleArn']) {
                    $DataConnector.AWSRoleArn = $PSBoundParameters['AWSRoleArn']
                    $null = $PSBoundParameters.Remove('AWSRoleArn')
                }

                If ($PSBoundParameters['Log']) {
                    $DataConnector.LogState = $PSBoundParameters['Log']
                    $null = $PSBoundParameters.Remove('Log')
                }
                $null = $PSBoundParameters.Remove('AWSCloudTrail')            
            }
            if ($DataConnector.Kind -eq 'AmazonWebServicesS3') {
                If ($PSBoundParameters['AWSRoleArn']) {
                    $DataConnector.AWSRoleArn = $PSBoundParameters['AWSRoleArn']
                    $null = $PSBoundParameters.Remove('AWSRoleArn')
                }

                If ($PSBoundParameters['Log']) {
                    $DataConnector.LogState = $PSBoundParameters['Log']
                    $null = $PSBoundParameters.Remove('Log')
                }
                
                If ($PSBoundParameters['SQSURL']) {
                    $DataConnector.SqsUrl = $PSBoundParameters['SQSURL']
                    $null = $PSBoundParameters.Remove('SQSURL')
                }
                If ($PSBoundParameters['DetinationTable']) {
                    $DataConnector.DestinationTable = $PSBoundParameters['DetinationTable']
                    $null = $PSBoundParameters.Remove('DetinationTable')
                }
                $null = $PSBoundParameters.Remove('AWSS3')
            }
            if ($DataConnector.Kind -eq 'GenericUI') {
                If ($PSBoundParameters['UiConfigTitle']) {
                    $DataConnector.ConnectorUiConfigTitle = $PSBoundParameters['UiConfigTitle']
                    $null = $PSBoundParameters.Remove('UiConfigTitle')
                }
                If ($PSBoundParameters['UiConfigPublisher']) {
                    $DataConnector.ConnectorUiConfigPublisher = $PSBoundParameters['UiConfigPublisher']
                    $null = $PSBoundParameters.Remove('UiConfigPublisher')
                }        
                If ($PSBoundParameters['UiConfigDescriptionMarkdown']) {
                    $DataConnector.ConnectorUiConfigDescriptionMarkdown = $PSBoundParameters['UiConfigDescriptionMarkdown']
                    $null = $PSBoundParameters.Remove('UiConfigDescriptionMarkdown')
                }
                If ($PSBoundParameters['UiConfigCustomImage']) {
                    $DataConnector.ConnectorUiConfigCustomImage = $PSBoundParameters['UiConfigCustomImage']
                    $null = $PSBoundParameters.Remove('UiConfigCustomImage')
                }
                If ($PSBoundParameters['UiConfigGraphQueriesTableName']) {
                    $DataConnector.ConnectorUiConfigGraphQueriesTableName = $PSBoundParameters['UiConfigGraphQueriesTableName']
                    $null = $PSBoundParameters.Remove('UiConfigGraphQueriesTableName')
                }
                If ($PSBoundParameters['UiConfigGraphQuery']) {
                    $DataConnector.ConnectorUiConfigGraphQuery = $PSBoundParameters['UiConfigGraphQuery']
                    $null = $PSBoundParameters.Remove('UiConfigGraphQuery')
                }
                If ($PSBoundParameters['UiConfigSampleQuery']) {
                    $DataConnector.ConnectorUiConfigSampleQuery = $PSBoundParameters['UiConfigSampleQuery']
                    $null = $PSBoundParameters.Remove('UiConfigSampleQuery')
                }
                If ($PSBoundParameters['UiConfigDataType']) {
                    $DataConnector.ConnectorUiConfigDataType = $PSBoundParameters['UiConfigDataType']
                    $null = $PSBoundParameters.Remove('UiConfigDataType')
                }
                If ($PSBoundParameters['UiConfigConnectivityCriterion']) {
                    $DataConnector.ConnectorUiConfigConnectivityCriterion = $PSBoundParameters['UiConfigConnectivityCriterion']
                    $null = $PSBoundParameters.Remove('UiConfigConnectivityCriterion')
                }
                If ($PSBoundParameters['AvailabilityIsPreview']) {
                    $DataConnector.AvailabilityIsPreview = $PSBoundParameters['AvailabilityIsPreview']
                    $null = $PSBoundParameters.Remove('AvailabilityIsPreview')
                }
                If ($PSBoundParameters['AvailabilityStatus']) {
                    $DataConnector.AvailabilityStatus = $PSBoundParameters['AvailabilityStatus']
                    $null = $PSBoundParameters.Remove('AvailabilityStatus')
                }
                If ($PSBoundParameters['PermissionResourceProvider']) {
                    $DataConnector.PermissionResourceProvider = $PSBoundParameters['PermissionResourceProvider']
                    $null = $PSBoundParameters.Remove('PermissionResourceProvider')
                }
                If ($PSBoundParameters['PermissionCustom']) {
                    $DataConnector.DestinationTable = $PSBoundParameters['PermissionCustom']
                    $null = $PSBoundParameters.Remove('PermissionCustom')
                }
                If ($PSBoundParameters['UiConfigInstructionStep']) {
                    $DataConnector.ConnectorUiConfigInstructionStep = $PSBoundParameters['UiConfigInstructionStep']
                    $null = $PSBoundParameters.Remove('UiConfigInstructionStep')
                }
            }
    
            $null = $PSBoundParameters.Add('DataConnector', $DataConnector)
            Az.SecurityInsights.internal\Update-AzSentinelDataConnector @PSBoundParameters
        }
        catch {
            throw
        }
    }
}
# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBoBEIDjP6Y4iuc
# 4706lO6boOqaNIiD9hqQxiaHaNGNk6CCDXYwggX0MIID3KADAgECAhMzAAAEhV6Z
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEILkZ81/RRQSVqAfB0qnkR/kW
# 3cm2U/GtTq7+2lNRr8NAMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAu+KUYDyEuqfx9tOV/97sdCxO5OQKE2+oHia+DY5uy/NACb56+Ple00l1
# ZLTij31a651+cx8BgOHfYUFNZ0t/PSVbNeylYbhVCBQwEUZ2lUgUxrykWy6pE7GL
# SGDJY2y9V6IEM8h2kprkrxSwMEloIiM47HTqdKdwL3gt+7P4qNy+bNb61rxlu9al
# 0vvKCFUfo3pyL1yhJ9wxAljhnC54ylh24ohKGJ1CbvMMKZ/3+Gvf142T5DmiCYmm
# J7Xi7YUR0vOBSWR5t2JFMV+M1uPPzws38tvuGbOFdJd8o4JhYrPETVZMLvu83+F/
# wFkbcrq9g6ThNU+kZgfAj6bBdAwX9aGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCAAoffQll49PcDXLCZjcwk6Matg3WiStAVcN7gRoD+mwQIGaKOnrWFQ
# GBMyMDI1MTAwOTEyNDUwOS4yMjRaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MzcwMy0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgpHshTZ7rKzDwABAAACCjANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NTdaFw0yNjA0MjIxOTQyNTdaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MzcwMy0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCy7NzwEpb7BpwAk9LJ00Xq30TcTjcwNZ80TxAtAbhS
# aJ2kwnJA1Au/Do9/fEBjAHv6Mmtt3fmPDeIJnQ7VBeIq8RcfjcjrbPIg3wA5v5MQ
# flPNSBNOvcXRP+fZnAy0ELDzfnJHnCkZNsQUZ7GF7LxULTKOYY2YJw4TrmcHohkY
# 6DjCZyxhqmGQwwdbjoPWRbYu/ozFem/yfJPyjVBql1068bcVh58A8c5CD6TWN/L3
# u+Ny+7O8+Dver6qBT44Ey7pfPZMZ1Hi7yvCLv5LGzSB6o2OD5GIZy7z4kh8UYHdz
# jn9Wx+QZ2233SJQKtZhpI7uHf3oMTg0zanQfz7mgudefmGBrQEg1ox3n+3Tizh0D
# 9zVmNQP9sFjsPQtNGZ9ID9H8A+kFInx4mrSxA2SyGMOQcxlGM30ktIKM3iqCuFEU
# 9CHVMpN94/1fl4T6PonJ+/oWJqFlatYuMKv2Z8uiprnFcAxCpOsDIVBO9K1vHeAM
# iQQUlcE9CD536I1YLnmO2qHagPPmXhdOGrHUnCUtop21elukHh75q/5zH+OnNekp
# 5udpjQNZCviYAZdHsLnkU0NfUAr6r1UqDcSq1yf5RiwimB8SjsdmHll4gPjmqVi0
# /rmnM1oAEQm3PyWcTQQibYLiuKN7Y4io5bJTVwm+vRRbpJ5UL/D33C//7qnHbeoW
# BQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFAKvF0EEj4AyPfY8W/qrsAvftZwkMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQCwk3PW0CyjOaqXCMOusTde7ep2CwP/xV1J
# 3o9KAiKSdq8a2UR5RCHYhnJseemweMUH2kNefpnAh2Bn8H2opDztDJkj8OYRd/KQ
# ysE12NwaY3KOwAW8Rg8OdXv5fUZIsOWgprkCQM0VoFHdXYExkJN3EzBbUCUw3yb4
# gAFPK56T+6cPpI8MJLJCQXHNMgti2QZhX9KkfRAffFYMFcpsbI+oziC5Brrk3361
# cJFHhgEJR0J42nqZTGSgUpDGHSZARGqNcAV5h+OQDLeF2p3URx/P6McUg1nJ2gMP
# YBsD+bwd9B0c/XIZ9Mt3ujlELPpkijjCdSZxhzu2M3SZWJr57uY+FC+LspvIOH1O
# pofanh3JGDosNcAEu9yUMWKsEBMngD6VWQSQYZ6X9F80zCoeZwTq0i9AujnYzzx5
# W2fEgZejRu6K1GCASmztNlYJlACjqafWRofTqkJhV/J2v97X3ruDvfpuOuQoUtVA
# wXrDsG2NOBuvVso5KdW54hBSsz/4+ORB4qLnq4/GNtajUHorKRKHGOgFo8DKaXG+
# UNANwhGNxHbILSa59PxExMgCjBRP3828yGKsquSEzzLNWnz5af9ZmeH4809fwItt
# I41JkuiY9X6hmMmLYv8OY34vvOK+zyxkS+9BULVAP6gt+yaHaBlrln8Gi4/dBr2y
# 6Srr/56g0DCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
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
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjM3MDMtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDR
# AMVJlA6bKq93Vnu3UkJgm5HlYaCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7JIEozAiGA8yMDI1MTAwOTA5NTMz
# OVoYDzIwMjUxMDEwMDk1MzM5WjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDskgSj
# AgEAMAoCAQACAlDdAgH/MAcCAQACAjZkMAoCBQDsk1YjAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBABQ9COd9kqWLhK0hW3SJAl/aR380ziLTJxzfFda/cqog
# cmjxKHsFQRvfqjy0G33qNUWiLsYMHvwq+t0410WcOOU5fDeop0z1XUa/BvtGle1H
# kUITkbi/VX2xrEKVKdvL9M/ww5ZHMnHhdBDAKzsBTukX/yYm+fib+9su2PFs3FxV
# 3IOMA1cnTRGgVl9aJchHZW40nDKGe7+DjSOOTYGtCL1X8/d68Z/mV2+3vL+TBwmk
# 3ykDGI2luJ5VV07BvZTrKxjH6Xuk1AYLyknGH76sQBZbXx0Q8mv51EFih2YsL0qR
# sIHkUtY3o2Dd9wfEyV3Zj/zKj6knpdsMoEyq+Xq2V6sxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgpHshTZ7rKzDwABAAAC
# CjANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCCPuiNqKhZCST5rADOY0PpobzKF2/VVFI9RZ6K4xVlk
# ZDCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIE2ay/y0epK/X3Z03KTcloqE
# 8u9IXRtdO7Mex0hw9+SaMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIKR7IU2e6ysw8AAQAAAgowIgQg02/0l0+X3iaT/OtfKLUrX57R
# S9QDR9W1VyfcdWBU4X8wDQYJKoZIhvcNAQELBQAEggIAe13pSUAVbNbVFpKaCudM
# Icl2u4Sdxlb4PWe2oAbtIy0r8/geHbgy8jHu6BUZvJWaG0qVaoAjL1PVPjFmoVxe
# TwwNkI/YPvjm/9QK32FH51J+tedGw9Dou/QioJFGm2syAj38T0GdYWzXWvsnGQum
# 04jxet5za8K8q5RulXJc68VWZArpmZ1Y3vSFo8YSr1oGg4UZdjcwB8p5jEGvh+IF
# EjvFACgEv04ZaFpS17NorzqGHMqYqann6GBWkXAvAfO3Oge1dcQ3ZlUZRYtgmyRd
# JrANWDEgg0F1rOifJYh7FXx3Jy+LrYGpyoqvJ16GSLNAl56Z4yiUvBnGDJ3mEeJN
# tc4Kh10X+fmIZrN7Gs3GELjFEEVisDyBPRs0DjmcbBSfJnKm+i2O/DfPybSBHDrf
# p2LgRotnx/mPqHI7Yho+GPRjMN2crVw6n6yJ/6RGyJ6XLE95bY98xJTYzKNz7kHD
# f9EtY1nMGS3w6xem3gQx1Qv3rCLD8oR5oELsh3hznNDe3BbHuw3pHw6NNvhFW53C
# jjURdUfhB3Wxd6oC+MgPl1yo/e2RzUWOLkTM5sht1zqLpXbgr5DPDUuGY+HDmDKl
# Kx0bOmndtb9jtvtTlrZ5VsjcbvJ/wWOgeQd3XmfxoyStQMHBTKOcKqfseieCYyF7
# 9UV6+kR5yzoZQ5ENnpC1+88=
# SIG # End signature block
