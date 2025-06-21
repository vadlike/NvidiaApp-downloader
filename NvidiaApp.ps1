Add-Type -AssemblyName System.Windows.Forms

# Функция выбора папки через диалог
function Select-DownloadFolder {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Выберите папку для сохранения установочного файла NVIDIA App"
    $folderBrowser.ShowNewFolderButton = $true

    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderBrowser.SelectedPath
    } else {
        Write-Host "Выбор папки отменён. Завершение работы."
        exit
    }
}

# Запрашиваем у пользователя папку
$saveFolder = Select-DownloadFolder

# Определяем URL страницы загрузки NVIDIA App
$downloadPageUrl = "https://www.nvidia.com/en-us/software/nvidia-app/"

# Получаем содержимое страницы
try {
    $webPage = Invoke-WebRequest -Uri $downloadPageUrl -UseBasicParsing
} catch {
    Write-Host "Ошибка при получении страницы загрузки: $_"
    exit
}

# Ищем ссылку на установочный файл
$installerUrl = $webPage.Links | Where-Object { $_.href -match 'NVIDIA_App.*\.exe$' } | Select-Object -First 1 -ExpandProperty href

if (-not $installerUrl) {
    Write-Host "Не удалось найти ссылку на установочный файл NVIDIA App."
    exit
}

# Преобразуем относительную ссылку в абсолютную, если необходимо
if ($installerUrl -notmatch '^https?://') {
    $uri = New-Object System.Uri($downloadPageUrl)
    $installerUrl = "$($uri.Scheme)://$($uri.Host)$installerUrl"
}

# Формируем путь сохранения
$installerPath = Join-Path -Path $saveFolder -ChildPath "NVIDIA_App_Installer.exe"

# Скачиваем установочный файл
Write-Host "Скачивание NVIDIA App с $installerUrl..."
try {
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
} catch {
    Write-Host "Ошибка при скачивании установочного файла: $_"
    exit
}

# Запускаем установку в тихом режиме
Write-Host "Установка NVIDIA App..."
try {
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
} catch {
    Write-Host "Ошибка при установке NVIDIA App: $_"
    exit
}



Write-Host "NVIDIA App успешно установлено."
