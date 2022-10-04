
# 读取文件 UTF8-NOBOM
function ReadFile($path) {
    return (Get-Content -Raw -Encoding "UTF8NoBOM" -Path "$path" )
}

# 读取json文件并转换为对象
function ReadJsonFile($path) {
    $content = ReadFile $path
    return ConvertFrom-Json -InputObject $content
}

# 读取,调用上面的函数
$appSettings = (ReadJsonFile -path "./applist.json" )

$path = $appSettings.setting.path
$DownloadsPath = $appSettings.setting.Downloads

Write-Host "安装目录："$appSettings.setting.path -ForegroundColor Green
Write-Host "当前列表包含：" -ForegroundColor Green
Write-Host "--------winget--------" -ForegroundColor Green
for($k=0;$k -lt $appSettings.winget.Length;$k++){
    Write-Host $appSettings.winget[$k].name
}
Write-Host "--------msstore--------" -ForegroundColor Green
for($k=0;$k -lt $appSettings.msstore.Length;$k++){
    Write-Host $appSettings.msstore[$k].name
}
Write-Host "--------optional--------" -ForegroundColor Green
for($k=0;$k -lt $appSettings.optional.Length;$k++){
    Write-Host $appSettings.optional[$k].name
}
Write-Host "--------game--------" -ForegroundColor Green
for($k=0;$k -lt $appSettings.game.Length;$k++){
    Write-Host $appSettings.game[$k].name
}
$chose = Read-Host "总共"$appSettings.winget.Length"个winget源应用;"$appSettings.msstore.Length"个msstore源应用;"$appSettings.optional.Length"个可选应用;"$appSettings.game.Length"个游戏; 您确认要继续吗? Y/n"


if($chose -eq "Y"||$chose -eq "y")
{
    # 安装winget应用
    for($i=0;($i -lt $appSettings.winget.Length) -and ($appSettings.winget.Length -ne 0);$i++)
    {
        cls
        Write-Host "开始安装winget应用" -ForegroundColor Green
        $InstallPath=$path+$appSettings.winget[$i].name
        winget install $appSettings.winget[$i].id -l $InstallPath
    }

    # 安装msstore应用
    for($j=0;($j -lt $appSettings.msstore.Length) -and ($appSettings.msstore.Length -ne 0);$j++)
    {
        cls
        Write-Host "开始安装msstore应用，请手动输入`"y`"确认" -ForegroundColor Green
        winget install $appSettings.msstore[$j].id
    }

    # 安装可选应用
    for($k=0;($k -lt $appSettings.optional.Length) -and ($appSettings.optional.Length -ne 0);$k++)
    {
        cls
        $chose = Read-Host "是否安装`""$appSettings.optional[$k].name"`"Y/n"
        if($chose -eq "Y"||$chose -eq "y")
        {
            $InstallPath=$path+$appSettings.optional[$k].name
            winget install $appSettings.optional[$k].id -l $InstallPath
        }
        elseif($chose -eq "N"||$chose -eq "n")
        {
            cls
        }
    }

    #安装游戏(或者需要从链接下载exe的应用)
    mkdir -Force $DownloadsPath
    for($k=0;($k -lt $appSettings.game.Length) -and ($appSettings.game.Length -ne 0);$k++)
    {
        # cls
        $chose = Read-Host "是否安装`""$appSettings.game[$k].name"`"Y/n"
        if($chose -eq "Y"||$chose -eq "y")
        {
            Write-Host "正在安装"$appSettings.game[$k].name"from"$appSettings.game[$k].url -ForegroundColor Green
            $exe_path = $DownloadsPath+"\"+$k+".exe"
            $client = [System.Net.WebClient]::new()
            $client.DownloadFile($appSettings.game[$k].url,$exe_path)
            Start-Process $exe_path -Wait
            Remove-Item $exe_path -Force
        }
        elseif($chose -eq "N"||$chose -eq "n")
        {
            cls
        }
    }
    Remove-Item $DownloadsPath -Force
}
elseif($chose -eq "N"||$chose -eq "n")
{
    cls
}


winget upgrade --all

