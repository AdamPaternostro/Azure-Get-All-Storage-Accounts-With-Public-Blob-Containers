# Finds any storage account (Classic or ARM) that have a Blob Container with an access level other than "Off" (so it finds Public and Blob)
# You might get errors on Classic if you do not have access
# You might get errors on ARM if you do not have access (this error message states it is a permission issue)

Login-AzureRmAccount

$subscriptionList = Get-AzureRmSubscription

foreach ($s in $subscriptionList)
{
    # Note: we can write this to loop through all subscriptions
    Select-AzureRmSubscription -SubscriptionId $s.SubscriptionId

    # Gets all Azure resources
    $Resources = Get-AzureRmResource

    foreach ($r in $Resources)
    {
       $item = New-Object -TypeName PSObject -Property @{
                    Name = $r.Name
                    ResourceType = $r.ResourceType
                    ResourceGroupName = $r.ResourceGroupName
                    } | Select-Object Name,  ResourceType, ResourceGroupName

        # Do for ARM
        if ($item.ResourceType -eq "Microsoft.Storage/storageAccounts")
          {
              $string = "Processing ARM storage account: " + $item.Name
              Write-Output $string
              $Ctx = Get-AzureRmStorageAccount –StorageAccountName $item.Name -ResourceGroupName $item.ResourceGroupName
     
              # Get all the containers
              $containerList = Get-AzureStorageContainer -Context $Ctx.Context -MaxCount 2147483647  

              foreach ($c in $containerList)
              {
                  $containerItem = New-Object -TypeName PSObject -Property @{
                                     Name = $c.Name
                                     PublicAccess = $c.PublicAccess
                                     } | Select-Object Name,  PublicAccess
       
                  # Test each for public
                  if ($containerItem.PublicAccess -ne "Off")
                  {
                     $string = "Subscription Name: " + $s.SubscriptionName + " (" + $s.SubscriptionId + ") Storage Account: " + $item.Name + " in RG: " + $item.ResourceGroupName + " has a public container named: " + $c.Name
                     Write-Output $string 
                  } 
              } # ($c in $containerList)

          }

        # Do for classic
        if ($item.ResourceType -eq "Microsoft.ClassicStorage/storageAccounts")
          {
              $string = "Processing Classic storage account: " + $item.Name
              Write-Output $string
              $Ctx = Get-AzureStorageAccount –StorageAccountName $item.Name 
     
              # Get all the containers
              $containerList = Get-AzureStorageContainer -Context $Ctx.Context -MaxCount 2147483647  

              foreach ($c in $containerList)
              {
                  $containerItem = New-Object -TypeName PSObject -Property @{
                                     Name = $c.Name
                                     PublicAccess = $c.PublicAccess
                                     } | Select-Object Name,  PublicAccess
      

                  # Test each for public
                  if ($containerItem.PublicAccess -ne "Off")
                  {
                     $string = "Subscription Name: " + $s.SubscriptionName + " (" + $s.SubscriptionId + ") Storage Account: " + $item.Name + " in RG: " + $item.ResourceGroupName + " has a public container named: " + $c.Name
                     Write-Output $string 
                  } 
              } # ($c in $containerList)

          }

    } # ($r in $Resources)

    Write-Output ""

} #foreach ($s in $subscriptionList)


