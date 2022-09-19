function Find-BitcoinAddess{
  param(
    [Parameter(Mandatory)]
    [string]$BitcoinAddress,
    [switch]$ShowTransactions # Flag to display transactions
  )

  $ESC = [char]27

  $raw_addr_endpoint = "https://blockchain.info/rawaddr"
  $exchange_endpoint = "https://blockchain.info/ticker"

  $last_exchange_rate = (Invoke-RestMethod -Uri $exchange_endpoint | Select-Object USD).USD.last 

  $satoshi_conv = 100000000
  
  Write-Host "[FBA] Searching $BitcoinAddress..."
  $query = Invoke-RestMethod -Uri "$raw_addr_endpoint/$BitcoinAddress"

  if($query -ne "" -or $null -ne $query){
    $received = (($query.total_received / $satoshi_conv) * $last_exchange_rate).ToString("#.##")
    $sent = (($query.total_sent / $satoshi_conv) * $last_exchange_rate).ToString("#.##")
    $balance = (($query.final_balance / $satoshi_conv) * $last_exchange_rate).ToString("#.##")

    Write-Output "[FBA] Info for $($BitcoinAddress):"
    Write-Output " Total Received: `$$received"
    Write-Output " Total Sent: `$$sent"
    Write-Output " Final Balance: `$$balance"
    Write-Output " Total Transactions: $($query.n_tx)"
    if($ShowTransactions){
      Write-Output " Transactions:"

      $out = $query.txs.out | Sort-Object value -Descending
      Write-Output "  Out:"
      foreach($tx in $out){
        $amount = (($tx.value / $satoshi_conv) * $last_exchange_rate).ToString("#.##")
        Write-Output "   $ESC[31m->$ESC[0m $($tx.addr):"
        Write-Output "    Spent? $(if($tx.spent){ "$ESC[5;31mTrue$ESC[0m"} else {"False"})"
        Write-Output "    Amount: `$$amount"
      }
    }
  }
}