# Running on a personal iPhone

Open `Collector.xcodeproj`, select the `Collector` scheme and your iPhone,
then run with the Debug configuration.

Debug uses `Collector/Collector.entitlements`; Release uses
`Config/AppStore.entitlements` with production CloudKit entitlements.
The widget uses `CollectorWidgets/CollectorWidgets.entitlements`, with manual signing
for team `3H2J727ZZN`.

The app bundle ID is `com.brianroman.Collectorappmen`. The embedded widget bundle
ID must start with the app bundle ID followed by a dot, so the project uses
`com.brianroman.Collectorappmen.widget`. Register that widget ID with
the account holder; `com.Collectorap.CollectorWidgets` cannot be embedded in this app.

Release uses Apple Distribution for App Store Connect / TestFlight, with profiles
`Gotit AppStore` for the app and `Gotit Widget AppStore` for the widget. The
app profile authorizes `group.com.brianroman.gotit` and
`iCloud.com.brianroman.gotit`. The regenerated widget profile also authorizes the
shared group; Release selects its UUID `c211d388-293e-4ec2-82de-1d686862a1da` to
avoid selecting the older profile with the same name. Push Notifications are not required by this build:
CloudKit is checked when the app becomes active or through Settings, without
registering subscriptions or handling remote notifications.
App Store Connect profiles do not require registered iPhones.

Debug uses Apple Development and requires separate development profiles with
the test device included. The installed development certificate is
`Apple Development: Cristian Bahamondes (6SLM6BYX8Y)`; this suffix is not the team ID.

The app uses CloudKit container `iCloud.com.brianroman.gotit` and both
targets share `group.com.brianroman.gotit`. These identifiers must be
registered with the selected team and associated with the appropriate App IDs
before generating profiles.

Debug with `LOCAL_DEVICE_BUILD` still unlocks Pro for local testing without
StoreKit or App Store Connect. This override is kept in memory and does not
write a purchased entitlement to device storage. Release uses real purchases.
`LOCAL_DEVICE_BUILD` no longer disables CloudKit.

`LocalDevice.entitlements` is retained as a legacy local-only entitlement file;
it is not selected by the app or widget build configurations.

The Books widget shows the single currently reading book from the shared
snapshot, with its cover thumbnail (or a book icon when unavailable) and progress. Selecting another current book
removes the previous book's reading status while preserving its pages and dates.
Existing libraries with multiple current books keep the most recently updated
one selected. Comics retain their independent reading statuses. Tapping a book uses
`gotit://reading/<item UUID>` to open its progress editor, including books on
nested shelves. `gotit://reading` opens the most recently updated current book.
Open the app after installing to publish the library to the shared App Group.
Saving a reading update publishes a new snapshot and requests a widget refresh.

Open a comics series and select Follow this series to feature it in the Comics
widget. Following is exclusive across comics collections and is saved with the
series. The widget shows that series' owned/missing counts and the first issue's
cover, ordered by issue number. Tapping opens the series via
`gotit://comics/<category UUID>/<group UUID>`. Covers are downsampled to at most
160 pixels and stored in the shared snapshot for both books and comics.

Open an album and select Feature in widget to make it the single favorite album
across vinyl collections. The Vinyl widget shows its square cover, title and
subtitle, and a random track from that Discogs release. Without an explicit favorite,
the previous tagged/recently added owned-album selection remains the fallback.
The favorite flag is saved with the item and preserved by the editor. Tapping
uses `gotit://vinyl/<item UUID>` and resolves albums on nested shelves as well.

Discogs release IDs are retained by new imports. Older albums are resolved only
when the album title and artist or catalog number match a search result. Release
tracklists exclude headings and expand subtracks. The app caches the artwork and
tracklist before sharing them with the widget; API credentials stay in the app.
Remote artwork and rebased local cover paths are supported. Widget timelines
schedule shuffled tracks at 30-minute intervals using cached data, without
depending on network access in the extension.

## Manual App Store Connect export

The Organizer's automatic distribution flow may try to fetch profiles from the
account holder's team, which is unavailable to an App Store Connect-only member.
Select Custom distribution and manually manage signing, importing the local
profiles for both targets if necessary. `Config/ExportOptions-AppStore.plist`
records the verified manual export configuration, including exact profile UUIDs.
Update those UUIDs if the account holder regenerates the profiles.

To export an existing signed archive locally without uploading it:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -exportArchive \
  -archivePath /private/tmp/Gotit-AppStore-20261018.xcarchive \
  -exportOptionsPlist Config/ExportOptions-AppStore.plist \
  -exportPath /private/tmp/Gotit-AppStore-export
```

The exported IPA can be uploaded with Transporter using an Apple account that
has permission to upload builds to the app in App Store Connect.
