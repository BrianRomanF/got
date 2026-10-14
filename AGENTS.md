# Collector

Collector is an iPhone app for organizing personal collections such as comics, video games, vinyl records, figures, and other collectibles.

## Architecture Rules

- Use MVC intentionally, even when a SwiftUI-native pattern could be simpler.
- Keep view-exclusive code inside that view feature folder.
- Prefer single-responsibility files: inputs, buttons, cells, headers, and orchestrating views live separately.
- The main view of a screen should compose smaller views and delegate state decisions to a controller.
- Visible copy should go through `L10n`, backed by `Localizable.strings` and generated with SwiftGen.

## Current Flow

- `Home` lists top-level collections.
- `CategoryDetail` shows shelves/groups and pieces inside a collection.
- `GroupDetail` supports nested shelves/groups and pieces.
- `ItemEditor` creates a collectible piece.
- `ItemDetail` shows a gallery-style detail page.

## SwiftGen

The project includes `swiftgen.yml`. After installing SwiftGen, run:

```sh
swiftgen config run
```

That command should regenerate `Collector/Shared/Generated/L10n.swift`.
