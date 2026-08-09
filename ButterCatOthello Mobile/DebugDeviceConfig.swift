import Foundation
import Security

enum DebugDeviceConfig {
    private static let keychainService = "com.buttercat.debug-device"
    private static let keychainAccount = "device-uuid"

    /// アンインストール後も Keychain に残る永続 UUID
    static let persistentDeviceID: String = {
        if let existing = readFromKeychain() { return existing }
        let new = UUID().uuidString
        writeToKeychain(new)
        return new
    }()

    private static let registeredIDs: [String] = {
        guard let url = Bundle.main.url(forResource: "debug-config", withExtension: "js"),
              let content = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        let pattern = #"VENDOR_IDS\s*:\s*\[([^\]]*)\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
              let range = Range(match.range(at: 1), in: content) else { return [] }
        return content[range]
            .components(separatedBy: ",")
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
                  .trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
            }
            .filter { !$0.isEmpty }
    }()

    static var isDebugDevice: Bool {
        registeredIDs.contains(persistentDeviceID)
    }

    private static func readFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
        return value
    }

    private static func writeToKeychain(_ value: String) {
        guard let data = value.data(using: .utf8) else { return }
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(attributes as CFDictionary, nil)
    }
}
