# OpenSnap Updates

OpenSnap uses Sparkle with GitHub Releases for archives, this directory for the appcast, and `ReleaseNotes/` for update notes.

## Release inputs

For version `0.1.0-beta.1`, build a signed and notarized archive named `OpenSnap-0.1.0-beta.1.zip`. Give its release-notes file the same basename: `OpenSnap-0.1.0-beta.1.md`.

Every release must increment `CFBundleVersion`. `CFBundleShortVersionString` is the user-facing version.

## Generate the appcast

1. Download Sparkle's official release tools for the exact version pinned in `OpenSnap.xcodeproj`.
2. Place the signed ZIP, matching Markdown release notes, and the current `appcast.xml` in a temporary directory.
3. Run:

   ```sh
   generate_appcast \
     --download-url-prefix "https://github.com/asifcool83/OpenSnap/releases/download/v0.1.0-beta.1/" \
     --release-notes-url-prefix "https://raw.githubusercontent.com/asifcool83/OpenSnap/main/Updates/ReleaseNotes/" \
     temporary-release-directory
   ```

4. Copy the generated `appcast.xml` here and the Markdown file into `ReleaseNotes/`.
5. Upload the ZIP to the matching GitHub Release, then verify the published appcast and update flow before announcing the build.

`generate_appcast` reads the EdDSA private key from the macOS Keychain by default. The private key must never be committed. CI may instead supply it through a protected secret using Sparkle's documented `--ed-key-file -` flow.

The public key is stored as `SUPublicEDKey` in `Configuration/Info.plist`.
