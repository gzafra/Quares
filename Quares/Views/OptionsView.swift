import SwiftUI

struct OptionsView: View {
    @AppStorage("colorMode") private var colorMode: String = ColorMode.normal.rawValue
    @Environment(\.dismiss) private var dismiss
    @StateObject private var soundManager = SoundManager.shared

    private var selectedColorMode: ColorMode {
        ColorMode(rawValue: colorMode) ?? .normal
    }

    var body: some View {
        ZStack {
            Color(white: 0.1)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)

                Text("Options")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                ScrollView {
                    VStack(spacing: 24) {
                        soundSection
                        colorModeSection
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
        .navigationTitle("Options")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audio")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Toggle("Music", isOn: $soundManager.isMusicEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .foregroundColor(.white)

            Toggle("Sound Effects", isOn: $soundManager.isSoundEffectsEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .foregroundColor(.white)

            Toggle("Allow Own Music", isOn: $soundManager.allowOwnMusic)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .foregroundColor(.white)

            Text("When enabled, your music will play instead of game music")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(12)
    }

    private var colorModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color Mode")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Picker("Color Mode", selection: $colorMode) {
                ForEach(ColorMode.allCases) { mode in
                    Text(mode.displayName).tag(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)

            colorPreview
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(12)
    }

    private var colorPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            HStack(spacing: 8) {
                ForEach(Array(selectedColorMode.colors.enumerated()), id: \.offset) { _, color in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(height: 40)
                }
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        OptionsView()
    }
}
