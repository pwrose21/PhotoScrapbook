import SwiftUI

struct PhotoEditView: View {
    let photo: Photo
    @State private var zoom: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var brightness: Double = 0.0
    @State private var contrast: Double = 1.0
    
    var body: some View {
        VStack(spacing: 16) {
            // Photo display area
            ZStack {
                if let processedImage = photo.processedImage {
                    Image(nsImage: processedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(zoom)
                        .offset(panOffset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    zoom = value
                                }
                                .simultaneously(with: DragGesture()
                                    .onChanged { value in
                                        panOffset = value.translation
                                    })
                        )
                        .clipped()
                        .frame(height: 200)
                        .overlay(
                            Rectangle()
                                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        )
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            // Adjustment controls
            VStack(spacing: 12) {
                HStack {
                    Text("Zoom")
                        .frame(width: 60, alignment: .leading)
                    Slider(value: $zoom, in: 0.5...3.0, step: 0.1)
                    Text("\(zoom, specifier: "%.1f")x")
                        .frame(width: 40, alignment: .trailing)
                }
                
                HStack {
                    Text("Brightness")
                        .frame(width: 60, alignment: .leading)
                    Slider(value: $brightness, in: -1.0...1.0, step: 0.1)
                    Text("\(brightness, specifier: "%.1f")")
                        .frame(width: 40, alignment: .trailing)
                }
                
                HStack {
                    Text("Contrast")
                        .frame(width: 60, alignment: .leading)
                    Slider(value: $contrast, in: 0.5...2.0, step: 0.1)
                    Text("\(contrast, specifier: "%.1f")")
                        .frame(width: 40, alignment: .trailing)
                }
                
                HStack {
                    Button("Reset") {
                        resetAdjustments()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                }
            }
            .padding()
        }
    }
    
    private func resetAdjustments() {
        zoom = 1.0
        panOffset = .zero
        brightness = 0.0
        contrast = 1.0
    }
}
