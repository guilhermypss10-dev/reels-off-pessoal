import SwiftUI
import WebKit

/// Modo alternativo: usa a versao web do Instagram, nunca modifica o app nativo.
/// O filtro funciona apenas nesta WKWebView e pode exigir atualizacoes quando
/// o Instagram alterar suas rotas ou estrutura HTML.
struct InstagramSemReelsView: View {
    @State private var reloadID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Label("Instagram sem Reels", systemImage: "hand.raised.fill")
                    .font(.headline)
                Spacer()
                Button {
                    reloadID = UUID()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Recarregar Instagram")
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            Text("Modo web experimental. O Instagram original nao e alterado.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)
            FilteredInstagramWebView()
                .id(reloadID)
        }
    }
}

private struct FilteredInstagramWebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let script = WKUserScript(
            source: Self.filterScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = nil
        if let homeURL = URL(string: "https://www.instagram.com/") {
            webView.load(URLRequest(url: homeURL))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        private static func isReelsURL(_ url: URL) -> Bool {
            guard let host = url.host?.lowercased(),
                  host == "instagram.com" || host.hasSuffix(".instagram.com") else { return false }
            let path = url.path.lowercased()
            return path == "/reels" || path.hasPrefix("/reels/")
                || path == "/reel" || path.hasPrefix("/reel/")
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            if Self.isReelsURL(url) {
                decisionHandler(.cancel)
                if !webView.isLoading {
                    webView.evaluateJavaScript("history.replaceState(null, '', '/');", completionHandler: nil)
                }
                return
            }
            // Impede que links para dominios estranhos sejam carregados
            // dentro da sessao autenticada do Instagram.
            if let host = url.host?.lowercased(),
               host != "instagram.com" && !host.hasSuffix(".instagram.com")
                && host != "facebook.com" && !host.hasSuffix(".facebook.com")
                && host != "accountscenter.instagram.com" {
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }

    private static let filterScript = #"""
    (() => {
      if (window.__reelsOffInstalled) return;
      window.__reelsOffInstalled = true;
      const reelPath = path => /^\/reels?(?:\/|$)/i.test(path || '');
      const isReelLink = link => {
        try { return reelPath(new URL(link.href, location.href).pathname); }
        catch { return false; }
      };
      let lastKnownGood = '/';
      const clean = () => {
        try {
          if (!reelPath(location.pathname)) {
            lastKnownGood = location.pathname + location.search;
          } else {
            location.replace(lastKnownGood === location.pathname ? '/' : lastKnownGood);
            return;
          }
          document.querySelectorAll('a[href]').forEach(a => {
            if (isReelLink(a)) {
              a.style.setProperty('display', 'none', 'important');
              a.setAttribute('aria-hidden', 'true');
            }
          });
        } catch (_) {}
      };
      document.addEventListener('click', event => {
        const link = event.target.closest?.('a[href]');
        if (link && isReelLink(link)) {
          event.preventDefault();
          event.stopImmediatePropagation();
        }
      }, true);
      const beginObserving = () => {
        if (!document.documentElement) return;
        const observer = new MutationObserver(clean);
        observer.observe(document.documentElement, {childList: true, subtree: true});
        clean();
      };
      if (document.documentElement) beginObserving();
      else document.addEventListener('DOMContentLoaded', beginObserving, { once: true });
      addEventListener('popstate', clean);
      const originalPush = history.pushState;
      const originalReplace = history.replaceState;
      history.pushState = function (...args) {
        const result = originalPush.apply(this, args);
        clean();
        return result;
      };
      history.replaceState = function (...args) {
        const result = originalReplace.apply(this, args);
        clean();
        return result;
      };
      if (document.documentElement) clean();
    })();
    """#
}
