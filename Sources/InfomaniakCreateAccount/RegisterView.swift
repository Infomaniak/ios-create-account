/*
 Infomaniak Create Account
 Copyright (C) 2023 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@preconcurrency import InfomaniakCore
import InfomaniakCoreSwiftUI
import SwiftUI
import WebKit

#if canImport(UIKit)
import UIKit

public typealias RegistrationPresenterController = UIViewController
#elseif canImport(AppKit)
import AppKit

public typealias RegistrationPresenterController = NSViewController
#endif

public struct RegistrationProcess: Equatable, Hashable, Sendable {
    let name: String
    let landingHost: String
    let urlString: String

    public init(name: String, landingHost: String = "ksuite.\(ApiEnvironment.current.host)", additionalPath: String? = nil) {
        self.name = name
        self.landingHost = landingHost
        urlString = "https://welcome.\(ApiEnvironment.current.host)/signup/\(name)\(additionalPath ?? "")"
    }

    public static let drive = RegistrationProcess(name: "ikdrive", additionalPath: "?app=true")
    public static let mail = RegistrationProcess(name: "ikmail", additionalPath: "?app=true")
    public static let euria = RegistrationProcess(name: "euria")
    public static let swissTransfer = RegistrationProcess(name: "swisstransfer")
}

public struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State var isLoading = true

    let registrationProcess: RegistrationProcess
    let onRegistrationCompleted: ((RegistrationPresenterController?) -> Void)?

    public init(
        registrationProcess: RegistrationProcess,
        onRegistrationCompleted: ((RegistrationPresenterController?) -> Void)? = nil
    ) {
        self.registrationProcess = registrationProcess
        self.onRegistrationCompleted = onRegistrationCompleted
    }

    public var body: some View {
        NavigationStack {
            registerWebView
        }
        .interactiveDismissDisabled()
    }

    var registerWebView: some View {
        WebView(
            initialURL: URL(string: registrationProcess.urlString)!
        ) { _ in
            withAnimation {
                isLoading = false
            }
        } shouldNavigateToPage: { webView, navigationAction, decision in
            guard let host = navigationAction.request.url?.host else {
                decision(.allow)
                return
            }

            #if canImport(UIKit)
            webView.scrollView.contentInset.bottom = -webView.safeAreaInsets.bottom
            #endif

            if host == registrationProcess.landingHost {
                decision(.cancel)

                let controller = findParentViewController(from: webView)
                onRegistrationCompleted?(controller)
            } else if host == "login.\(ApiEnvironment.current.host))" {
                decision(.cancel)
                dismiss()
            } else if navigationAction.navigationType == .linkActivated,
                      navigationAction.targetFrame == nil,
                      let url = navigationAction.request.url {
                openURL(url)
                decision(.cancel)
            } else {
                decision(.allow)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    cleanRegistrationData()
                    dismiss()
                } label: {
                    Label("Cancel", systemImage: "xmark")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
        }
        #if canImport(UIKit)
        .background(Color(uiColor: UIColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 1.00)))
        #elseif canImport(AppKit)
        .background(Color(nsColor: NSColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 1.00)))
        #endif
    }

    func cleanRegistrationData() {
        let defaultStore = WKWebsiteDataStore.default()
        defaultStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            for record in records {
                defaultStore.removeData(ofTypes: record.dataTypes, for: [record]) {}
            }
        }
    }

    #if canImport(UIKit)
    func findParentViewController(from view: UIView) -> RegistrationPresenterController? {
        var parentResponder: UIResponder? = view
        while parentResponder != nil {
            if let viewController = parentResponder as? RegistrationPresenterController {
                return viewController.navigationController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }

    #elseif canImport(AppKit)
    func findParentViewController(from view: NSView) -> RegistrationPresenterController? {
        var parentResponder: NSResponder? = view
        while parentResponder != nil {
            if let viewController = parentResponder as? RegistrationPresenterController {
                return viewController.parent
            }
            parentResponder = parentResponder?.nextResponder
        }
        return nil
    }#endif
}

#Preview("kSuite") {
    RegisterView(registrationProcess: .mail) { _ in }
}

#Preview("Euria") {
    RegisterView(registrationProcess: .euria) { _ in }
}
