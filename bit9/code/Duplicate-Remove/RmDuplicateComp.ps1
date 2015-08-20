#####################
# Set up API
#####################
$apiKey = "Your API Key Here"
$URLResource = "https://serverURL/api/bit9platform/v1/computer"
$ActiveComputers = $URLResource+"?q=deleted:false"

#####################
# API Call
#####################
$Computers = Invoke-RestMethod -Uri $ActiveComputers -Method Get -Header @{ "X-Auth-Token" = $apiKey }

#####################
# Import all the data into a hash table.
#####################
$HashTable = @{}
foreach($Computer in $Computers)
{
	$HashTable[$Computer.name] = $Computer.id
}

#####################
# GetEnumerator Function will maintain unique values based on the sort given. Supports multi-sort
#####################
$HashTable.GetEnumerator() | sort Name,Value -Descending

#####################
# If the machine is not in the hash table, it is a duplicate
# Check each active machine against hash table, and if it doesn't exist in the hash table, delete it from the server.
#####################
foreach ($Instance in $Computers)
{
    $comp = $Instance.name
    $ID = $Instance.id
    $Unique = $HashTable.ContainsValue($ID)
    if ( $Unique -ne $true )
    {
    $deleteCall = $URLResource + "/$ID"
    Invoke-RestMethod -Uri $deleteCall -Method Delete -Header @{ "X-Auth-Token" = $apiKey }
    }
}