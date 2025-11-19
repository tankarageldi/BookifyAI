import SwiftUI
import PhotosUI

struct CameraView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var textElements: [RecognizedTextElement] = []
    @State private var isProcessing = false
    @State private var showingInteractiveView = false
    @State private var selectedTextForAPI: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Photo Picker Button
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Select Photo", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Show selected image
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Loading indicator
                if isProcessing {
                    ProgressView("Extracting text...")
                }
                
                // Button to open interactive selection
                if !textElements.isEmpty && !isProcessing {
                    Button(action: {
                        showingInteractiveView = true
                    }) {
                        Label("Select Text to Simplify", systemImage: "hand.tap.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // Show selected text (after user confirms selection)
                if !selectedTextForAPI.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Text to Simplify:")
                            .font(.headline)
                        
                        ScrollView {
                            Text(selectedTextForAPI.joined(separator: " "))
                                .padding()
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 150)
                        
                        // TODO: Add button here to send to Claude API
                        Button(action: {
                            // Will implement Claude API call next
                            print("Sending to Claude:", selectedTextForAPI.joined(separator: " "))
                        }) {
                            Label("Simplify with Claude", systemImage: "wand.and.stars")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Book Simplify")
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    await loadAndProcessImage(newItem)
                }
            }
            .sheet(isPresented: $showingInteractiveView) {
                if let image = selectedImage {
                    InteractiveTextImageView(
                        image: image,
                        textElements: textElements,
                        onSelectionComplete: { selectedText in
                            selectedTextForAPI = selectedText
                        }
                    )
                }
            }
        }
    }
    
    private func loadAndProcessImage(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isProcessing = true
        textElements = []
        selectedTextForAPI = []
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
                
                // Perform OCR with bounding boxes
                textElements = try await OCRService.shared.recognizeTextWithBoundingBoxes(from: uiImage)
                
                print("Found \(textElements.count) text elements")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        isProcessing = false
    }
}

#Preview {
    CameraView()
}
