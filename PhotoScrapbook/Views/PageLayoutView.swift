import SwiftUI

struct PageLayoutView: View {
    let page: Page
    let pageNumber: Int
    let selectedPhoto: Photo?
    let onPhotoSelected: (Photo) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Page \(pageNumber)")
                .font(.caption)
                .fontWeight(.medium)
            
            // Page container with fixed dimensions
            VStack(spacing: Constants.photoGap) { // Use the gap constant
                ForEach(Array(page.photos.enumerated()), id: \.element.id) { index, photo in
                    InteractivePhotoView(
                        photo: photo,
                        index: index,
                        isSelected: selectedPhoto?.id == photo.id,
                        onSelected: { onPhotoSelected(photo) }
                    )
                }
            }
            .frame(width: Constants.pageWidth, height: Constants.pageHeight)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            )
        }
    }
}

struct InteractivePhotoView: View {
    let photo: Photo
    let index: Int
    let isSelected: Bool
    let onSelected: () -> Void
    
    // Local state for editing
    @State private var localScale: CGFloat = 1.0
    @State private var localOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Photo container with clipping
            ZStack {
                // Full photo (including overflow areas)
                if let processedImage = photo.processedImage {
                    Image(nsImage: processedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: Constants.photoWidth, height: Constants.photoHeight)
                        .scaleEffect(localScale)
                        .offset(localOffset)
                        .overlay(
                            Rectangle()
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: isSelected ? 3 : 0)
                        )
                }
            }
            .frame(width: Constants.photoWidth, height: Constants.photoHeight)
            .clipped() // This clips the photo to the allocated box
            .onTapGesture {
                onSelected()
            }
            
            // Faded overflow indicator (only show when editing)
            if isSelected && (localScale > 1.0 || abs(localOffset.width) > 0 || abs(localOffset.height) > 0) {
                // Show the full photo area with faded overlay
                if let processedImage = photo.processedImage {
                    Image(nsImage: processedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: Constants.photoWidth, height: Constants.photoHeight)
                        .scaleEffect(localScale)
                        .offset(localOffset)
                        .opacity(0.3) // Faded version
                        .allowsHitTesting(false) // Don't interfere with interactions
                }
            }
            
            // Selection handles (only show when selected)
            if isSelected {
                // Corner resize handles - positioned on the actual photo edges
                ForEach(0..<4) { corner in
                    ResizeHandle(corner: corner, scale: $localScale, photoScale: localScale, photoOffset: localOffset)
                }
                
                // Edge resize handles - positioned on the actual photo edges
                ForEach(0..<4) { edge in
                    EdgeResizeHandle(edge: edge, scale: $localScale, photoScale: localScale, photoOffset: localOffset)
                }
                
                // Move handle (center)
                MoveHandle(offset: $localOffset)
            }
        }
        .onAppear {
            // Initialize local state from photo
            localScale = photo.scale
            localOffset = photo.offset
        }
        .onChange(of: localScale) { newScale in
            // Update photo when local scale changes
            photo.scale = newScale
        }
        .onChange(of: localOffset) { newOffset in
            // Update photo when local offset changes
            photo.offset = newOffset
        }
    }
}

struct ResizeHandle: View {
    let corner: Int
    @Binding var scale: CGFloat
    let photoScale: CGFloat
    let photoOffset: CGSize
    
    @State private var isDragging = false
    @State private var startScale: CGFloat = 1.0
    @State private var startPosition: CGPoint = .zero
    
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .position(cornerPosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            startScale = scale
                            startPosition = value.startLocation
                            return
                        }
                        
                        // Calculate the distance from start position
                        let currentPosition = value.location
                        let startToCurrent = CGPoint(
                            x: currentPosition.x - startPosition.x,
                            y: currentPosition.y - startPosition.y
                        )
                        
                        // Calculate the distance from the photo center
                        let photoCenter = CGPoint(x: Constants.photoWidth / 2, y: Constants.photoHeight / 2)
                        let centerToStart = CGPoint(
                            x: startPosition.x - photoCenter.x,
                            y: startPosition.y - photoCenter.y
                        )
                        let centerToCurrent = CGPoint(
                            x: currentPosition.x - photoCenter.x,
                            y: currentPosition.y - photoCenter.y
                        )
                        
                        // Determine if we're moving inward or outward
                        let startDistance = sqrt(centerToStart.x * centerToStart.x + centerToStart.y * centerToStart.y)
                        let currentDistance = sqrt(centerToCurrent.x * centerToCurrent.x + centerToCurrent.y * centerToCurrent.y)
                        
