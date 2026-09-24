import SwiftUI
import WebKit

/// Shows HTML of the bundled content (lessons, About page).
struct HTMLView: UIViewRepresentable {
    let html: String
    var language = "uk"

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        // lessons use fixed dark text colours, so they stay on a light background
        view.overrideUserInterfaceStyle = .light
        view.navigationDelegate = context.coordinator
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {
        guard context.coordinator.loaded != html else { return }
        context.coordinator.loaded = html
        view.loadHTMLString(HTMLView.page(html, language: language), baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        var loaded: String?

        // links (About page) open in Safari, the view itself never navigates away
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    static func page(_ body: String, language: String) -> String {
        """
        <!DOCTYPE html>
        <html lang="\(language)">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>\(css)</style>
        </head>
        <body>\(body)</body>
        </html>
        """
    }

    /// Same rules as the web app: text follows Dynamic Type, tables fit the screen.
    static let css = """
        :root { color-scheme: light; }
        body { font: -apple-system-body; margin: 16px; color: #212121; background: #fff;
               overflow-wrap: break-word; -webkit-text-size-adjust: 100%; }
        table { max-width: 100%; }
        td { overflow-wrap: anywhere; }
        p { margin: .5em 0; }
        .UNIT { display: none; }
        .TITLE { font-size: 1.4em; font-weight: bold; }
        .note { margin: -16px -16px 16px; padding: 16px; background: #E8EAF6; }
        a { color: #3F51B5; }
        """
}

extension String {
    /// Text safe to put into HTML.
    var htmlEscaped: String {
        replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
