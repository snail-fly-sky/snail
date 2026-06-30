Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$signature = @"
using System;
using System.Runtime.InteropServices;

public static class WindowApi
{
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
}
"@

Add-Type -TypeDefinition $signature

$script:taskRunning = $false
$script:targetProcess = $null
$script:intervalSeconds = 60
$script:messageText = ""
$script:terminalProcessNames = @("WindowsTerminal", "wt", "cmd", "powershell", "pwsh", "conhost")

function Get-WindowOptions {
    Get-Process |
        Where-Object {
            $_.MainWindowHandle -ne 0 -and
            $_.MainWindowTitle.Trim().Length -gt 0 -and
            $script:terminalProcessNames -contains $_.ProcessName
        } |
        Sort-Object ProcessName, MainWindowTitle |
        ForEach-Object {
            [PSCustomObject]@{
                Display = "$($_.ProcessName) - $($_.MainWindowTitle)"
                Id = $_.Id
                Handle = $_.MainWindowHandle
                Title = $_.MainWindowTitle
            }
        }
}

function Refresh-WindowList {
    param(
        [System.Windows.Forms.ComboBox]$ComboBox
    )

    $previousText = $ComboBox.Text
    $ComboBox.Items.Clear()

    foreach ($window in Get-WindowOptions) {
        [void]$ComboBox.Items.Add($window.Display)
    }

    if ($previousText.Trim().Length -gt 0) {
        $ComboBox.Text = $previousText
    }
}

function Get-WindowQueries {
    param(
        [string]$Query
    )

    $queries = New-Object System.Collections.Generic.List[string]
    $queries.Add($Query)

    if ([System.IO.Path]::IsPathRooted($Query)) {
        $normalizedQuery = $Query.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
        $leafName = [System.IO.Path]::GetFileName($normalizedQuery)
        if ($leafName.Trim().Length -gt 0 -and $leafName -ne $Query) {
            $queries.Add($leafName)
        }
    }

    return $queries
}

function Resolve-TargetWindow {
    param(
        [string]$WindowText
    )

    $query = $WindowText.Trim()
    if ($query.Length -eq 0) {
        throw "请选择一个终端窗口，或输入窗口标题的一部分。"
    }

    $windows = Get-WindowOptions
    $exact = $windows | Where-Object { $_.Display -eq $query } | Select-Object -First 1
    if ($exact) {
        return $exact
    }

    $queries = Get-WindowQueries -Query $query
    $matches = $windows | Where-Object {
        foreach ($item in $queries) {
            if ($_.Display -like "*$item*" -or $_.Title -like "*$item*") {
                return $true
            }
        }

        return $false
    }

    $terminalMatches = $matches | Where-Object { $script:terminalProcessNames -contains $_.ProcessName }
    if (($terminalMatches | Measure-Object).Count -gt 0) {
        $matches = $terminalMatches
    }

    if (($matches | Measure-Object).Count -eq 0) {
        throw "未匹配到可见窗口：$query"
    }

    return $matches | Select-Object -First 1
}

function Send-MessageToWindow {
    param(
        [string]$WindowText,
        [string]$Message
    )

    $target = Resolve-TargetWindow -WindowText $WindowText
    [WindowApi]::ShowWindowAsync([IntPtr]$target.Handle, 9) | Out-Null
    [WindowApi]::SetForegroundWindow([IntPtr]$target.Handle) | Out-Null
    Start-Sleep -Milliseconds 250

    [System.Windows.Forms.Clipboard]::SetText($Message)
    [System.Windows.Forms.SendKeys]::SendWait("^v")
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
}

function Set-Status {
    param(
        [System.Windows.Forms.Label]$Label,
        [string]$Text
    )

    $Label.Text = $Text
}

function Set-ButtonStyle {
    param(
        [System.Windows.Forms.Button]$Button,
        [System.Drawing.Color]$BackColor,
        [System.Drawing.Color]$ForeColor
    )

    $Button.FlatStyle = "Flat"
    $Button.FlatAppearance.BorderSize = 0
    $Button.BackColor = $BackColor
    $Button.ForeColor = $ForeColor
    $Button.UseVisualStyleBackColor = $false
    $Button.Cursor = [System.Windows.Forms.Cursors]::Hand
}

