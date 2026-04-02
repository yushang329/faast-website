# FaAST 网站一键部署脚本
# 用户名: yushang329
# 仓库: faast-website

Write-Host "=== FaAST 网站一键部署工具 ===" -ForegroundColor Cyan
Write-Host ""

# 设置变量
$repoName = "faast-website"
$githubUser = "yushang329"
$projectPath = "D:\XMU\Subject\互联网+\项目网页"

# 检查是否已安装 Git
try {
    $gitVersion = git --version 2>$null
    if ($gitVersion) {
        Write-Host "✓ Git 已安装: $gitVersion" -ForegroundColor Green
    } else {
        throw "Git not found"
    }
} catch {
    Write-Host "正在下载并安装 Git..." -ForegroundColor Yellow
    
    # 下载 Git
    $gitInstaller = "$env:TEMP\Git-2.42.0-64-bit.exe"
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe"
    
    try {
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
        Write-Host "✓ Git 安装包下载完成" -ForegroundColor Green
        
        # 安装 Git（静默安装）
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS=icons,ext\reg\shellhere,assoc,assoc_sh" -Wait
        Write-Host "✓ Git 安装完成" -ForegroundColor Green
        
        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    } catch {
        Write-Host "✗ Git 下载失败，请手动下载安装: https://git-scm.com/download/win" -ForegroundColor Red
        Read-Host "按回车键退出"
        exit
    }
}

Write-Host ""
Write-Host "请确保已在 GitHub 创建仓库: $repoName" -ForegroundColor Yellow
Write-Host "访问: https://github.com/new" -ForegroundColor Cyan
Write-Host ""

$continue = Read-Host "是否继续? (输入 y 继续)"
if ($continue -ne "y") {
    exit
}

# 配置 Git
Write-Host ""
Write-Host "配置 Git..." -ForegroundColor Cyan

$gitName = Read-Host "请输入你的姓名（用于 Git 提交记录）"
$gitEmail = Read-Host "请输入你的邮箱（用于 Git 提交记录）"

git config --global user.name "$gitName"
git config --global user.email "$gitEmail"

# 进入项目目录
Set-Location $projectPath

# 初始化仓库
Write-Host ""
Write-Host "初始化 Git 仓库..." -ForegroundColor Cyan

if (Test-Path ".git") {
    Remove-Item -Recurse -Force ".git"
}

git init

# 添加所有文件
Write-Host "添加文件到仓库..." -ForegroundColor Cyan
git add .

# 提交
git commit -m "Initial commit: FaAST website"

# 连接远程仓库
Write-Host ""
Write-Host "连接 GitHub 远程仓库..." -ForegroundColor Cyan
$remoteUrl = "https://github.com/$githubUser/$repoName.git"
git remote add origin $remoteUrl

# 推送
Write-Host ""
Write-Host "推送到 GitHub..." -ForegroundColor Cyan
git branch -M main

try {
    git push -u origin main
    Write-Host ""
    Write-Host "✓ 上传成功！" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "✗ 推送失败，尝试使用 GitHub 凭据..." -ForegroundColor Yellow
    Write-Host "请在弹出的窗口中输入你的 GitHub 用户名和密码（或 Personal Access Token）" -ForegroundColor Yellow
    
    # 使用凭据管理器
    git config --global credential.helper wincred
    git push -u origin main
}

Write-Host ""
Write-Host "=== 部署完成 ===" -ForegroundColor Green
Write-Host ""
Write-Host "网站地址: https://$githubUser.github.io/$repoName/" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "1. 访问 https://github.com/$githubUser/$repoName/settings/pages" -ForegroundColor White
Write-Host "2. Source 选择 'Deploy from a branch'" -ForegroundColor White
Write-Host "3. Branch 选择 'main'，文件夹选择 '/ (root)'" -ForegroundColor White
Write-Host "4. 点击 Save，等待 1-2 分钟" -ForegroundColor White
Write-Host ""

Read-Host "按回车键退出"
