# Running on a personal iPhone

Open `Collector.xcodeproj`, select the `Collector` scheme and your iPhone,
then run with the Debug configuration.

Debug uses `LocalDevice.entitlements` and `LOCAL_DEVICE_BUILD` so the app and
widget can be signed by a Personal Team. Collections stay on the device;
iCloud sync and App Group sharing are disabled. Widgets show placeholder data.

Debug with `LOCAL_DEVICE_BUILD` also unlocks Pro for local testing without
StoreKit or App Store Connect. This override is kept in memory and does not
write a purchased entitlement to device storage. Release uses real purchases.

Release keeps the original iCloud, push and App Group entitlements and requires
a development team and provisioning profiles that support those capabilities.
