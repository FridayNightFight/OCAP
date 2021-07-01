<#

	IndigoFox#6290
	2021-05-01

	HOW TO USE

	Install ImageMagick from https://legacy.imagemagick.org/script/download.php
	This is a command-line image processing utility we'll use for this process.


	Grab a marker from the game files. You can find the pbo path using the in-game CfgViewer >> CfgMarkers.

	Extract the PBO and locate the actual image files (PAA). You'll use TexView2 to convert this to a .png file.

	Create a new folder under ocap-web\static\images\markers with the exact marker 'type' name (such as hd_dot).
	Inside of it,
	place the converted .png file. It will be white.

	Rename the file to "FFFFFF.png".

	The Javascript display of the map during playback looks at the marker color that was placed in-game and matches the hex color to the filename of an image under the marker type name. This means we need a hex code file of the matching color.


	Open a new Powershell window in the directory containing your "FFFFFF.png" file,
	and post the below code in. It will automatically process colored markers for each hex code.

#>





Write-Warning "Please open this file in a text editor and read the instructions on how to use it."
Pause
exit




# FOR MAGICONS -- Run in markers/magIcons
# IFA/FOW changes white to "EDEBBA"
$ParentPath = (Get-Location).Path
ForEach ($Folder in (Get-ChildItem -Directory | ForEach-Object FullName)) {
	# $Folder = Get-Location
	Set-Location $Folder
	Copy-Item -Path ".\FFFFFF.png" -Destination ".\EDEBBA.png"
}




# FOR GENERAL COLORIZED MARKERS
$ParentPath = (Get-Location).Path
ForEach ($Folder in (Get-ChildItem -Directory | ForEach-Object FullName)) {
	$TargetColors = @(
		"000000",
		"0000FF",
		"004C99",
		"008000",
		"00CC00",
		"660080",
		"678B9B",
		"800000",
		"804000",
		"808080",
		"809966",
		"ADBF83",
		"B040A7",
		"B13339",
		"B29900",
		"D96600",
		"D9D900",
		"E60000",
		"F08231",
		"FF4C66",
		"FFFFFF"
		"261C1C",
		"808080",
		"BA3B2B",
		"523836",
		"D6960D",
		"E0C91A",
		"A39947",
		"528C3D",
		"404F9C",
		"EDB8C9",
		"EDEBBA",
		"B13339",
		"ADBF83",
		"F08231",
		"678B9B",
		"B040A7",
		"5A595A",
		"B21A00",
		"009900",
		"000000",
		"B21A00",
		"009900",
		"1A1AE6",
		"CC9900",
		"CCCCCC"
	)
	# $Folder = Get-Location
	Set-Location $Folder
	if (Test-Path ".\FFFFFF.png") {
		ForEach ($ColorHex in $TargetColors) {
			# magick convert "$Folder\FFFFFF.png" -fuzz 5% -fill "#$ColorHex" -opaque "#FFFFFF" -colorize 10 "$ColorHex.png"
			# magick "$Folder\FFFFFF.png" -fuzz 80% -fill "#$ColorHex" -opaque "#FFFFFF" "$ColorHex.png"
			if ($ColorHex -eq "000000") {
				magick ".\FFFFFF.png" -fuzz 90% -fill "#444444" -opaque "#FFFFFF" "000000.png"
			} else {
				magick ".\FFFFFF.png" -fuzz 90% -fill "#$ColorHex" -opaque "#FFFFFF" "$ColorHex.png"
			}
		}
	}
}