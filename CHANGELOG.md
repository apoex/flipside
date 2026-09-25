## [Unreleased]
- Show entities whose record has been deleted instead of raising in the UI
- Add `Flipside::Flippable` with `flipside_entity` and `flipside_role`, so models can register themselves (listed in `Flipside.flippables`); entities of a destroyed record are removed
- Add `Flipside.prune_orphaned_entities`
- Registering the same role twice no longer lists it twice

## [0.3.4] - 2026-03-04
- Support an array of default objects

## [0.3.3] - 2025-08-21
- Move gem ownership

## [0.3.2] - 2025-05-28
- Add button to delete a feature
- Make switch light blue when feature is partially enabled

## [0.3.1] - 2025-05-15
- Remove dependency on sinatra

## [0.3.0] - 2025-05-14
- Rewrite Sinatra UI to Roda
- Fix links not respecting mount point
- Add Cache-Control header for js files

## [0.2.2] - 2025-04-25

- Add disabled? method
- Edit feature description from UI
- Add configuration for setting default_object

## [0.2.1] - 2025-01-30

- Option to create missing features
- Option to set link back to main application

## [0.2.0] - 2025-01-29

- Support checking multiple objects at once
- Show hover text for feature statuses
- Support feature names with spaces

## [0.1.1] - 2024-11-22

- Fix missing js files for web UI

## [0.1.0] - 2024-11-22

- Initial release
