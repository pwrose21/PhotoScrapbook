import Foundation

struct ScrapbookProject: Identifiable {
    let id = UUID()
    var name: String
    var photos: [Photo] = []
    var pages: [Page] = []
    var createdAt: Date = Date()
    
    init(name: String) {
        self.name = name
    }
    
    mutating func addPhoto(_ photo: Photo) {
        photos.append(photo)
        autoAssignToPages()
    }
    
    private mutating func autoAssignToPages() {
        pages.removeAll()
        
        var currentPage = Page(pageNumber: 1)
        
        for photo in photos {
            if currentPage.isFull {
                pages.append(currentPage)
                currentPage = Page(pageNumber: pages.count + 1)
            }
            currentPage.addPhoto(photo)
        }
        
        if !currentPage.photos.isEmpty {
            pages.append(currentPage)
        }
    }
}
