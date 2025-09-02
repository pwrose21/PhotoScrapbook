//
//  ContentView.swift
//  PhotoScrapbook
//
//  Created by Peyton Rose on 9/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var photoPickerVM = PhotoPickerViewModel()
    @StateObject private var layoutService = LayoutService()
    @State private var selectedPhoto: Photo?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Text("Photo Scrapbook")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Automate your weekly photo layout")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                HStack(alignment: .top, spacing: 20) {
                    // Left Panel - Photo Selection
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Selected Photos")
                                .font(.headline)
                            Spacer()
                            Button("Select Photos") {
                                photoPickerVM.selectPhotos()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        if photoPickerVM.selectedPhotos.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("No photos selected yet")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("Click 'Select Photos' to get started")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(10)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                                    ForEach(photoPickerVM.selectedPhotos) { photo in
                                        PhotoThumbnailView(photo: photo) {
                                            photoPickerVM.removePhoto(photo)
                                            if selectedPhoto?.id == photo.id {
                                                selectedPhoto = nil
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                            .frame(maxHeight: 200)
                            
                            HStack {
                                Text("\(photoPickerVM.selectedPhotos.count) photos selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("Clear All") {
                                    photoPickerVM.clearAllPhotos()
                                    selectedPhoto = nil
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .frame(width: 350)
                    .padding()
                    
                    // Center Panel - Page Layout Preview (now with interactive editing)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Page Layout Preview")
                                .font(.headline)
                            
                            if selectedPhoto != nil {
                                Spacer()
                                Text("Click on photos to edit • Drag corners to resize • Drag center to move")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if photoPickerVM.selectedPhotos.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "doc.text.image")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("No photos to layout")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(10)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 20) {
                                    ForEach(layoutService.pages) { page in
                                        PageLayoutView(
                                            page: page,
                                            pageNumber: page.pageNumber,
                                            selectedPhoto: selectedPhoto,
                                            onPhotoSelected: { photo in
                                                selectedPhoto = photo
                                            }
                                        )
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Spacer()
            }
            .frame(minWidth: 1200, minHeight: 800)
        }
        .onChange(of: photoPickerVM.selectedPhotos) { _ in
            layoutService.createLayout(from: photoPickerVM.selectedPhotos)
        }
    }
}

struct PhotoThumbnailView: View {
    let photo: Photo
    let onRemove: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = photo.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(6)
            } else {
                Rectangle()
                    .fill(Color(NSColor.controlBackgroundColor))
                    .frame(width: 80, height: 80)
                    .cornerRadius(6)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    )
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(2)
        }
    }
}

#Preview {
    ContentView()
}
