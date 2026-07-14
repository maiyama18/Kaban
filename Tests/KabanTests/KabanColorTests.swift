import SwiftUI
import Testing
import Kaban

@Test
func swiftUIColorCreatesKabanColor() {
    let color = KabanColor(.red)

    requireSendable(color)
}

@Test
func swiftUIColorCanBeReadFromKabanColor() {
    let kabanColor = KabanColor(.red)
    let color: Color = kabanColor.color

    requireSendable(color)
}

private func requireSendable<T: Sendable>(_: T) {}