                        // Calculate scale change based on distance change
                        let distanceChange = currentDistance - startDistance
                        let scaleChange = distanceChange / 100.0 // Adjust sensitivity
                        
                        // Apply scale change
                        let newScale = startScale + scaleChange
                        scale = max(0.5, min(3.0, newScale))
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
    }
    
    private var cornerPosition: CGPoint {
        let width = Constants.photoWidth
        let height = Constants.photoHeight
        
        // Calculate the actual photo boundaries based on scale and offset
        let scaledWidth = width * photoScale
        let scaledHeight = height * photoScale
        
        // Position handles on the outer edge of the scaled photo
        switch corner {
        case 0: return CGPoint(x: photoOffset.width - (scaledWidth - width) / 2, y: photoOffset.height - (scaledHeight - height) / 2) // Top-left
        case 1: return CGPoint(x: photoOffset.width + (scaledWidth + width) / 2, y: photoOffset.height - (scaledHeight - height) / 2) // Top-right
        case 2: return CGPoint(x: photoOffset.width + (scaledWidth + width) / 2, y: photoOffset.height + (scaledHeight + height) / 2) // Bottom-right
        case 3: return CGPoint(x: photoOffset.width - (scaledWidth - width) / 2, y: photoOffset.height + (scaledHeight + height) / 2) // Bottom-left
        default: return CGPoint.zero
        }
    }
}

struct EdgeResizeHandle: View {
    let edge: Int
    @Binding var scale: CGFloat
    let photoScale: CGFloat
    let photoOffset: CGSize
    
    @State private var isDragging = false
    @State private var startScale: CGFloat = 1.0
    @State private var startPosition: CGPoint = .zero
    
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .position(edgePosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            startScale = scale
                            startPosition = value.startLocation
                            return
                        }
                        
                        // Calculate the distance from start position
                        let currentPosition = value.location
                        let startToCurrent = CGPoint(
                            x: currentPosition.x - startPosition.x,
                            y: currentPosition.y - startPosition.y
                        )
                        
                        // Calculate the distance from the photo center
                        let photoCenter = CGPoint(x: Constants.photoWidth / 2, y: Constants.photoHeight / 2)
                        let centerToStart = CGPoint(
                            x: startPosition.x - photoCenter.x,
                            y: startPosition.y - photoCenter.y
                        )
                        let centerToCurrent = CGPoint(
                            x: currentPosition.x - photoCenter.x,
                            y: currentPosition.y - photoCenter.y
                        )
                        
                        // Determine if we're moving inward or outward
                        let startDistance = sqrt(centerToStart.x * centerToStart.x + centerToStart.y * centerToStart.y)
                        let currentDistance = sqrt(centerToCurrent.x * centerToCurrent.x + centerToCurrent.y * centerToCurrent.y)
                        
                        // Calculate scale change based on distance change
                        let distanceChange = currentDistance - startDistance
                        let scaleChange = distanceChange / 100.0 // Adjust sensitivity
                        
                        // Apply scale change
                        let newScale = startScale + scaleChange
                        scale = max(0.5, min(3.0, newScale))
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
    }
    
    private var edgePosition: CGPoint {
        let width = Constants.photoWidth
        let height = Constants.photoHeight
        
        // Calculate the actual photo boundaries based on scale and offset
        let scaledWidth = width * photoScale
        let scaledHeight = height * photoScale
        
        // Position handles on the outer edge of the scaled photo
        switch edge {
        case 0: return CGPoint(x: photoOffset.width + width / 2, y: photoOffset.height - (scaledHeight - height) / 2) // Top-center
        case 1: return CGPoint(x: photoOffset.width + (scaledWidth + width) / 2, y: photoOffset.height + height / 2) // Right-center
        case 2: return CGPoint(x: photoOffset.width + width / 2, y: photoOffset.height + (scaledHeight + height) / 2) // Bottom-center
        case 3: return CGPoint(x: photoOffset.width - (scaledWidth - width) / 2, y: photoOffset.height + height / 2) // Left-center
        default: return CGPoint.zero
        }
    }
}

struct MoveHandle: View {
    @Binding var offset: CGSize
    
    @State private var isDragging = false
    @State private var initialOffset: CGSize = .zero
    
    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 16, height: 16)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .position(x: Constants.photoWidth / 2, y: Constants.photoHeight / 2)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            initialOffset = offset
                            return
                        }
                        
                        let translation = value.translation
                        
                        // Update local offset based on initial position plus translation
                        offset = CGSize(
                            width: initialOffset.width + translation.width,
                            height: initialOffset.height + translation.height
                        )
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
}
