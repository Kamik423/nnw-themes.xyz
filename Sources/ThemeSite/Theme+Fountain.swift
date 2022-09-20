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
                        site: context.site,
                        context: context
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
                    ItemList(items: section.items, site: context.site, context: context)
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
                        makeInnerItem(for: item, in: context.site, with: context)
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
                    H1("Browse All Tags and Creators")
                    H2("Theme Origins:")
                    Paragraph{
                        List(page.tags.filter({theme_modes.contains($0.string)}).sorted()) { TagBadge(tag: $0, site: context.site, context: context) }.class("tag-list")
                    }
                    H2("Supported UI Themes:")
                    Paragraph{
                        List(page.tags.filter({light_modes.contains($0.string)}).sorted()) { TagBadge(tag: $0, site: context.site, context: context) }.class("tag-list")
                    }
                    H2("Fonts:")
                    Paragraph{
                        List(page.tags.filter({font_modes.contains($0.string)}).sorted()) { TagBadge(tag: $0, site: context.site, context: context) }.class("tag-list")
                    }
                    H2("Creators:")
                    Paragraph{
                        List(page.tags.filter({$0.isCreator}).sorted()) { TagBadge(tag: $0, site: context.site, context: context )}.class("tag-list")
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
                        Text(page.tag.isCreator ? "Created By " : "Tagged ")
                        TagBadge(tag: page.tag, site: context.site, context: context)
                    }
                    if page.tag.isCreator && creatorUrl(for: page.tag.string) != nil {
                        Span {
                            Link(url: creatorUrl(for: page.tag.string)!) {
                               LinkIcon().class("illustration-icon")
                                Text("Creator Website")
                            }.class("creator-website")
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
                        site: context.site,
                        context: context
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
                Link(url: "/") {
                    H3("Unofficial Official")
                    H1("NetNewsWire")
                    H2("Themes Directory")
                }.class("title")

                // if Site.SectionID.allCases.count > 1 {
                //     navigation
                // }
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
    var context: PublishingContext<Site>

    var body: Component {
        List(items) { item in
            makeInnerItem(for: item, in: site, with: context)
        }.class("item-list")
    }
}

func makeInnerItem<Site: Website>(for item: Item<Site>, in site: Site, with context: PublishingContext<Site>) -> Component {
    guard let site = site as? ThemeSite else { return Article { } }
    guard let context = context as? PublishingContext<ThemeSite> else { return Article { } }
    guard let item = item as? Item<ThemeSite> else { return Article { } }
    return Article {
        Div {
            H1 { Link(item.title, url: "/themes/\(item.title)") }
            Span {
                Link(url: item.metadata.ziplink ?? "") { Image(url: "/website-resources/download-icon.png", description: "Download Zip") }
                if !item.isDefaultTheme {
                    Link(url: item.metadata.themelink ?? "") { Image(url: "/website-resources/add-icon.png", description: "Install Theme to NetNewsWire") }
                }
            }.class("theme-link-buttons")
        }.class("article-headline")
        Div {
            ItemTagList(item: item, site: site, context: context)
            Span {
                if let link = item.metadata.link {
                    Link(url: link) {
                        LinkIcon().class("illustration-icon")
                        Text("Theme")
                    }.class("info-link")
                }
                if let creator = creatorUrl(for: item.metadata.creator) {
                    Link(url: creator) {
                        LinkIcon().class("illustration-icon")
                        Text("Creator")
                    }.class("info-link")
                }
            }.class("info-links")
        }.class("secondary-bar")
        Div(content: {
            Div(item.content.body)
            if (item.isMixedTheme) {
                Image(url: "/themes/\(item.title)/\(item.title)-light.png", description: "light").class("screenshot").class("first-screenshot")
                Image(url: "/themes/\(item.title)/\(item.title)-dark.png", description: "dark").class("screenshot").class("second-screenshot")
            } else {
                Image(url: "/themes/\(item.title)/\(item.title).png", description: "screenshot").class("screenshot").class("first-screenshot")
            }
        }).class("content")
    }
}

private struct ItemTagList<Site: Website>: Component {
    var item: Item<Site>
    var site: Site
    var context: PublishingContext<Site>

    var body: Component {
        List(item.tags) {
            TagBadge(tag: $0, site: site, context: context)
        }.class("tag-list")
    }
}

private struct TagBadge<Site: Website>: Component {
    var tag: Tag
    var site: Site
    var context: PublishingContext<Site>

    var body: Component {
        guard let site = site as? ThemeSite else { return Span { } }
        return Link(url: site.path(for: tag).absoluteString) {
            if tag.isCreator {
                Image(url: "/website-resources/creator.svg", description: "Creator").class("tag-icon")
            }
            Text(tag.string)
            Span {
                Text("\(context.occurances(ofTag: tag))")
            }.class("tag-count")
        }
            .class("tag")
            .class("tag-\(tag.string.replacingOccurrences(of: " ", with: "-").lowercased())")
            .class(tag.isCreator ? "tag-creator" : "tag-style")
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
                Text(" • ")
                Span {
                    Link("About", url: "/about")
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

extension PublishingContext {
    func occurances(ofTag tag: Tag) -> Int {
        return self.sections.map({ $0.items(taggedWith: tag).count }).reduce(0, +)
    }
}
