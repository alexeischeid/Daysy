//
//  OpenAIStuff.swift
//  Daysy
//
//  Created by Alexander Eischeid on 4/29/24.
//

import Foundation
import SwiftUI /*
import OpenAIKit


let apiKey = "[redacted for github]"
let openAI = OpenAI (Configuration(organizationId: "Personal", apiKey: apiKey))
var sanitizedPrompt = ""

func generateImage (prompt: String) async -> UIImage{
    //Step 1
    do {
        let imageParams = ImageParameters(prompt: prompt, resolution: .medium, responseFormat: .base64Json)
        //Step 2
        let result = try await openAI.createImage(parameters: imageParams)
        //Step 3
        let b64Image = result.data[0].image
        //Step 4
        return try openAI.decodeBase64Image (b64Image)
    } catch {
        print(error.localizedDescription)
    }
    return UIImage(systemName: "plus.viewfinder")!
}

func askGPT (prompt: String) async -> UIImage {
    do {
        let chat: [ChatMessage] = [
            ChatMessage(role: .user, content: "replace the names of specific people and things in the following prompt with generic items: (if it already complies just say \(prompt)): \(prompt)")
        ]
        
        let chatParameters = ChatParameters(
            model: .gpt4,  // ID of the model to use.
            messages: chat  // A list of messages comprising the conversation so far.
        )
        
        let chatCompletion = try await openAI.generateChatCompletion(
            parameters: chatParameters
        )
        
        if let message = chatCompletion.choices[0].message {
            let content = message.content
            sanitizedPrompt = content ?? ""
        }
        
        Task {
            do {
                let generatedImage = try await generateImage(prompt: "a photorealistic image of \(sanitizedPrompt)")
                return generatedImage
            }
            
        }
    } catch {
        print(error.localizedDescription)
    }
    return UIImage(systemName: "plus.viewfinder")!
}
*/
