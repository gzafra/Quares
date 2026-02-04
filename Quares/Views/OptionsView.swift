import SwiftUI

struct OptionsView: View {
    @AppStorage("colorMode") private var colorMode: String = ColorMode.normal.rawValue
    @Environment(\.dismiss) private var dismiss

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

                colorModeSection

                Spacer()
            }
        }
        .navigationTitle("Options")
        .navigationBarTitleDisplayMode(.inline
        )
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
