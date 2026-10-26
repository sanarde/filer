# Contributing

## Building

See the Build section of [README.md](README.md). Configure with `-DSANAR_FILER_LOCALEDIR=$PWD/build/locale` to run from the build tree with translations.

## Source layout

- `src/qml`: interface only, no file system logic.
- `src/fs`: directory model, file operations, trash, transfers.
- `src/places`: sidebar places and devices, UDisks2 client.
- `src/nav`: navigation history.
- `src/thumbs`: thumbnail provider, cache, system thumbnailers.
- `src/settings`: settings, stored in cfgd.
- `resources/cfgd`: the cfgd schema of the settings.
- `po`: gettext catalogs.

## Translations

Run `cmake --build build --target update-po` after changing user-visible strings. Translate the new entries in `po/<language>.po` and remove fuzzy markers. Check a catalog with `msgfmt --check --statistics -o /dev/null po/<language>.po`. A new language needs a `.po` file created with `msginit` and its code added to `LANGUAGES` in `po/CMakeLists.txt`.

## Settings

Add a key to the schema in `resources/cfgd` and to `Settings`, with the same default in both.

## Commits

Commits use Conventional Commits with a single-line message, for example `feat: add recent files location`. Each commit contains one logical change and the project builds after it.

## Before submitting

Build the project and run `qmllint` on the changed QML files. There is no automated test suite.
