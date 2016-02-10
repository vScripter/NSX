

function Get-NSXManagerSystemSummary {
	
	[cmdletbinding()]
	param (
        [parameter(Mandatory, Position = 1)]
		[System.String]$Manager,
		
        [parameter(Mandatory, Position = 2)]
		[System.Management.Automation.PSCredential]$Credential
	)
	
	BEGIN {
		
		# setup authentication header
		$encodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.Username + ":" + $($Credential.GetNetworkCredential().password)))
		$headerCredential = @{ "Authorization" = "Basic $encodedCredential" }
		$nsxUri = "https://$Manager/api/1.0/appliance-management/summary/system"
		
		# allow untrusted certs
		# Allow untrusted SSL certs
		add-type @"
	    using System.Net;
	    using System.Security.Cryptography.X509Certificates;
	    public class TrustAllCertsPolicy : ICertificatePolicy {
	        public bool CheckValidationResult(
	            ServicePoint srvPoint, X509Certificate certificate,
	            WebRequest request, int certificateProblem) {
	            return true;
	        }
	    }
"@
		[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
		
	} # end BEGIN block
	
	PROCESS {
		
		try {
            
			$nsxREST = $null
			$nsxREST = Invoke-RestMethod -Method Get -Uri $nsxUri -Headers $headerCredential -Verbose -ErrorAction Stop
			
			$obj = @()
			$obj = [PSCustomObject] @{
				NSXManager = $nsxREST.hostName
				IPAddress = $nsxREST.ipv4Address
				DomainName = $nsxREST.domainName
				ApplianceName = $nsxREST.applianceName
				Version = "$($nsxREST.versionInfo.majorVersion).$($nsxREST.versionInfo.minorVersion)"
				Build = $nsxREST.versionInfo.buildNumber
				Uptime = $nsxREST.uptime
				SystemTime = $nsxREST.currentSystemDate
			}
			$obj
			
		} catch {
			
			throw "$_"
			
		} # end try/catch
		
	} # end PROCESS block
	
	
	END {
		
		
	} # end END block
	
} # end function Get-NSXManagerSystemSummary

function Get-NSXController {
	
	[cmdletbinding()]
	param (
		[parameter(Mandatory, Position = 1)]
		[System.String]$Manager,
		
		[parameter(Mandatory, Position = 2)]
		[System.Management.Automation.PSCredential]$Credential
	)
	
	BEGIN {
		
		# setup authentication header
		$encodedCredential = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.Username + ":" + $($Credential.GetNetworkCredential().password)))
		$headerCredential = @{ "Authorization" = "Basic $encodedCredential" }
		$nsxUri = "https://$Manager/api/2.0/vdn/controller"
		
		# allow untrusted certs
		# Allow untrusted SSL certs
		add-type @"
	    using System.Net;
	    using System.Security.Cryptography.X509Certificates;
	    public class TrustAllCertsPolicy : ICertificatePolicy {
	        public bool CheckValidationResult(
	            ServicePoint srvPoint, X509Certificate certificate,
	            WebRequest request, int certificateProblem) {
	            return true;
	        }
	    }
"@
		[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
		
	} # end BEGIN block
	
	PROCESS {
		
		try {
			
			$nsxREST = $null
			$nsxREST = Invoke-RestMethod -Method Get -Uri $nsxUri -Headers $headerCredential -Verbose -ErrorAction Stop
			
            foreach ($nsxController in $nsxRest.controllers.controller) {
			$obj = @()
			$obj = [PSCustomObject] @{
				NSXManager = $Manager
                ControllerID = $nsxController.id
				IPAddress = $nsxController.ipAddress
                Status = $nsxController.Status
                Version = $nsxController.version
                UpgradeStatus = $nsxController.upgradestatus
                UpgradeAvailable = $nsxController.upgradeavailable
	            VMName = $nsxController.virtualMachineInfo.name
                VMHost = $nsxController.hostInfo.name
                Cluster = $nsxController.clusterInfo.name
                Datastore = $nsxController.datastoreInfo.name
			}
			$obj
			
            } # end foreach
			
		} catch {
			
			throw "$_"
			
		} # end try/catch
		
	} # end PROCESS block
	
	
	END {
		
		
	} # end END block
	
} # end function Get-NSXController
