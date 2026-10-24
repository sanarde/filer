# Sanar Filer

File manager for SanarDE.

## Dependencies

- Qt 6.8 or newer (Core, Gui, Quick)
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

## Acknowledgments

- [Roboto Flex](https://github.com/TypeNetwork/Roboto-Flex), SIL Open Font License 1.1
- [Material Symbols](https://github.com/google/material-design-icons), Apache License 2.0

Font files and license texts are in `resources/fonts`. The icon font is a subset; to change the icon set, edit `tools/icon-names.txt` and run `tools/subset-icons.sh` with the full font and codepoints file.

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## License

GNU General Public License v3.0. See [LICENSE](LICENSE).
