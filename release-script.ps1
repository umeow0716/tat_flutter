param(
  [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
  [string]$Version
)

Remove-Item "./build/app/outputs/flutter-apk/*"

flutter build apk -t lib/main_beta.dart --flavor beta --target-platform android-arm,android-arm64,android-x64
flutter build apk -t lib/main_beta.dart --flavor beta --target-platform android-arm,android-arm64,android-x64 --split-per-abi

Move-Item -Path "./build/app/outputs/flutter-apk/app-beta-release.apk" -Destination "./build/app/outputs/flutter-apk/TAT_umeow_V${Version}.apk"
Move-Item -Path "./build/app/outputs/flutter-apk/app-beta-release.apk.sha1" -Destination "./build/app/outputs/flutter-apk/TAT_umeow_V${Version}.apk.sha1"

Move-Item -Path "./build/app/outputs/flutter-apk/app-arm64-v8a-beta-release.apk" -Destination "./build/app/outputs/flutter-apk/TAT_umeow_V${Version}_v8a.apk"
Move-Item -Path "./build/app/outputs/flutter-apk/app-arm64-v8a-beta-release.apk.sha1" -Destination "./build/app/outputs/flutter-apk/TAT_umeow_V${Version}_v8a.apk.sha1"

Move-Item -Path "./build/app/outputs/flutter-apk/app-armeabi-v7a-beta-release.apk" -Destination "./build/app/outputs/flutter-apk/TAT_umeow_V${Version}_v7a.apk"
Move-Item -Path "./build/app/outputs/flutter-apk/app-armeabi-v7a-beta-release.apk.sha1" -Destination "./build/app/outputs/flutter-apk/TAT_umeow_V${Version}_v7a.apk.sha1"

Move-Item -Path "./build/app/outputs/flutter-apk/app-x86_64-beta-release.apk" -Destination "./build/app/outputs/flutter-apk/TAT_umeow_V${Version}_x86_64.apk"
Move-Item -Path "./build/app/outputs/flutter-apk/app-x86_64-beta-release.apk.sha1" -Destination "./build/app/outputs/flutter-apk/TAT_umeow_V${Version}_x86_64.apk.sha1"

Write-Output "done!"