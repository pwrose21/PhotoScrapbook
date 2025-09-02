import Foundation
import CoreGraphics

class LayoutService: ObservableObject {
    @Published var pages: [Page] = []
    
    func createLayout(from photos: [Photo]) -> [Page] {
        var newPages: [Page] = []
        var currentPage = Page(pageNumber: 1)
        
        for photo in photos {
            if currentPage.isFull {
                newPages.append(currentPage)
                currentPage = Page(pageNumber: newPages.count + 1)
            }
            currentPage.addPhoto(photo)
        }
        
        // Add the last page if it has photos
        if !currentPage.photos.isEmpty {
            newPages.append(currentPage)
        }
        
        DispatchQueue.main.async {
            self.pages = newPages
        }
        
        return newPages
    }
}
