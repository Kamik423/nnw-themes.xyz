# Contributing

## Creating Your Own Theme

Refer to [the technote](https://github.com/Ranchero-Software/NetNewsWire/blob/main/Technotes/Themes.md) and the insanely well documented [Promenade theme](/themes/Promenade).

## Submitting Your Own Theme

Create a pull request with your theme on [the GitHub repo](https://github.com/Kamik423/NetNewsWire-Themes).
Include the .nnwtheme-bundle as a zip and take screenshots of the same size in both light and dark mode (if applicable) in the `Resources/themes/YourThemeName` directory.
Make sure the spelling of your theme name is consistent, including capitalization.
Match the format of the other themes by creating a MarkDown file in `Content/themes`, matching this format:

```
---
date: YYYY-MM-DD HH-MM
creator: Your Name
tags: Theme Mode Tag, Theme Color Tag
link: OptionalLinkToThemeWebsite.com
---

Put an optional description paragraph here.
```

The tags need to contain either `User Theme` or `Default Theme` depending on whether it comes preinstalled or not.
It also needs to have one of `Light and Dark`, `Dark Only` or `Light Only`, depending on whether it has good support for these modes.
The screenshots should be in the same folder as the theme zip and named `ThemeName-light.png` and `ThemeName-dark.png` respectively.
If you only support light or dark mode just name it `ThemeName.png`.

Then build the site using

```
publish generate
```

You might need to first install publish with

```
brew install publish
```

If this is beyond your capabilities that is ok, please note so in the pull request.

## Linking Your Website

You can link a personal website by adding your name to the `Content/websites.json` file.
To link a website for your theme fill in the `link` tag.

## License

You can include your own license in the `.nnwtheme`-bundle.
Please then also note the license in the description.
If you do not include a license the theme is presumed to be license under the [MIT license](/license), as are the rest of the documents included in this repository.
