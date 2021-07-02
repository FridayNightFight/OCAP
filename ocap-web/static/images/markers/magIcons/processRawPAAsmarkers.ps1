$cfgMarkers = Import-Csv ".\CfgMarkers.csv"

ForEach ($file in (Get-ChildItem -File | ForEach-Object name)) {
	if ($file -contains '.ps1' -or $file -contains 'ps1' -or $file -contains 'csv') {continue}
	ForEach ($line in $cfgMarkers) {
		if ($file -eq ($line.'Icon Path' -split '\\')[-1] -and (Test-Path $file)) {
			New-Item -Path ".\temp" -Name $line.class -Type Directory -Force
			Copy-Item -Path ".\$file" -Destination ".\temp\$($line.Class)" -Force -EA SilentlyContinue
			Rename-Item -Path ".\temp\$($line.Class)\${file}" -NewName "FFFFFF.paa" -Force -EA SilentlyContinue
			. "K:\SteamLibrary\steamapps\common\Arma 3 Tools\TexView2\Pal2PacE.exe" ".\temp\$($line.Class)\FFFFFF.paa" ".\temp\$($line.Class)\FFFFFF.png"
			Copy-Item ".\temp\$($line.Class)\FFFFFF.png" ".\temp\$($line.Class)\000000.png"
			Remove-Item -Path ".\temp\$($line.Class)\*.paa" -Force -EA SilentlyContinue
			Remove-Item $file
		}
	}
	# New-Item -Path ".\temp" -Name "$(${file} -replace '.paa','')" -Type Directory -Force
	# Copy-Item -Path ".\$file" -Destination ".\temp\$(${file} -replace '.paa', '')" -Force -EA SilentlyContinue
	# Rename-Item -Path ".\temp\$(${file} -replace '.paa', '')\${file}" -NewName "FFFFFF.paa" -Force -EA SilentlyContinue
	# . "K:\SteamLibrary\steamapps\common\Arma 3 Tools\TexView2\Pal2PacE.exe" ".\temp\$(${file} -replace '.paa', '')\FFFFFF.paa" ".\temp\$(${file} -replace '.paa', '')\FFFFFF.png"
	# Copy-Item ".\temp\$(${file} -replace '.paa', '')\FFFFFF.png" ".\temp\$(${file} -replace '.paa', '')\000000.png"
	# Remove-Item -Path ".\temp\$(${file} -replace '.paa', '')\*.paa" -Force -EA SilentlyContinue
}