import SwiftUI

// GardenShopView allows spending tokens on Pazu Wearables and Garden Decorations with zero emojis
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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FOCUS GARDEN SHOP")
                            .font(.custom("Inter", size: 14).weight(.black))
                            .foregroundColor(.inkBlack)
                        Text("Customize Pazu the Red Panda & Zen Environment")
                            .font(.custom("Inter", size: 11))
                            .foregroundColor(.inkMuted)
                    }
                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.terracotta)
                        Text("\(state.tokens)")
                            .font(.custom("JetBrainsMono", size: 13).weight(.bold))
                            .foregroundColor(.inkBlack)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.pureWhite)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 4)

                // Pazu Preview
                PazuCharacterView(state: state)

                // Section 1: Wearables
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pazu Pet Wearables")
                        .font(.custom("Inter", size: 12).weight(.bold))
                        .foregroundColor(.inkMuted)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(pazuWearables, id: \.0) { item, cost, category in
                            let isUnlocked = state.unlockedPazuItems.contains(item)
                            let isEquipped = (category == "Hat" && state.pazuHat == item) ||
                                             (category == "Glasses" && state.pazuGlasses == item) ||
                                             (category == "Scarf" && state.pazuScarf == item)

                            Button(action: {
                                if isUnlocked || state.tokens >= cost {
                                    if !isUnlocked {
                                        state.tokens -= cost;
                                        state.unlockedPazuItems.append(item)
                                    }
                                    if category == "Hat" { state.pazuHat = (state.pazuHat == item ? "None" : item) }
                                    if category == "Glasses" { state.pazuGlasses = (state.pazuGlasses == item ? "None" : item) }
                                    if category == "Scarf" { state.pazuScarf = (state.pazuScarf == item ? "None" : item) }
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Text(item)
                                        .font(.custom("Inter", size: 12).weight(.bold))
                                        .foregroundColor(.inkBlack)

                                    if isEquipped {
                                        Text("Equipped")
                                            .font(.custom("Inter", size: 9).weight(.bold))
                                            .foregroundColor(.terracotta)
                                    } else if isUnlocked {
                                        Text("Equip")
                                            .font(.custom("Inter", size: 9).weight(.bold))
                                            .foregroundColor(.inkMuted)
                                    } else {
                                        Text("\(cost) ★")
                                            .font(.custom("JetBrainsMono", size: 10).weight(.bold))
                                            .foregroundColor(state.tokens >= cost ? .inkBlack : .inkMuted)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isEquipped ? Color.terracotta.opacity(0.12) : Color.pureWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isEquipped ? Color.terracotta : Color.paperBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.pureWhite)
                .cornerRadius(16)
                .shadow(color: Color.paperShadow.opacity(0.5), radius: 6, x: 0, y: 3)
            }
            .padding(16)
        }
        .background(Color.washiPaper)
    }
}
