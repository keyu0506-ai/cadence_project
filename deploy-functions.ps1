$ErrorActionPreference = 'Stop'
$previousTimeout = $env:FUNCTIONS_DISCOVERY_TIMEOUT
try {
    # This controls local CLI source discovery, not function execution time.
    $env:FUNCTIONS_DISCOVERY_TIMEOUT = '60'
    Push-Location $PSScriptRoot
    try {
        & firebase deploy --only functions --project project-database-3265e
        $deployExitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }
} finally {
    $env:FUNCTIONS_DISCOVERY_TIMEOUT = $previousTimeout
}
exit $deployExitCode
