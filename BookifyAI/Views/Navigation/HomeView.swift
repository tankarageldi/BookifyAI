//
//  HomeView.swift
//  BookifyAI
//
//  Created by Tan Karageldi on 2025-11-21.
//

import SwiftUI

struct HomeView: View {
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingTextSelection = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App icon/logo area (optional)
            Image(systemName: "book.pages.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Simplify Any Text")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Take a photo of a book page and get simplified explanations")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Main action button
            Button(action: {
                showingImagePicker = true
            }) {
                Label("Take Photo", systemImage: "camera.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
        .onChange(of: selectedImage) { _, newImage in
            if newImage != nil {
                showingTextSelection = true
            }
        }
        .fullScreenCover(isPresented: $showingTextSelection) {
            if let image = selectedImage {
                TextSelectionWorkflowView(image: image)
            }
        }
    }
}

#Preview {
    HomeView()
}
