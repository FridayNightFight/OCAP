ForEach ($file in (Get-ChildItem -File | ForEach-Object name)) {
	New-Item -Path ".\magIcons" -Name "$(${file} -replace '.paa','')" -Type Directory -Force
	Copy-Item -Path ".\$file" -Destination ".\magIcons\$(${file} -replace '.paa', '')" -Force -EA SilentlyContinue
	Rename-Item -Path ".\magIcons\$(${file} -replace '.paa', '')\${file}" -NewName "FFFFFF.paa" -Force -EA SilentlyContinue
	. "K:\SteamLibrary\steamapps\common\Arma 3 Tools\TexView2\Pal2PacE.exe" ".\magIcons\$(${file} -replace '.paa', '')\FFFFFF.paa" ".\magIcons\$(${file} -replace '.paa', '')\FFFFFF.png"
	Copy-Item ".\magIcons\$(${file} -replace '.paa', '')\FFFFFF.png" ".\magIcons\$(${file} -replace '.paa', '')\000000.png"
	Remove-Item -Path ".\magIcons\$(${file} -replace '.paa', '')\*.paa" -Force -EA SilentlyContinue
}