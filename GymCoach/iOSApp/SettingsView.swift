import SwiftUI
import GymCoachKit

struct SettingsView: View {
    @AppStorage("unit") private var unitRaw = WeightUnit.lb.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Weight units", selection: $unitRaw) {
                        ForEach(WeightUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.symbol).tag(unit.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                } footer: {
                    Text("Your watch switches to match.")
                }

                Section("About the plan") {
                    Text("A 9-week cricket strength block starting Mon Oct 12, 2026: 3 weeks Foundation, 3 weeks Strength, 1 week Deload, 2 weeks Power. Then it starts again.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Settings")
            .onChange(of: unitRaw) { _, raw in
                if let unit = WeightUnit(rawValue: raw) {
                    Connectivity.shared.sendUnit(unit)
                }
            }
        }
    }
}
