param(
    [Parameter(Mandatory = $true)]
    [string]$ModuleName,

    [string]$BasePackage = 'com.pocketledger',

    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$moduleName = $ModuleName.Trim()
if (-not $moduleName) {
    throw 'ModuleName cannot be empty.'
}

if ($moduleName -notmatch '^[a-z][a-z0-9-]*$') {
    throw "Invalid module name '$moduleName'. Use lowercase letters, numbers, or hyphens."
}

$moduleDir = Join-Path $ProjectRoot $moduleName
if (Test-Path $moduleDir) {
    throw "Module folder already exists: $moduleDir"
}

$packageName = "$BasePackage.$moduleName"
$packagePath = $packageName.Replace('.', [IO.Path]::DirectorySeparatorChar)
$javaRoot = Join-Path $moduleDir "src\main\java"
$testRoot = Join-Path $moduleDir "src\test\java"
$mainPackageRoot = Join-Path $javaRoot $packagePath
$testPackageRoot = Join-Path $testRoot $packagePath

$folders = @(
    (Join-Path $mainPackageRoot 'controller'),
    (Join-Path $mainPackageRoot 'service'),
    (Join-Path $mainPackageRoot 'repository'),
    (Join-Path $mainPackageRoot 'entity'),
    (Join-Path $mainPackageRoot 'enums'),
    (Join-Path $mainPackageRoot 'dto'),
    (Join-Path $mainPackageRoot 'mapper'),
    (Join-Path $mainPackageRoot 'exception'),
    (Join-Path $mainPackageRoot 'validation'),
    (Join-Path $mainPackageRoot 'event'),
    (Join-Path $moduleDir 'src\main\resources'),
    $testPackageRoot
)

$applicationClass = @"
package $packageName;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class $(($moduleName.Substring(0,1).ToUpper() + $moduleName.Substring(1)))Application {

    public static void main(String[] args) {
        SpringApplication.run($(($moduleName.Substring(0,1).ToUpper() + $moduleName.Substring(1)))Application.class, args);
    }
}
"@

$moduleDirItem = New-Item -ItemType Directory -Path $moduleDir -Force
$null = $moduleDirItem
foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $folder '.gitkeep') -Force | Out-Null
}

$applicationClassPath = Join-Path $mainPackageRoot ($moduleName.Substring(0, 1).ToUpper() + $moduleName.Substring(1) + 'Application.java')
Set-Content -Path $applicationClassPath -Value $applicationClass -Encoding UTF8

$authTemplate = Join-Path $ProjectRoot 'auth\build.gradle'
$moduleBuild = Join-Path $moduleDir 'build.gradle'
if (Test-Path $authTemplate) {
    Copy-Item $authTemplate $moduleBuild -Force
}
else {
    @"
plugins {
    id 'java-library'
    id "com.diffplug.spotless" version "6.25.0"
}

dependencies {
    implementation project(':auth')
    implementation 'org.mapstruct:mapstruct:1.5.5.Final'

    compileOnly 'org.projectlombok:lombok:1.18.32'
    annotationProcessor 'org.projectlombok:lombok:1.18.32'
    annotationProcessor 'org.projectlombok:lombok-mapstruct-binding:0.2.0'
    annotationProcessor 'org.mapstruct:mapstruct-processor:1.5.5.Final'
    testImplementation 'org.junit.jupiter:junit-jupiter:5.9.3'
}

spotless {
    java {
        googleJavaFormat()
        removeUnusedImports()
    }
}
"@ | Set-Content -Path $moduleBuild -Encoding UTF8
}

$settingsPath = Join-Path $ProjectRoot 'settings.gradle'
$includeLine = "include ':$moduleName'"
if (Test-Path $settingsPath) {
    $settingsText = Get-Content $settingsPath -Raw
    if ($settingsText -notmatch [regex]::Escape($includeLine)) {
        if (-not $settingsText.EndsWith("`n")) {
            $settingsText += "`n"
        }
        $settingsText += "$includeLine`n"
        Set-Content -Path $settingsPath -Value $settingsText -Encoding UTF8
    }
}

Write-Host "Created module: $moduleName"
Write-Host "Package root: $packageName"
Write-Host "Folders created under: $moduleDir"

