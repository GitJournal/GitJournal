source = ["build/macos/Build/Products/Release/GitJournal.app"]
bundle_id = "io.gitjournal.gitjournal"

apple_id {
  username = "ios.ci@gitjournal.io"
  password = "@env:FASTLANE_PASSWORD"
}

sign {
  application_identity = "Developer ID Application: Vishesh Handa (4NYTN6RU3N)"
  entitlements_file = "macos/Runner/Release.entitlements"
}

dmg {
  output_path = "GitJournal.dmg"
  volume_name = "GitJournal"
}
