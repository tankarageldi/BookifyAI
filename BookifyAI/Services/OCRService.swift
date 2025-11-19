import Vision
import UIKit


class OCRService {
    
    // Create a singleton instance
    
    static let shared = OCRService()
    private init(){}
    
    func recognizeTextWithBoundingBoxes(from Image: UIImage) async throws -> [RecognizedTextElement] {
        guard let cGImage = Image.cgImage else {
            throw OCRError.invalidImage
        }
        
        let handler = VNImageRequestHandler(cgImage: cGImage, orientation: .up ,options:[:])
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
    
        try handler.perform([request])
        
        guard let observations = request.results else {
            throw OCRError.noTextFound
        }
        var elements: [RecognizedTextElement] = []
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let boundingBox = observation.boundingBox
            let element = RecognizedTextElement (
                text: topCandidate.string,
                boundingBox: boundingBox
            )
            
            elements.append(element)
        }
        
        
        return elements
    }
        
    
    func recognizeText(from image: UIImage) async throws -> String {
        
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up ,options:[:])
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
    
        
        try handler.perform([request])
        
        guard let observations = request.results else {
            throw OCRError.noTextFound
        }
        
        let recognizedText = observations.compactMap{observation in observation.topCandidates(1).first?.string}.joined(separator: "\n")
        return recognizedText
        
        
    }
}

 enum OCRError: Error {
     case invalidImage
     case noTextFound
     case processingFailed
 }
