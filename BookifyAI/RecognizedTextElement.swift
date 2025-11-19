//
//  RecognizedTextElement.swift
//  BookifyAI
//
//  Created by Tan Karageldi on 2025-11-19.
//

import Foundation
import CoreGraphics

struct RecognizedTextElement {
    let text: String
    let boundingBox: CGRect
    let id: UUID = UUID()
}


