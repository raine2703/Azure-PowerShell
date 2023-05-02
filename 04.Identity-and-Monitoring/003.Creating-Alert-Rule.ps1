#Using Azure Monitor. Creating Action group and CPU usage Alert when over 20%

function Get-ResourceId
{
    param([String] $ResourceName)

    $Resource=Get-AzResource -Name $ResourceName
    return $Resource.Id
}


$ResourceGroupName="RG8"
$ActionGroupName="AdminGroup"
$ReceiverGroupName="EmailAdmin"
$ReceiverGroupEmail="raitis.neitals@gmail.com"

#Creating Action group
$Receiver=New-AzActionGroupReceiver -Name $ReceiverGroupName `
-EmailReceiver -EmailAddress $ReceiverGroupEmail

$ActionGroup=Set-AzActionGroup -Name $ActionGroupName -ResourceGroupName $ResourceGroupName `
-ShortName $ActionGroupName -Receiver $Receiver

#Creating alert for existing VM
$ResourceName="appvm"
$AlertName="CPUAlert"
$Threshold=20
$MetricName="Percentage CPU"
$Description="Alert when CPU percentage goes beyond 20%"
$WindowSize=New-TimeSpan -Minutes 5
$Frequency=New-TimeSpan -Minutes 5

$Condition=New-AzMetricAlertRuleV2Criteria -MetricName $MetricName `
-TimeAggregation Average -Operator GreaterThanOrEqual -Threshold $Threshold

Add-AzMetricAlertRuleV2 -Name $AlertName -ResourceGroupName $ResourceGroupName `
-Severity 3 -TargetResourceId (Get-ResourceId $ResourceName) `
-Description $Description -Condition $Condition `
-WindowSize $WindowSize -Frequency $Frequency -ActionGroupId $ActionGroup.Id