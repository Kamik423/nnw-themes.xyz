import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct ThemeSite: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case themes
        case contributing
        case license
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
        var creator: String
        var themelink: String?
        var ziplink: String?
        var link: String?
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://nnw-themes.xyz/")!
    var name = "Unofficial Official NetNewsWire Themes Directory"
    var description = ""
    var language: Language { .english }
    var imagePath: Path? { nil }
    var favicon: Favicon? { Favicon(path: "website-resources/favicon.png", type: "image/png") }
}

let default_theme_tag = "Default Theme"
let user_theme_tag = "User Theme"
let theme_modes = [user_theme_tag, default_theme_tag]
let light_theme_tag = "Light Only"
let dark_theme_tag = "Dark Only"
let mixed_theme_tag = "Light and Dark"
let light_modes = [mixed_theme_tag, dark_theme_tag, light_theme_tag]
let all_tags = theme_modes + light_modes

extension Tag {
    var is_creator: Bool {
        return !all_tags.contains(self.string)
    }
}

extension Item {
    var isDefaultTheme: Bool { return self.tags.map(\.string).contains(default_theme_tag) }
    var isUserTheme: Bool { return self.tags.map(\.string).contains(user_theme_tag) }
    var isLightTheme: Bool { return self.tags.map(\.string).contains(light_theme_tag) }
    var isDarkTheme: Bool { return self.tags.map(\.string).contains(dark_theme_tag) }
    var isMixedTheme: Bool { return self.tags.map(\.string).contains(mixed_theme_tag) }
}

func resourceExists(at path: String) -> Bool {
	// APFS may be case insensitive thus this more complex process is required
    let abspath = "\(FileManager.default.currentDirectoryPath)/Resources/\(path)"
    var matches: Bool = false
    let fd = open(FileManager.default.fileSystemRepresentation(withPath: abspath), O_RDONLY)
    if fd != -1 {
        var buffer = [CChar](repeating: 0, count: Int(MAXPATHLEN))
        if fcntl(fd, F_GETPATH, &buffer) != -1 {
            matches = String(cString: buffer) == abspath
        }
        close(fd)
    }
    return matches
}

// This will generate your website using the built-in Foundation theme:
try ThemeSite().publish(
    withTheme: .fountain,
    additionalSteps: [
        .step(named: "Tag Validation") { context in
                let allItems = context.sections.flatMap { $0.items }
                for item in allItems {
                    // All tags must be known tags
                    let incorrect_tag = item.tags.first(where: { !all_tags.contains($0.string) } )
                    guard incorrect_tag == nil else {
                        throw PublishingError(
                            path: item.path,
                            infoMessage: "[\(incorrect_tag!)] is not a valid tag, must be one of \(all_tags)."
                        )
                    }
                    // Must have exactly one theme mode
                    guard item.tags.filter({ theme_modes.contains($0.string) }).count == 1 else {
                        throw PublishingError(
                            path: item.path,
                            infoMessage: "Must have exactly one tag from \(theme_modes)."
                        )
                    }
                    // Must have exactly one light mode
                    guard item.tags.filter({ light_modes.contains($0.string) }).count == 1 else {
                        throw PublishingError(
                            path: item.path,
                            infoMessage: "Must have exactly one tag from \(light_modes)."
                        )
                    }
                }
            },
        .step(named: "Create Creators") { context in
            // Create tags for creators
            context.mutateAllSections { section in
                section.mutateItems { item in
                    item.tags.insert(Tag(item.metadata.creator), at: 0)
                }
            }
        },
        .step(named: "Create Links") { context in
            // Create the download badges
            var error: PublishingError? = nil
            context.mutateAllSections { section in
                section.mutateItems { item in
                    let file_url = "themes/\(item.title)/\(item.title).nnwtheme.zip"
                    let web_url = "https://nnw-themes.xyz/\(file_url)"
                    item.metadata.ziplink = web_url
                    item.metadata.themelink = "netnewswire://theme/add?url=\(web_url)"
                    // Couldn't get throwing here to work
                    if !resourceExists(at: file_url) {
                        error = PublishingError(
                            path: item.path,
                            infoMessage: "Theme could not be located but was expected at Resources/\(file_url)."
                        )
                    }
                }
            }
            if let error = error {
                throw error
            }
        },
        .step(named: "Verify Screenshots") { context in
            // Verify the screenshots exist
            let allItems = context.sections.flatMap { $0.items }
            for item in allItems {
                if item.isMixedTheme {
                    if !resourceExists(at: "themes/\(item.title)/\(item.title)-light.png") {
                        throw PublishingError(
                            path: item.path,
                            infoMessage: "Screenshot could not be located but was expected at Resources/themes/\(item.title)/\(item.title)-light.png."
                        )
                    }
                    if !resourceExists(at: "themes/\(item.title)/\(item.title)-dark.png") {
                        throw PublishingError(
                            path: item.path,
                            infoMessage: "Screenshot could not be located but was expected at Resources/themes/\(item.title)/\(item.title)-dark.png."
                        )
                    }
                } else {
                    if !resourceExists(at: "themes/\(item.title)/\(item.title).png") {
                        throw PublishingError(
                            path: item.path,
                            infoMessage: "Screenshot could not be located but was expected at Resources/themes/\(item.title)/\(item.title).png."
                        )
                    }
                }
            }
        }
    ]
)
