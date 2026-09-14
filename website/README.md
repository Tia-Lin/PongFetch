# PongFetch website

Static product website source: homepage, three colour palettes, assembly checklist, downloads and a kit-selection preview. No orders or payments are taken. The website is not deployed by publishing this repository.

## Build downloads and preview

From the repository root, using Python 3 (standard library only):

```sh
python3 website/prepare_downloads.py
python3 website/validate.py
python3 -m http.server 4173 --bind 127.0.0.1 --directory website/dist
```

Open http://127.0.0.1:4173. Generated downloads are ignored by Git; regenerate them after changing the canonical design, print files or documentation. Release ZIPs are produced by the same script.

## Files

- `dist/index.html`: page shell and homepage.
- `dist/content.js`: build guide, downloads, license and kit preview.
- `dist/styles.css`: layout and colour system.
- `dist/app.js`: palettes, navigation, guide progress and kit summary.
- `dist/assets/`: product CAD renders in WebP format.
- `prepare_downloads.py`: current files, licensed archives and SHA-256 manifest.
- `validate.py`: routes, references, file integrity and archive checks.

Colour choices and assembly progress are stored in the browser. Palette selection does not modify downloaded 3MF settings. Palette images are design references; exact Rev 3.0 lettering views are in `previews/` at the repository root. New colour finish still awaits physical validation.

An optional feature-detected WebMCP palette tool is present; ordinary controls do not depend on browser support for it. GitHub and Creative Commons links open external pages when clicked. No analytics or backend account service is included.

## Licensing

Download packages include the CC BY-NC-SA 4.0 design license, its official legal text and third-party notices. Website application code and Python utilities are outside that design-license grant; see the root LICENSE.md. Source downloads link to https://github.com/Tia-Lin/PongFetch.
