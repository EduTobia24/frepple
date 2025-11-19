# Getting Xerces-C Pre-Built Binaries

The xerces-c-3.3.0.zip you downloaded contains **source code**, not compiled binaries.

## Option 1: Download Pre-Built Binaries (EASIEST)

Download pre-built binaries from NuGet:
1. Go to: https://www.nuget.org/packages/xerces-c-vc142-x64/
2. Click "Download package" on the right side
3. Rename the downloaded `.nupkg` file to `.zip`
4. Extract it
5. The DLLs will be in the `build\native\bin` folder

**OR use PowerShell to download automatically:**

```powershell
# Run this from the frepple root directory
$depPath = ".\contrib\windows\dependencies"
$nugetUrl = "https://www.nuget.org/api/v2/package/xerces-c-vc142-x64/3.3.0"
$zipPath = "$depPath\xerces-nuget.zip"

Write-Host "Downloading Xerces-C binaries from NuGet..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $nugetUrl -OutFile $zipPath

Write-Host "Extracting..." -ForegroundColor Yellow
$tempDir = "$depPath\temp_xerces_nuget"
Expand-Archive $zipPath -DestinationPath $tempDir -Force

# Move DLLs to correct location
Remove-Item "$depPath\xerces-c" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory "$depPath\xerces-c\bin" -Force | Out-Null
New-Item -ItemType Directory "$depPath\xerces-c\lib" -Force | Out-Null
New-Item -ItemType Directory "$depPath\xerces-c\include" -Force | Out-Null

Copy-Item "$tempDir\build\native\bin\*.dll" "$depPath\xerces-c\bin\" -Force
Copy-Item "$tempDir\build\native\lib\*.lib" "$depPath\xerces-c\lib\" -Force
Copy-Item "$tempDir\build\native\include\*" "$depPath\xerces-c\include\" -Recurse -Force

# Cleanup
Remove-Item $tempDir -Recurse -Force
Remove-Item $zipPath -Force

Write-Host "✓ Xerces-C binaries installed!" -ForegroundColor Green
```

## Option 2: Use vcpkg (Alternative)

If you have vcpkg installed:
```powershell
vcpkg install xerces-c:x64-windows
```

Then copy files from `vcpkg\installed\x64-windows\` to the dependencies folder.

## Option 3: Build from Source (Advanced)

This requires Visual Studio and CMake:
```powershell
cd contrib\windows\dependencies
cmake -S xerces-c -B xerces-c-build -A x64
cmake --build xerces-c-build --config Release
```

---

**Recommended:** Use Option 1 (NuGet) - it's the fastest and most reliable.
