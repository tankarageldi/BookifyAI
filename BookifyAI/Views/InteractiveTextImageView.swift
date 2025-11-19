//
//  InteractiveTextImageView.swift
//  BookifyAI
//
//  Created by Tan Karageldi on 2025-11-19.
//

import SwiftUI

struct InteractiveTextImageView: View {
    let image: UIImage
    let textElements: [RecognizedTextElement]
    let onSelectionComplete: ([String]) -> Void  // Callback with selected text
    
    @State private var selectedIndices: Set<Int> = []
    @Environment(\.dismiss) var dismiss
    
    var selectedText: [String] {
        selectedIndices.sorted().map { textElements[$0].text }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Selection controls
                HStack(spacing: 12) {
                    Button(action: {
                        selectedIndices = Set(textElements.indices)
                    }) {
                        Label("Select All", systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        selectedIndices.removeAll()
                    }) {
                        Label("Clear All", systemImage: "xmark.circle.fill")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Text("\(selectedIndices.count) selected")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Image with overlay
                GeometryReader { geometry in
                    ZStack {
                        // Display image
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        
                        // Overlay bounding boxes
                        ForEach(Array(textElements.enumerated()), id: \.element.id) { index, element in
                            let screenRect = convertToScreenCoordinates(
                                normalizedRect: element.boundingBox,
                                imageSize: image.size,
                                viewSize: geometry.size
                            )
                            
                            Rectangle()
                                .fill(selectedIndices.contains(index) ? Color.yellow.opacity(0.4) : Color.clear)
                                .border(selectedIndices.contains(index) ? Color.yellow : Color.blue.opacity(0.3), width: 2)
                                .frame(width: screenRect.width, height: screenRect.height)
                                .position(x: screenRect.midX, y: screenRect.midY)
                                .onTapGesture {
                                    toggleSelection(at: index)
                                }
                        }
                    }
                }
                
                // Selected text preview
                if !selectedIndices.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Text:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ScrollView {
                            Text(selectedText.joined(separator: " "))
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 100)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                }
            }
            .navigationTitle("Select Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Use Selection") {
                        onSelectionComplete(selectedText)
                        dismiss()
                    }
                    .disabled(selectedIndices.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func toggleSelection(at index: Int) {
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)
        }
    }
    
    // This is the CRITICAL coordinate conversion function
    private func convertToScreenCoordinates(
        normalizedRect: CGRect,
        imageSize: CGSize,
        viewSize: CGSize
    ) -> CGRect {
        // 1. Convert normalized (0-1) to image pixel coordinates
        let imageRect = CGRect(
            x: normalizedRect.origin.x * imageSize.width,
            y: normalizedRect.origin.y * imageSize.height,
            width: normalizedRect.width * imageSize.width,
            height: normalizedRect.height * imageSize.height
        )
        
        // 2. Calculate how image is scaled to fit in view
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        
        var displaySize = CGSize.zero
        var offset = CGPoint.zero
        
        if imageAspect > viewAspect {
            // Image is wider - fit to width
            displaySize.width = viewSize.width
            displaySize.height = viewSize.width / imageAspect
            offset.y = (viewSize.height - displaySize.height) / 2
        } else {
            // Image is taller - fit to height
            displaySize.height = viewSize.height
            displaySize.width = viewSize.height * imageAspect
            offset.x = (viewSize.width - displaySize.width) / 2
        }
        
        // 3. Scale image coordinates to display coordinates
        let scale = displaySize.width / imageSize.width
        
        // 4. FLIP Y (Vision uses bottom-origin, SwiftUI uses top-origin)
        let flippedY = imageSize.height - imageRect.origin.y - imageRect.height
        
        // 5. Final screen coordinates
        return CGRect(
            x: imageRect.origin.x * scale + offset.x,
            y: flippedY * scale + offset.y,
            width: imageRect.width * scale,
            height: imageRect.height * scale
        )
    }
}
