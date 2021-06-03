$CopyFrom = 'Object ID to copy from'
$CopyTo = 'Object ID to copy to'
Get-AzRoleAssignment -ObjectId $CopyFrom | ForEach-Object{
    New-AzRoleAssignment -ObjectId $CopyTo -RoleDefinitionId $_.RoleDefinitionId -Scope $_.Scope
}
