# Runs commands sent from Neovim (:Shell, see lua/shell/init.lua) in this terminal tab.
#
# Start it in the tab that should run them:
#     pwsh -NoExit -File $env:LOCALAPPDATA\nvim\scripts\nvim-listener.ps1
# Ctrl+C stops listening and leaves you at the prompt.
#
# Protocol, over the named pipe \\.\pipe\<Name>: the client sends one JSON object per line,
#     {"cmd": "msbuild Foo.sln"}
# and gets one JSON line back when the command has finished,
#     {"ok": true, "exit": 0}
# The pipe only accepts connections from the current user.

#Requires -Version 7
param(
    [string]$Name = 'nvim-shell'
)

$ErrorActionPreference = 'Stop'
$utf8 = [System.Text.UTF8Encoding]::new($false)

# Wait on an async .NET call in short slices so Ctrl+C can still stop the script.
function Wait-Task($task) {
    while (-not $task.Wait(200)) { }
    return $task
}

function Invoke-NvimCommand([string]$cmd) {
    Write-Host "nvim> $cmd" -ForegroundColor Cyan
    $global:LASTEXITCODE = 0
    $ok = $true
    try {
        Invoke-Expression $cmd | Out-Host
        $ok = $?
    } catch {
        Write-Host $_ -ForegroundColor Red
        $ok = $false
    }
    $exit = if ($global:LASTEXITCODE) { $global:LASTEXITCODE } else { 0 }
    $ok = $ok -and $exit -eq 0
    $status = if ($ok) { 'ok' } elseif ($exit -ne 0) { "failed, exit $exit" } else { 'failed' }
    Write-Host "nvim> done ($status)" -ForegroundColor DarkGray
    return @{ ok = $ok; exit = $exit }
}

Write-Host "Listening for Neovim on \\.\pipe\$Name (Ctrl+C to stop)" -ForegroundColor DarkGray

function New-Pipe {
    [System.IO.Pipes.NamedPipeServerStream]::new(
        $Name,
        [System.IO.Pipes.PipeDirection]::InOut,
        [System.IO.Pipes.NamedPipeServerStream]::MaxAllowedServerInstances,
        [System.IO.Pipes.PipeTransmissionMode]::Byte,
        [System.IO.Pipes.PipeOptions]::Asynchronous -bor [System.IO.Pipes.PipeOptions]::CurrentUserOnly)
}

# The next pipe instance is opened as soon as a client connects, so there is never a moment without one: a
# command sent while another is running connects straight away and runs when the current one finishes.
$next = New-Pipe
try {
while ($true) {
    $pipe = $next
    try {
        Wait-Task $pipe.WaitForConnectionAsync() | Out-Null
        $next = New-Pipe
        $reader = [System.IO.StreamReader]::new($pipe, $utf8)
        $writer = [System.IO.StreamWriter]::new($pipe, $utf8)
        $writer.AutoFlush = $true

        while ($pipe.IsConnected) {
            $line = (Wait-Task $reader.ReadLineAsync()).Result
            if ($null -eq $line) { break }     # client closed the connection
            if ($line.Trim() -eq '') { continue }

            try {
                $msg = $line | ConvertFrom-Json
                $reply = Invoke-NvimCommand $msg.cmd
            } catch {
                Write-Host "nvim> bad message: $line" -ForegroundColor Red
                $reply = @{ ok = $false; exit = -1; error = "$_" }
            }
            try {
                $writer.WriteLine(($reply | ConvertTo-Json -Compress))
            } catch [System.IO.IOException] {
                break                           # Neovim went away while the command ran
            }
        }
    } catch [System.IO.IOException] {
        # Client disconnected abruptly; wait for the next one.
    } finally {
        $pipe.Dispose()
    }
}
} finally {
    $next.Dispose()
}
