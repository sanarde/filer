# Sanar Filer

File manager for SanarDE.

## Dependencies

- Qt 6.8 or newer (Core, Gui, Quick, DBus)
- CMake 3.21 or newer
- A C++20 compiler
- gettext tools (xgettext, msgmerge, msgfmt)

## Build

```
cmake -S . -B build -G Ninja
cmake --build build
./build/src/sanar-filer
```

## Translations

Message catalogs are in `po`. After changing strings in QML, run `cmake --build build --target update-po`. To run from the build tree, configure with `-DSANAR_FILER_LOCALEDIR=$PWD/build/locale`.

## Palettes

Built-in palettes are in `resources/palettes`. Additional palettes are read from `$XDG_DATA_HOME/sanar-filer/palettes/*.json` (usually `~/.local/share/sanar-filer/palettes`). A file with the id of a built-in palette replaces it. Files with a missing or invalid color are ignored.

A palette file has an `id`, a `name` (a string or an object keyed by language code with an `en` fallback) and two color tables, `light` and `dark`. Each table must contain all keys listed in `resources/palettes/10-teal.json`, with colors written as `#RRGGBB`.

## Thumbnails

Thumbnails are cached in `$XDG_CACHE_HOME/thumbnails` following the freedesktop thumbnail specification. Images are decoded directly. Video and PDF thumbnails are produced by the thumbnailers installed on the system (`/usr/share/thumbnailers/*.thumbnailer`, for example `totem-video-thumbnailer` or `papers-thumbnailer`). Without a matching thumbnailer a generic icon is shown.

## Devices

Removable volumes are listed in the sidebar. Mounting, unmounting and powering off use the UDisks2 service on the system bus. Without the service only mounted volumes are shown and the eject button is not available.

## Acknowledgments

- [Roboto Flex](https://github.com/TypeNetwork/Roboto-Flex), SIL Open Font License 1.1
- [Material Symbols](https://github.com/google/material-design-icons), Apache License 2.0

Font files and license texts are in `resources/fonts`. The icon font is a subset; to change the icon set, edit `tools/icon-names.txt` and run `tools/subset-icons.sh` with the full font and codepoints file.

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## License

GNU General Public License v3.0. See [LICENSE](LICENSE).