$backgroundColor = [System.Drawing.ColorTranslator]::FromHtml("#F6F8FB")
$surfaceColor = [System.Drawing.ColorTranslator]::FromHtml("#FFFFFF")
$primaryColor = [System.Drawing.ColorTranslator]::FromHtml("#2563EB")
$secondaryColor = [System.Drawing.ColorTranslator]::FromHtml("#E5E7EB")
$dangerColor = [System.Drawing.ColorTranslator]::FromHtml("#DC2626")
$textColor = [System.Drawing.ColorTranslator]::FromHtml("#111827")
$mutedTextColor = [System.Drawing.ColorTranslator]::FromHtml("#6B7280")
$font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$titleFont = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Bold)
$labelFont = New-Object System.Drawing.Font("Microsoft YaHei UI", 9, [System.Drawing.FontStyle]::Bold)

$form = New-Object System.Windows.Forms.Form
$form.Text = "Codex 自动发送"
$form.ClientSize = New-Object System.Drawing.Size(584, 390)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = $backgroundColor
$form.Font = $font

$appTitleLabel = New-Object System.Windows.Forms.Label
$appTitleLabel.Text = "Codex 自动发送"
$appTitleLabel.Location = New-Object System.Drawing.Point(24, 18)
$appTitleLabel.Size = New-Object System.Drawing.Size(240, 30)
$appTitleLabel.Font = $titleFont
$appTitleLabel.ForeColor = $textColor
$form.Controls.Add($appTitleLabel)

$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "按固定间隔向指定终端窗口发送消息"
$subtitleLabel.Location = New-Object System.Drawing.Point(25, 50)
$subtitleLabel.Size = New-Object System.Drawing.Size(430, 22)
$subtitleLabel.ForeColor = $mutedTextColor
$form.Controls.Add($subtitleLabel)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "目标终端窗口"
$titleLabel.Location = New-Object System.Drawing.Point(24, 88)
$titleLabel.Size = New-Object System.Drawing.Size(180, 22)
$titleLabel.Font = $labelFont
$titleLabel.ForeColor = $textColor
$form.Controls.Add($titleLabel)

$windowBox = New-Object System.Windows.Forms.ComboBox
$windowBox.Location = New-Object System.Drawing.Point(24, 114)
$windowBox.Size = New-Object System.Drawing.Size(436, 26)
$windowBox.DropDownStyle = "DropDown"
$windowBox.BackColor = $surfaceColor
$windowBox.ForeColor = $textColor
$windowBox.FlatStyle = "Flat"
$form.Controls.Add($windowBox)

$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Text = "刷新"
$refreshButton.Location = New-Object System.Drawing.Point(472, 112)
$refreshButton.Size = New-Object System.Drawing.Size(84, 30)
Set-ButtonStyle -Button $refreshButton -BackColor $secondaryColor -ForeColor $textColor
$form.Controls.Add($refreshButton)

$messageLabel = New-Object System.Windows.Forms.Label
$messageLabel.Text = "消息内容"
$messageLabel.Location = New-Object System.Drawing.Point(24, 154)
$messageLabel.Size = New-Object System.Drawing.Size(120, 22)
$messageLabel.Font = $labelFont
$messageLabel.ForeColor = $textColor
$form.Controls.Add($messageLabel)

$messageBox = New-Object System.Windows.Forms.TextBox
$messageBox.Location = New-Object System.Drawing.Point(24, 180)
$messageBox.Size = New-Object System.Drawing.Size(532, 88)
$messageBox.Multiline = $true
$messageBox.ScrollBars = "Vertical"
$messageBox.Text = "你好"
$messageBox.BackColor = $surfaceColor
$messageBox.ForeColor = $textColor
$messageBox.BorderStyle = "FixedSingle"
$form.Controls.Add($messageBox)

$intervalLabel = New-Object System.Windows.Forms.Label
$intervalLabel.Text = "间隔秒数"
$intervalLabel.Location = New-Object System.Drawing.Point(24, 286)
$intervalLabel.Size = New-Object System.Drawing.Size(76, 26)
$intervalLabel.Font = $labelFont
$intervalLabel.ForeColor = $textColor
$intervalLabel.TextAlign = "MiddleLeft"
$form.Controls.Add($intervalLabel)

$intervalInput = New-Object System.Windows.Forms.NumericUpDown
$intervalInput.Location = New-Object System.Drawing.Point(112, 282)
$intervalInput.Size = New-Object System.Drawing.Size(120, 28)
$intervalInput.Minimum = 1
$intervalInput.Maximum = 86400
$intervalInput.Value = 60
$intervalInput.BackColor = $surfaceColor
$intervalInput.ForeColor = $textColor
$intervalInput.BorderStyle = "FixedSingle"
$form.Controls.Add($intervalInput)

