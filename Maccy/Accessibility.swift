import AppKit

nonisolated struct Accessibility {
  private static var allowed: Bool { AXIsProcessTrustedWithOptions(nil) }

  // Shows the system prompt that leads to Privacy & Security → Accessibility.
  static func check() {
    guard !allowed else {
      return
    }

    AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary)
  }
}
