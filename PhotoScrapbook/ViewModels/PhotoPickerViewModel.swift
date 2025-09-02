import Foundation
import AppKit
import SwiftUI

class PhotoPickerViewModel: ObservableObject {
    @Published var selectedPhotos: [Photo] = []
    @Published var isShowingPhotoPicker = false
    
    func selectPhotos() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        
        panel.begin { [weak self] response in
            if response == .OK {
                let urls = panel.urls
                let newPhotos = urls.map { Photo(url: $0) }
                DispatchQueue.main.async {
                    self?.selectedPhotos.append(contentsOf: newPhotos)
                }
            }
        }
    }
    
    func removePhoto(_ photo: Photo) {
        selectedPhotos.removeAll { $0.id == photo.id }
    }
    
    func clearAllPhotos() {
        selectedPhotos.removeAll()
    }
}
