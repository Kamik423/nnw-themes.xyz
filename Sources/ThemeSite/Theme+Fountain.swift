import Foundation
import Publish
import Plot

public extension Theme {
    /// A modification of the foundation theme
    static var fountain: Self {
        Theme(
            htmlFactory: FountainHTMLFactory(),
            resourcePaths: ["Resources/website-resources/styles.css"]
        )
    }
}

private struct FountainHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    Paragraph(index.body)
                    ItemList(
                        items: context.allItems(
                            sortedBy: \.groupedSorting,
                            order: .ascending
                        ),
                        site: context.site
                    )
                }
                SiteFooter()
            }
        )
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: section.id)
                Wrapper {
                    H1(section.title)
                    ItemList(items: section.items, site: context.site)
                }
                SiteFooter()
            }
        )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .class("item-page"),
                .components {
                    SiteHeader(context: context, selectedSelectionID: item.sectionID)
                    Wrapper {
                        makeInnerItem(for: item, in: context.site)
                    }
                    SiteFooter()
                }
            )
        )
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper(page.body)
                SiteFooter()
            }
        )
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    H1("Browse all tags and creators")
                    H2("Theme origin:")
                    Paragraph{
                        List(page.tags.filter({theme_modes.contains($0.string)}).sorted()) { TagBadge(tag: $0, site: context.site )}.class("all-tags")
                    }
                    H2("Supported UI themes:")
                    Paragraph{
                        List(page.tags.filter({light_modes.contains($0.string)}).sorted()) { TagBadge(tag: $0, site: context.site )}.class("all-tags")
                    }
                    H2("Creator:")
                    Paragraph{
                        List(page.tags.filter({$0.is_creator}).sorted()) { TagBadge(tag: $0, site: context.site )}.class("all-tags")
                    }
                }
                SiteFooter()
            }
        )
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    H1 {
                        Text("Created by ")
                        TagBadge(tag: page.tag, site: context.site)
                        if page.tag.is_creator && creatorUrl(for: page.tag.string) != nil {
                            Span {
                                Link(url: creatorUrl(for: page.tag.string)!) {
                                   LinkIcon().class("illustration-icon")
                                    Text("Creator")
                                }.class("creator-website")
                            }
                        }
                    }

                    Link("Browse all tags and creators",  url: context.site.tagListPath.absoluteString)
                        .class("browse-all")

                    ItemList(
                        items: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.groupedSorting,
                            order: .ascending
                        ),
                        site: context.site
                    )
                }
                SiteFooter()
            }
        )
    }
}

private struct LinkIcon: Component {
    var body: Component {
        LightDarkPicture(
            lightModePicture: "/website-resources/link-icon-light.svg",
            darkModePicture: "/website-resources/link-icon-dark.svg"
        )
    }
}

private struct LightDarkPicture: Component {
    var lightModePicture: String
    var darkModePicture: String

    var body: Component {
        Node.picture(
            .source(.srcset(darkModePicture), .media("(prefers-color-scheme: dark)")),
            .img(.src(lightModePicture))
        )
    }
}

func creatorUrl(for creator: String) -> String? {
    let url =  try? JSONDecoder().decode([String: String].self, from: getFile(named: "Content/websites.json") ?? "{}".data(using: .utf8)!)[creator]
    if url == "" { return nil }
    return url
}

func getFile(named name: String) -> Data? {
    try? Data(contentsOf: URL(fileURLWithPath: name))
}

private struct Wrapper: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Div(content: content).class("wrapper")
    }
}

private struct SiteHeader<Site: Website>: Component {
    var context: PublishingContext<Site>
    var selectedSelectionID: Site.SectionID?

    var body: Component {
        Header {
            Wrapper {
                Link(context.site.name, url: "/")
                    .class("site-name")

                if Site.SectionID.allCases.count > 1 {
                    navigation
                }
            }
        }
    }

    private var navigation: Component {
        Navigation {
            List(Site.SectionID.allCases) { sectionID in
                let section = context.sections[sectionID]
                return Link(section.title, url: section.path.absoluteString)
                    .class(sectionID == selectedSelectionID ? "selected" : "")
            }
        }
    }
}

private struct ItemList<Site: Website>: Component {
    var items: [Item<Site>]
    var site: Site

    var body: Component {
        List(items) { item in
            makeInnerItem(for: item, in: site)
        }.class("item-list")
    }
}

func makeInnerItem<Site: Website>(for item: Item<Site>, in site: Site) -> Component {
    guard let site = site as? ThemeSite else { return Article { } }
    guard let item = item as? Item<ThemeSite> else { return Article { } }
    return Article {
        Div {
            H1 { Link(item.title, url: "/themes/\(item.title)") }
            Span {
                if let link = item.metadata.link {
                    Link(url: link) { Image(url: "/website-resources/theme-icon.png", description: "Visit Theme") }
                }
                if let creator = creatorUrl(for: item.metadata.creator) {
                    Link(url: creator) { Image(url: "/website-resources/creator-icon.png", description: "Visit Creator") }
                }
                Link(url: item.metadata.ziplink ?? "") { Image(url: "/website-resources/download-icon.png", description: "Download Zip") }
                if !item.isDefaultTheme {
                    Link(url: item.metadata.themelink ?? "") { Image(url: "/website-resources/add-icon.png", description: "Install Theme to NetNewsWire") }
                }
            }.class("theme-link-buttons")
        }.class("article-headline")
        ItemTagList(item: item, site: site)
        Div(content: {
            Div(item.content.body)
            if (item.isMixedTheme) {
                Image(url: "/\(item.title)/\(item.title)-light.png", description: "light").class("screenshot").class("first-screenshot")
                Image(url: "/\(item.title)/\(item.title)-dark.png", description: "dark").class("screenshot").class("second-screenshot")
            } else {
                Image(url: "/\(item.title)/\(item.title).png", description: "screenshot").class("screenshot").class("first-screenshot")
            }
        }).class("content")
    }
}

private struct ItemTagList<Site: Website>: Component {
    var item: Item<Site>
    var site: Site

    var body: Component {
        List(item.tags) {
            TagBadge(tag: $0, site: site)
        }.class("tag-list")
    }
}

private struct TagBadge<Site: Website>: Component {
    var tag: Tag
    var site: Site

    var body: Component {
        guard let site = site as? ThemeSite else { return Span { } }
        return Link(url: site.path(for: tag).absoluteString) {
            if tag.is_creator {
                Image(url: "/website-resources/creator.svg", description: "Creator").class("tag-icon")
            }
            Text(tag.string)
        }
            .class("tag")
            .class("tag-\(tag.string.replacingOccurrences(of: " ", with: "-").lowercased())")
            .class(tag.is_creator ? "tag-creator" : "tag-style")
    }
}

private struct SiteFooter: Component {
    var body: Component {
        Footer {
            Paragraph {
                Span {
                    Text("Generated by abusing ")
                    Link("Publish", url: "https://github.com/johnsundell/publish")
                }
            }
            Paragraph {
                Span {
                    Link("RSS feed", url: "/feed.rss")
                }
                Text(" • ")
                Span {
                    Link("License", url: "/license")
                }
            }
        }
    }
}

extension Item {
    var groupedSorting: String {
        return "\(tags.contains("User Theme") ? 0 : 1) \(title)"
    }
}
