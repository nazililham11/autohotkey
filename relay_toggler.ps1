$relayId = $args[0]

# Init voice
$voice = New-Object -ComObject Sapi.spvoice
$voice.rate = 0
$voice.voice = $voice.GetVoices().Item(1)

$device_labels = "Charger", "Lamp", "Fan"
$device = $device_labels.Item($relayId)

function relay([int]$id) {

    # First try
    $try_toggle = Invoke-RestMethod -Uri "http://10.10.10.1/relay?id=$id" -TimeoutSec 1;
    if ($try_toggle){
        return $true
    }

    # Try Connect to Wifi
    $interfaceInfo = netsh wlan show interfaces
    if ($interfaceInfo -match "State\s+:\s+disconnected") { 
        $voice.speak("Try connecting to WiFi..") | Out-Null
        netsh wlan connect AP;
        Start-Sleep -Seconds 5

        # Refresh Wifi info
        $interfaceInfo = netsh wlan show interfaces;
        if ($interfaceInfo -notmatch "SSID\s+:\s+AP") { 
            $voice.speak("Fail!") | Out-Null
            return $false
        }
        $voice.speak("Connected!") | Out-Null
    } 

    if ($interfaceInfo -notmatch "SSID\s+:\s+AP") { 
        $voice.speak("Already connected to other wifi") | Out-Null
        return $false
    }

    $stats = Invoke-RestMethod -Uri "http://10.10.10.1/stats";
    $state = if (!$stats.relay.Item($id) -eq 1) { "On" } else { "Off" }

    $voice.speak("Turn $state $device") | Out-Null
    $resp = Invoke-RestMethod -Uri "http://10.10.10.1/relay?id=$id";
    return $resp.runtime
}

Write-Host "Toggle Relay $relayId"

$result = relay($relayId)

if ($result -eq $true) { 
    $voice.speak("Toggle $device, Done!") | Out-Null
} else {
    $voice.speak("Toggle $device, Failed!") | Out-Null
}