$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "开始"
$startButton.Location = New-Object System.Drawing.Point(24, 344)
$startButton.Size = New-Object System.Drawing.Size(104, 34)
Set-ButtonStyle -Button $startButton -BackColor $primaryColor -ForeColor $surfaceColor
$form.Controls.Add($startButton)

$stopButton = New-Object System.Windows.Forms.Button
$stopButton.Text = "停止"
$stopButton.Location = New-Object System.Drawing.Point(250, 344)
$stopButton.Size = New-Object System.Drawing.Size(104, 34)
$stopButton.Enabled = $false
Set-ButtonStyle -Button $stopButton -BackColor $dangerColor -ForeColor $surfaceColor
$form.Controls.Add($stopButton)

$sendNowButton = New-Object System.Windows.Forms.Button
$sendNowButton.Text = "立即发送"
$sendNowButton.Location = New-Object System.Drawing.Point(136, 344)
$sendNowButton.Size = New-Object System.Drawing.Size(104, 34)
Set-ButtonStyle -Button $sendNowButton -BackColor $secondaryColor -ForeColor $textColor
$form.Controls.Add($sendNowButton)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "就绪。关闭此窗口将退出脚本。"
$statusLabel.Location = New-Object System.Drawing.Point(24, 318)
$statusLabel.Size = New-Object System.Drawing.Size(532, 20)
$statusLabel.ForeColor = $mutedTextColor
$statusLabel.BackColor = $backgroundColor
$form.Controls.Add($statusLabel)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 60000

$refreshButton.Add_Click({
    Refresh-WindowList -ComboBox $windowBox
})

$sendNowButton.Add_Click({
    try {
        Send-MessageToWindow -WindowText $windowBox.Text -Message $messageBox.Text
        Set-Status -Label $statusLabel -Text "已于 $(Get-Date -Format HH:mm:ss) 发送一次。"
    }
    catch {
        Set-Status -Label $statusLabel -Text $_.Exception.Message
    }
})

$startButton.Add_Click({
    try {
        $script:messageText = $messageBox.Text
        if ($script:messageText.Trim().Length -eq 0) {
            throw "消息内容不能为空。"
        }

        $script:targetProcess = Resolve-TargetWindow -WindowText $windowBox.Text
        $script:intervalSeconds = [int]$intervalInput.Value
        $timer.Interval = $script:intervalSeconds * 1000
        $timer.Start()

        $script:taskRunning = $true
        $startButton.Enabled = $false
        $stopButton.Enabled = $true
        $windowBox.Enabled = $false
        $messageBox.Enabled = $false
        $intervalInput.Enabled = $false

        Set-Status -Label $statusLabel -Text "正在运行，每 $script:intervalSeconds 秒发送一次。"
    }
    catch {
        Set-Status -Label $statusLabel -Text $_.Exception.Message
    }
})

$stopButton.Add_Click({
    $timer.Stop()
    $script:taskRunning = $false
    $startButton.Enabled = $true
    $stopButton.Enabled = $false
    $windowBox.Enabled = $true
    $messageBox.Enabled = $true
    $intervalInput.Enabled = $true
    Set-Status -Label $statusLabel -Text "已停止。"
})

$timer.Add_Tick({
    if (-not $script:taskRunning) {
        return
    }

    try {
        Send-MessageToWindow -WindowText $script:targetProcess.Display -Message $script:messageText
        Set-Status -Label $statusLabel -Text "上次发送时间：$(Get-Date -Format HH:mm:ss)。"
    }
    catch {
        $timer.Stop()
        $script:taskRunning = $false
        $startButton.Enabled = $true
        $stopButton.Enabled = $false
        $windowBox.Enabled = $true
        $messageBox.Enabled = $true
        $intervalInput.Enabled = $true
        Set-Status -Label $statusLabel -Text $_.Exception.Message
    }
})

$form.Add_Shown({
    Refresh-WindowList -ComboBox $windowBox
})

$form.Add_FormClosed({
    $timer.Stop()
    $timer.Dispose()
    [System.Windows.Forms.Application]::Exit()
})

[System.Windows.Forms.Application]::EnableVisualStyles()
[void]$form.ShowDialog()
