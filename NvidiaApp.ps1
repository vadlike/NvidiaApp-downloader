Add-Type -AssemblyName System.Windows.Forms

# ������� ������ ����� ����� ������
function Select-DownloadFolder {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "�������� ����� ��� ���������� ������������� ����� NVIDIA App"
    $folderBrowser.ShowNewFolderButton = $true

    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderBrowser.SelectedPath
    } else {
        Write-Host "����� ����� ������. ���������� ������."
        exit
    }
}

# ����������� � ������������ �����
$saveFolder = Select-DownloadFolder

# ���������� URL �������� �������� NVIDIA App
$downloadPageUrl = "https://www.nvidia.com/en-us/software/nvidia-app/"

# �������� ���������� ��������
try {
    $webPage = Invoke-WebRequest -Uri $downloadPageUrl -UseBasicParsing
} catch {
    Write-Host "������ ��� ��������� �������� ��������: $_"
    exit
}

# ���� ������ �� ������������ ����
$installerUrl = $webPage.Links | Where-Object { $_.href -match 'NVIDIA_App.*\.exe$' } | Select-Object -First 1 -ExpandProperty href

if (-not $installerUrl) {
    Write-Host "�� ������� ����� ������ �� ������������ ���� NVIDIA App."
    exit
}

# ����������� ������������� ������ � ����������, ���� ����������
if ($installerUrl -notmatch '^https?://') {
    $uri = New-Object System.Uri($downloadPageUrl)
    $installerUrl = "$($uri.Scheme)://$($uri.Host)$installerUrl"
}

# ��������� ���� ����������
$installerPath = Join-Path -Path $saveFolder -ChildPath "NVIDIA_App_Installer.exe"

# ��������� ������������ ����
Write-Host "���������� NVIDIA App � $installerUrl..."
try {
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
} catch {
    Write-Host "������ ��� ���������� ������������� �����: $_"
    exit
}

# ��������� ��������� � ����� ������
Write-Host "��������� NVIDIA App..."
try {
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
} catch {
    Write-Host "������ ��� ��������� NVIDIA App: $_"
    exit
}



Write-Host "NVIDIA App ������� �����������."
