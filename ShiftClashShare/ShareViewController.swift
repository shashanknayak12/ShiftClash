//
//  ShareViewController.swift
//  ShiftClashShare
//
//  Created by Shashank Nayak on 5/10/2026.
//

import UIKit
import Social
import UniformTypeIdentifiers

// Accepts a roster text or a Canvas link shared from another app, and
// saves it to the Roster Inbox for the student to deal with later.
class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        true
    }

    override func didSelectPost() {
        loadSharedText { [weak self] text in
            guard let self else { return }

            let finalText = text ?? self.contentText ?? ""
            if !finalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let message = SharedRosterMessage(id: UUID(), text: finalText, receivedAt: Date())
                SharedInboxStore().add(message)
            }

            // Always complete the request so the share sheet dismisses,
            // even if there was nothing usable to save.
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        []
    }

    private func loadSharedText(completion: @escaping (String?) -> Void) {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = item.attachments?.first else {
            completion(nil)
            return
        }

        if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.url.identifier) { data, _ in
                let url = data as? URL
                DispatchQueue.main.async {
                    completion(url?.absoluteString)
                }
            }
        } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
                let text = data as? String
                DispatchQueue.main.async {
                    completion(text)
                }
            }
        } else {
            completion(nil)
        }
    }
}
