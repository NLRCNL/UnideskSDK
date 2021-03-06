function Get-ALOsLayer
{
<#
.SYNOPSIS
  Gets all OS layers
.DESCRIPTION
  Gets all OS layers
.PARAMETER websession
  Existing Webrequest session for CAL Appliance
.EXAMPLE
  Get-ALOsLayer -websession $websession
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true)]$websession
)
Begin {
  Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
  Test-ALWebsession -WebSession $websession
}
Process {
[xml]$xml = @"
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
  <s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <QueryOsLayers xmlns="http://www.unidesk.com/">
      <query>
        <ResourceFarmId>0</ResourceFarmId>
        <Filter/>
      </query>
    </QueryOsLayers>
  </s:Body>
</s:Envelope>
"@
$headers = @{
SOAPAction = "http://www.unidesk.com/QueryOsLayers";
"Content-Type" = "text/xml; charset=utf-8";
UNIDESK_TOKEN = $websession.token;
}
$url = "https://" + $websession.aplip + "/Unidesk.Web/API.asmx"
$return = Invoke-WebRequest -Uri $url -Method Post -Body $xml -Headers $headers -WebSession $websession
[xml]$obj = $return.Content


if($obj.Envelope.Body.QueryOsLayersResponse.QueryOsLayersResult.OsLayers.Error)
    {
      throw $obj.Envelope.Body.QueryOsLayersResponse.QueryOsLayersResult.OsLayers.Error.message
    }
    else {
      return $obj.Envelope.Body.QueryOsLayersResponse.QueryOsLayersResult.OsLayers.LayerEntitySummary
    }
}
end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}
