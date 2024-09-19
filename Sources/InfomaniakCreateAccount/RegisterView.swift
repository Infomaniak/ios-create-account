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

import InfomaniakCore
import InfomaniakCoreSwiftUI
import SwiftUI
import WebKit

public struct RegistrationProcess {
    let name: String
    let landingHost: String

    public static let drive = RegistrationProcess(name: "ikdrive", landingHost: "drive.\(ApiEnvironment.current.host)")
    public static let mail = RegistrationProcess(name: "ikmail", landingHost: "mail.\(ApiEnvironment.current.host)")
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
            initialURL: URL(string: "https://welcome.\(ApiEnvironment.current.host)/signup/\(registrationProcess.name)?app=true")!
        ) { _ in
            withAnimation {
                isLoading = false
            }
        } shouldNavigateToPage: { webView, navigationAction, decision in
            guard let host = navigationAction.request.url?.host else {
                decision(.allow)
                return
            }

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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
            RegisterView(registrationProcess: .mail) { _ in }
        }
    }
