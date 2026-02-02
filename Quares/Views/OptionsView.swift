import SwiftUI

struct OptionsView: View {
    var body: some View {
        ZStack {
            Color(white: 0.1)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Options")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                Text("Coming soon...")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding(.top, 60)
        }
        .navigationTitle("Options")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OptionsView()
    }
}
