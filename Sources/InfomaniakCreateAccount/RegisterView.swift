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

public struct RegistrationProcess: Sendable {
    let name: String
    let landingHost: String
    let urlString: String

    public init(name: String, landingHost: String = "ksuite.\(ApiEnvironment.current.host)", additionalPath: String) {
        self.name = name
        self.landingHost = landingHost
        urlString = "https://welcome.\(ApiEnvironment.current.host)/signup/\(name)\(additionalPath)"
    }

    public static let drive = RegistrationProcess(name: "ikdrive", additionalPath: "?app=true")
    public static let mail = RegistrationProcess(name: "ikmail", additionalPath: "?app=true")
    public static let euria = RegistrationProcess(name: "euria", additionalPath: "/myksuite")
}

public struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State var isLoading = true

    let registrationProcess: RegistrationProcess
    let onRegistrationCompleted: ((UIViewController?) -> Void)?

    public init(
        registrationProcess: RegistrationProcess,
        onRegistrationCompleted: ((UIViewController?) -> Void)? = nil
    ) {
        self.registrationProcess = registrationProcess
        self.onRegistrationCompleted = onRegistrationCompleted
    }

    public var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                registerWebView
            }
            .interactiveDismissDisabled()
        } else {
            NavigationView {
                registerWebView
            }
            .navigationViewStyle(.stack)
            .interactiveDismissDisabled()
        }
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

            webView.scrollView.contentInset.bottom = -webView.safeAreaInsets.bottom

            if host == registrationProcess.landingHost {
                decision(.cancel)

                var parentViewController: UIViewController? {
                    var parentResponder: UIResponder? = webView.next
                    while parentResponder != nil {
                        if let viewController = parentResponder as? UIViewController {
                            return viewController
                        }
                        parentResponder = parentResponder?.next
                    }
                    return nil
                }
                onRegistrationCompleted?(parentViewController?.navigationController)
            } else if host == "login.\(ApiEnvironment.current.host))" {
                decision(.cancel)
                dismiss()
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
        .background(Color(uiColor: UIColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 1.00)))
    }

    func cleanRegistrationData() {
        let defaultStore = WKWebsiteDataStore.default()
        defaultStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            for record in records {
                defaultStore.removeData(ofTypes: record.dataTypes, for: [record]) {}
            }
        }
    }
}

#Preview("kSuite") {
    RegisterView(registrationProcess: .mail) { _ in }
}

#Preview("Euria") {
    RegisterView(registrationProcess: .euria) { _ in }
}
