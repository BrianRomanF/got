# Running on a personal iPhone

Open `Collector.xcodeproj`, select the `Collector` scheme and your iPhone,
then run with the Debug configuration.

Debug uses `LocalDevice.entitlements` and `LOCAL_DEVICE_BUILD` so the app and
widget can be signed for local device testing. Collections stay on the device;
iCloud sync and push notifications are disabled. App Group sharing is enabled
for `group.com.brianroman.Collectorappmen` in both targets so widgets show real data.

Debug with `LOCAL_DEVICE_BUILD` also unlocks Pro for local testing without
StoreKit or App Store Connect. This override is kept in memory and does not
write a purchased entitlement to device storage. Release uses real purchases.

Release keeps the original iCloud, push and App Group entitlements and requires
a development team and provisioning profiles that support those capabilities.

The Books widget shows up to four currently reading books from the shared
snapshot, with the most recently updated book featured. Tapping a book uses
`gotit://reading/<item UUID>` to open its progress editor, including books on
nested shelves. `gotit://reading` opens the most recently updated current book.
Open the app after installing to publish the library to the shared App Group.
Saving a reading update publishes a new snapshot and requests a widget refresh.
