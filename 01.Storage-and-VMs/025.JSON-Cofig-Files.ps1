#Idea how to work with JSON config files


#Define the Environment as input value
param(
[Parameter(Mandatory=$true)]
[string]$Environment
)

#Or simply $Environment="Production"

#Getting JSON file object values
$Object=Get-Content -Raw -Path "C:\Users\raitisn\Desktop\psw-work\Storage-and-VMs\Config.json" | ConvertFrom-Json

#Clearing all variables
$VirtualNetworkName=$null
$VirtualNetworkAddressSpace=$null
$SubnetNames=@()
$SubnetIPAddressSpace=@()

#Based on Environment getting different values 
switch($Environment)
{
    "Production"
    {
        $VirtualNetworkName=$Object.Production.VirtualNetwork.Name
        $VirtualNetworkAddressSpace=$Object.Production.VirtualNetwork.AddressSpace
        $SubnetNames+=$Object.Production.Subnets.Name
        $SubnetIPAddressSpace+=$Object.Production.Subnets.AddressSpace
    }

    "Test"
    {
        $VirtualNetworkName=$Object.Test.VirtualNetwork.Name
        $VirtualNetworkAddressSpace=$Object.Test.VirtualNetwork.AddressSpace
        $SubnetNames+=$Object.Test.Subnets.Name
        $SubnetIPAddressSpace+=$Object.Test.Subnets.AddressSpace

    }
}

#Based on Selected environment you will retrieve different values!
$VirtualNetworkName
$VirtualNetworkAddressSpace
$SubnetNames
$SubnetIPAddressSpace