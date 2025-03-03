import SwiftUI

struct IconView: View {
    var body: some View {
        ZStack {
            // Background
            Color.blue
            
            // Icon content
            VStack(spacing: 0) {
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    IconView()
        .frame(width: 512, height: 512)
        .previewLayout(.fixed(width: 512, height: 512))
} 