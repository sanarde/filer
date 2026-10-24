# Sanar Filer

File manager for SanarDE.

## Dependencies

- Qt 6.8 or newer (Core, Gui, Quick)
- CMake 3.21 or newer
- A C++20 compiler

## Build

```
cmake -S . -B build -G Ninja
cmake --build build
./build/src/sanar-filer
```

## Acknowledgments

- [Roboto Flex](https://github.com/TypeNetwork/Roboto-Flex), SIL Open Font License 1.1
- [Material Symbols](https://github.com/google/material-design-icons), Apache License 2.0

Font files and license texts are in `resources/fonts`. The icon font is a subset; to change the icon set, edit `tools/icon-names.txt` and run `tools/subset-icons.sh` with the full font and codepoints file.

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## License

GNU General Public License v3.0. See [LICENSE](LICENSE).
