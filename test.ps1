param([string]$Image = "awtrix2:latest")
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    docker compose -f compose.yml config --quiet
    if ($LASTEXITCODE -ne 0) { throw 'Local Compose validation failed.' }
    docker compose -f compose-example.yml config --quiet
    if ($LASTEXITCODE -ne 0) { throw 'NAS Compose validation failed.' }
    # Stub Java to check startup behavior without starting services.
    $check = @"
set -eu
java -version
mkdir /tmp/test-bin
printf '#!/bin/sh\nexit 0\n' > /tmp/test-bin/java
chmod +x /tmp/test-bin/java
export PATH=/tmp/test-bin:`$PATH
test ! -e /data/awtrix.jar
/entrypoint.sh
cmp /opt/awtrix/awtrix.jar /data/awtrix.jar
printf existing > /data/awtrix.jar
/entrypoint.sh
test "`$(cat /data/awtrix.jar)" = existing
: > /data/awtrix.jar
if /entrypoint.sh; then
    echo 'FAIL: empty JAR was accepted' >&2
    exit 1
fi
echo 'PASS: seed, preserve existing JAR, reject empty JAR'
"@
    $check.Replace("`r", "") | docker run --rm -i --network none --entrypoint sh $Image
    if ($LASTEXITCODE -ne 0) { throw 'Entrypoint checks failed.' }
} finally {
    Pop-Location
}
