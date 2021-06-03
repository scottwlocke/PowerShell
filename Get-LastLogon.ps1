Function Get-LastLogon (){
    [cmdletbinding()]

    Param(
        [alias("UserName","User","SamAccountName","Name","DistinguishedName","UserPrincipalName","DN","UPN")]
        [parameter(ValueFromPipeline,Position=0,Mandatory)]
        [string[]]$Identity
    )

    begin{
        $DCList = Get-ADDomainController -Filter * | Select-Object -ExpandProperty name
    }

    process{

        foreach($currentuser in $Identity)
        {
            $filter = switch -Regex ($currentuser){
                '=' {'DistinguishedName';break}
                '@' {'UserPrincipalName';break}
                ' ' {'Name';break}
                default {'SamAccountName'}
            }

            Write-Verbose "Checking lastlogon for user: $currentuser"

            foreach($DC in $DCList)
            {
                Write-Verbose "Current domain controller: $DC"

                $account = Get-ADUser -Filter "$filter -eq '$currentuser'" -Properties lastlogon,lastlogontimestamp -Server $DC

                if(!$account)
                {
                    Write-Verbose "No user found with search term '$filter -eq '$currentuser''"
                    continue
                }

                Write-Verbose "LastLogon         : $([datetime]::FromFileTime($account.lastlogon))"
                Write-Verbose "LastLogonTimeStamp: $([datetime]::FromFileTime($account.lastlogontimestamp))"

                $logontime = $account.lastlogon,$account.lastlogontimestamp |
                    Sort-Object -Descending | Select-Object -First 1
            
                if($logontime -gt $newest)
                {
                    $newest = $logontime
                }
            }

            if($account)
            {
                switch ([datetime]::FromFileTime($newest)){
                    {$_.year -eq '1600'}{
                        "Never"
                    }
                    default{$_}
                }
            }

            Remove-Variable newest,lastlogon,account,logontime,lastlogontimestamp -ErrorAction SilentlyContinue
        }
    }

    end{
        Remove-Variable dclist -ErrorAction SilentlyContinue
    }
}
