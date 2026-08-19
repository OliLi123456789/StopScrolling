import SwiftUI

// GardenShopView allows users to spend Star Tokens on Pazu Wearables and Garden Decorations
struct GardenShopView: View {
    @ObservedObject var state: AppState

    let pazuWearables = [
        ("Leaf Crown", 5, "Hat"),
        ("Straw Hat", 10, "Hat"),
        ("Wizard Hat", 15, "Hat"),
        ("Round Glasses", 5, "Glasses"),
        ("Sunglasses", 10, "Glasses"),
        ("Red Scarf", 5, "Scarf")
    ]

    let gardenTrees = [
        ("Cherry Blossom", 0),
        ("Maple Tree", 15),
        ("Pine Tree", 20),
        ("Bamboo Grove", 25)
    ]

    let gardenPonds = [
        ("Small Pond", 0),
        ("Large Pond", 15),
        ("Koi Pond", 25)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FOCUS GARDEN & SHOP")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                        Text("Customize Pazu the Red Panda & your Zen environment")
                            .font(.system(size: 11))
                            .foregroundColor(.slate500)
                    }
                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.rawBrass)
                        Text("\(state.tokens)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.charcoalLight)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 4)

                // Pazu Character Preview
                PazuCharacterView(state: state)

                // Section 1: Pazu Wearable Cosmetics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pazu Pet Wearables")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.slate400)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(pazuWearables, id: \.0) { item, cost, category in
                            let isUnlocked = state.unlockedPazuItems.contains(item)
                            let isEquipped = (category == "Hat" && state.pazuHat == item) ||
                                             (category == "Glasses" && state.pazuGlasses == item) ||
                                             (category == "Scarf" && state.pazuScarf == item)

                            Button(action: {
                                if isUnlocked || state.tokens >= cost {
                                    if !isUnlocked {
                                        state.tokens -= cost
                                        state.unlockedPazuItems.append(item)
                                    }
                                    if category == "Hat" { state.pazuHat = (state.pazuHat == item ? "None" : item) }
                                    if category == "Glasses" { state.pazuGlasses = (state.pazuGlasses == item ? "None" : item) }
                                    if category == "Scarf" { state.pazuScarf = (state.pazuScarf == item ? "None" : item) }
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Text(item)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)

                                    if isEquipped {
                                        Text("Equipped")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.rawBrass)
                                    } else if isUnlocked {
                                        Text("Equip")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.slate500)
                                    } else {
                                        Text("\(cost) ★")
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundColor(state.tokens >= cost ? .white : .slate500)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isEquipped ? Color.rawBrass.opacity(0.15) : Color.charcoalLight)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isEquipped ? Color.rawBrass : Color.slate800, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.charcoalLight.opacity(0.5))
                .cornerRadius(16)

                // Section 2: Garden Trees
                VStack(alignment: .leading, spacing: 12) {
                    Text("Zen Garden Trees")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.slate400)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(gardenTrees, id: \.0) { item, cost in
                            let isUnlocked = state.unlockedGardenDecorations.contains(item)
                            let isEquipped = state.gardenTree == item

                            Button(action: {
                                if isUnlocked || state.tokens >= cost {
                                    if !isUnlocked {
                                        state.tokens -= cost
                                        state.unlockedGardenDecorations.append(item)
                                    }
                                    state.gardenTree = item
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Text(item)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)

                                    if isEquipped {
                                        Text("Active")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.rawBrass)
                                    } else if isUnlocked {
                                        Text("Equip")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.slate500)
                                    } else {
                                        Text("\(cost) ★")
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundColor(state.tokens >= cost ? .white : .slate500)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isEquipped ? Color.rawBrass.opacity(0.15) : Color.charcoalLight)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isEquipped ? Color.rawBrass : Color.slate800, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.charcoalLight.opacity(0.5))
                .cornerRadius(16)
            }
            .padding(16)
        }
        .background(Color.charcoal)
    }
}
