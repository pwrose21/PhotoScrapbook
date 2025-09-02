import Foundation
import CoreGraphics

struct Page: Identifiable {
    let id = UUID()
    var photos: [Photo] = []
    var pageNumber: Int
    
    init(pageNumber: Int) {
        self.pageNumber = pageNumber
    }
    
    var isFull: Bool {
        photos.count >= 2
    }
    
    mutating func addPhoto(_ photo: Photo) {
        if photos.count < 2 {
            photos.append(photo)
        }
    }
}
