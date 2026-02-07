# 在项目根目录下，打开 PowerShell 运行：
# 比如你想升级到 0.0.2
# .\build.ps1 -Version "0.0.2"

param (
    [Parameter(Mandatory=$true)]
    [string]$Version
)

$pubspecPath = "pubspec.yaml"

if (-not (Test-Path $pubspecPath)) {
    Write-Host "错误: 找不到 pubspec.yaml 文件" -ForegroundColor Red
    exit 1
}

Write-Host "--- 开始自动化版本更新与构建 ---" -ForegroundColor Cyan

# 1. 读取并解析 pubspec.yaml
$content = Get-Content $pubspecPath -Raw

# 2. 静态检查
Write-Host "正在执行 flutter analyze..." -ForegroundColor Cyan
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 静态检查未通过，构建终止。" -ForegroundColor Red
    exit $LASTEXITCODE
}

# 3. 单元测试
Write-Host "正在执行 flutter test..." -ForegroundColor Cyan
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 单元测试失败，构建终止。" -ForegroundColor Red
    exit $LASTEXITCODE
}

# 4. 版本更新逻辑
if ($content -match "version:\s*([\d\.]+)\+(\d+)") {
    $oldVersionName = $Matches[1]
    $oldBuildNumber = [int]$Matches[2]
    
    # 构建号自动 +1
    $newBuildNumber = $oldBuildNumber + 1
    $newFullVersion = "$Version+$newBuildNumber"
    
    # 替换版本号行
    $newContent = $content -replace "version:\s*[\d\.]+\+\d+", "version: $newFullVersion"
    
    # 写回文件 (使用 UTF8 编码以匹配 Flutter 规范)
    [System.IO.File]::WriteAllText((Resolve-Path $pubspecPath), $newContent, [System.Text.Encoding]::UTF8)
    
    Write-Host "✓ 版本号已更新: $oldVersionName+$oldBuildNumber -> $newFullVersion" -ForegroundColor Green
} else {
    Write-Host "❌ 错误: 无法在 pubspec.yaml 中找到有效的版本号格式 (x.y.z+n)" -ForegroundColor Red
    exit 1
}

# 5. 执行 Flutter 构建
Write-Host "正在执行 flutter build windows --release..." -ForegroundColor Cyan

# 记录开始时间
$startTime = Get-Date

flutter build windows --release

if ($LASTEXITCODE -eq 0) {
    $endTime = Get-Date
    $duration = $endTime - $startTime
    Write-Host "`n★ 构建成功！" -ForegroundColor Green
    Write-Host "总耗时: $($duration.Minutes)分 $($duration.Seconds)秒"
    Write-Host "产物位置: build\windows\runner\Release\" -ForegroundColor Gray
} else {
    Write-Host "`n❌ 构建失败，请检查上方输出错误。" -ForegroundColor Red
    exit $LASTEXITCODE
}
