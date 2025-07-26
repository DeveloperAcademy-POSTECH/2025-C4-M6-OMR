//
//  File.swift
//  Features
//
//  Created by Henry on 7/25/25.
//

import UIKit

public actor FileStoreManager {
    public static let shared = FileStoreManager()
    private let fileManager = FileManager.default
    
    
    private var imagesDirectory: URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not find documents directory.")
            return nil
        }
        
        
        let imagesPath = documentsDirectory.appendingPathComponent("StoredImages")
        
        if !fileManager.fileExists(atPath: imagesPath.path) {
            do {
                try fileManager.createDirectory(at: imagesPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error: Could not create images directory - \(error.localizedDescription)")
                return nil
            }
        }
        
        return imagesPath
    }
    
    func saveImage(_ image: UIImage) -> String? {
        guard let directory = imagesDirectory else { return nil }
        
        let fileName = "\(UUID().uuidString).jpeg"
        let fileURL = directory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Error: 이미지 데이터를 변환할 수 없습니다.")
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            print("✅ 이미지 저장 성공: \(fileName)")
            return fileName
        } catch {
            print("Error: 이미지 파일 쓰기 실패 - \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadImage(fileName: String) -> UIImage? {
        guard let directory = imagesDirectory else { return nil }
        let fileURL = directory.appendingPathComponent(fileName)
        
        return UIImage(contentsOfFile: fileURL.path)
    }
}

