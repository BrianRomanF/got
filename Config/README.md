# Running on a personal iPhone

Open `Collector.xcodeproj`, select the `Collector` scheme and your iPhone,
then run with the Debug configuration.

Debug uses `LocalDevice.entitlements` and `LOCAL_DEVICE_BUILD` so the app and
widget can be signed by a Personal Team. Collections stay on the device;
iCloud sync and App Group sharing are disabled. Widgets show placeholder data.

Release keeps the original iCloud, push and App Group entitlements and requires
a development team and provisioning profiles that support those capabilities.
