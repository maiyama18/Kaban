import SwiftUI
import Testing
import Kaban

@Test
func swiftUIColorCreatesKabanColor() {
    let color = KabanColor(.red)

    requireSendable(color)
}

private func requireSendable<T: Sendable>(_: T) {}
