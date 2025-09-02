import Foundation
import AppKit

class Photo: Identifiable, ObservableObject, Equatable {
    let id = UUID()
    let url: URL
    var image: NSImage?
    var originalSize: CGSize
    var isPortrait: Bool
    var isSelected: Bool = false
    var needsRotation: Bool = false
    
    // Editing state
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var brightness: Double = 0.0
    @Published var contrast: Double = 1.0
    
    init(url: URL) {
        self.url = url
        self.image = NSImage(contentsOf: url)
        self.originalSize = image?.size ?? CGSize.zero
        self.isPortrait = (image?.size.height ?? 0) > (image?.size.width ?? 0)
        self.needsRotation = self.isPortrait
    }
    
    // Get the processed image (rotated if needed)
    var processedImage: NSImage? {
        guard let image = image else { return nil }
        
        if needsRotation {
            // Rotate portrait photos 90° clockwise
            let rotatedImage = NSImage(size: CGSize(width: image.size.height, height: image.size.width))
            rotatedImage.lockFocus()
            
            let transform = NSAffineTransform()
            transform.translateX(by: image.size.height, yBy: 0)
            transform.rotate(byDegrees: 90)
            transform.concat()
            
            image.draw(in: NSRect(origin: .zero, size: image.size))
            rotatedImage.unlockFocus()
            
            return rotatedImage
        }
        
        return image
    }
    
    // Required for Equatable conformance
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
}
