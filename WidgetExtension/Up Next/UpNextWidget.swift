import SwiftUI
import WidgetKit

struct UpNextWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Up_Next_Widget", provider: UpNextProvider()) { entry in
            UpNextWidgetEntryView(entry: entry)
                .clearBackground()
                .environment(\.widgetColorScheme, widgetColorSchemeContrast)
        }
        .contentMarginsDisabledIfAvailable()
        .configurationDisplayName(L10n.upNext)
        .description("See what’s playing now, and what’s coming Up Next.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
