import Foundation
import SwiftUI

// PazuBehavior decision engine
class PazuBehavior {
    static func decideNextAction(streak: Int, hasCheckedInToday: Bool) -> PazuState {
        if streak == 0 {
            return .sleeping
        } else if streak >= 7 {
            return .proud
        } else {
            let roll = Double.random(in: 0...1)
            if roll < 0.05 { // Lower chance of clumsy (5% instead of 30%)
                return .clumsy
            } else if roll < 0.25 {
                return .playing
            } else if roll < 0.45 {
                return .curious
            } else if roll < 0.60 {
                return .eating
            } else if roll < 0.75 {
                return .meditating
            } else {
                return .idle
            }
        }
    }
}
