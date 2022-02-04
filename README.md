# Unofficial Official NetNewsWire Themes Directory

This is a theme directory for the [NetNewsWire](https://netnewswire.com) RSS reader.

To install a theme you have to download the zip, unpack it and import it to NetNewsWire by either double-clicking it on macOS, sharing it to NetNewsWire on iOS or using the `+` button on iOS.
NetNewsWire has an URL scheme for this but GitHub [strips non-http URL schemes](https://github.community/t/deeplink-urls-are-stripped-from-github-markdown/199464).
The install URL is included as text, you can copy it and open it your browser.

## Preinstalled Themes

### Default

Ranchero Software, 2022-02

This theme is not actually shipped with NetNewsWire as a theme and has instead been reconstructed from the HTML and CSS in the app bundle.
This is the theme that is preset in NetNewsWire.

<img src="default-themes/Default_/Default-light.png" width="50%"><img src="default-themes/Default_/Default-dark.png" width="50%">

`netnewswire://theme/add?url=https://github.com/Kamik423/NetNewsWire-Themes/raw/main/default-themes/Default_/Default_.nnwtheme.zip`

### Appanoose

Ranchero Software, 2022-02

<img src="default-themes/Appanoose/Appanoose-light.png" width="50%"><img src="default-themes/Appanoose/Appanoose-dark.png" width="50%">

`netnewswire://theme/add?url=https://github.com/Kamik423/NetNewsWire-Themes/raw/main/default-themes/Appanoose/Appanoose.nnwtheme.zip`

### Promenade

Stuart Breckenridge, 2022-02

This is the best documented theme you can use this as reference for your own theme.

<img src="default-themes/Promenade/Promenade-light.png" width="50%"><img src="default-themes/Promenade/Promenade-dark.png" width="50%">

`netnewswire://theme/add?url=https://github.com/Kamik423/NetNewsWire-Themes/raw/main/default-themes/Promenade/Promenade.nnwtheme.zip`

### Sepia

Ranchero Software, 2022-02

This theme does not differentiate between light and dark modes.

<img src="default-themes/Sepia/Sepia.png" width="50%">

`netnewswire://theme/add?url=https://github.com/Kamik423/NetNewsWire-Themes/raw/main/default-themes/Sepia/Sepia.nnwtheme.zip`

## User Created Themes

### Druckpresse

Hans Schülein, 2022-02

<img src="user-themes/Druckpresse/Druckpresse-light.png" width="50%"><img src="user-themes/Druckpresse/Druckpresse-dark.png" width="50%">

`netnewswire://theme/add?url=https://github.com/Kamik423/NetNewsWire-Themes/raw/main/user-themes/Druckpresse/Druckpresse.nnwtheme.zip`

## Contributing your own theme

Create a pull request with your theme.
Include the `.nnwtheme`-bundle as a zip and take screenshots of the same size in both light and dark mode (if applicable) in the same directory.
Include the theme in the *User Created Themes* folder of the README (keep the order alphabetical).
Match the format of the other themes; including

* An author and a date
* Optionally: A description of the theme
* One or two images of the same size set to 50% width
* The NetNewsWire URL scheme.

## License

You can include your own license in the `.nnwtheme`-bundle.
Please then also note the license in the readme.
If you do not include a license the theme is presumed to be license under the [MIT license](LICENSE.md), as are the rest of the documents included in this repository.