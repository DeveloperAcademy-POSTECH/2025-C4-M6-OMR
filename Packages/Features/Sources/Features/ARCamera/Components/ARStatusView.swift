//
//  ARStatusView.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//
import SwiftUI

struct ARStatusView: View {
    let message: String
    
    var body: some View {
        formatMessage(message)
            .padding(12)
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 20)
            .animation(.easeInOut, value: message)
            .multilineTextAlignment(.center)
    }
    
    private func formatMessage(_ message: String) -> some View {
        // 메시지를 분석하여 꽃 이름 부분을 찾아 볼드 처리
        if let flowerName = extractFlowerName(from: message) {
            return createFormattedText(message: message, flowerName: flowerName)
        } else {
            // 꽃 이름이 없는 경우 일반 텍스트
            return AnyView(Text(message))
        }
    }
    
    private func extractFlowerName(from message: String) -> String? {
        // 동적으로 변하는 꽃 이름을 추출하는 패턴들
        let patterns = [
            // "장미 모델을 로드하는 중..." 패턴
            "([가-힣a-zA-Z0-9\\s]+)\\s+모델을\\s+로드하는\\s+중",
            // "🔴 빨간 인디케이터 위치에 장미이(가) 배치됩니다." 패턴
            "위치에\\s+([가-힣a-zA-Z0-9\\s]+)이\\(가\\)\\s+배치됩니다",
            // "장미이(가) 배치됩니다" 더 간단한 패턴
            "([가-힣a-zA-Z0-9\\s]+)이\\(가\\)\\s+배치됩니다",
            "여기에\\s+([가-힣a-zA-Z0-9\\s]+)를\\s+심을까요?"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
               let range = Range(match.range(at: 1), in: message) {
                let extractedName = String(message[range]).trimmingCharacters(in: .whitespaces)
                // 빈 문자열이 아닌 경우에만 반환
                return extractedName.isEmpty ? nil : extractedName
            }
        }
        
        return nil
    }
    
    private func createFormattedText(message: String, flowerName: String) -> AnyView {
        // 메시지를 꽃 이름 기준으로 분할
        let parts = message.components(separatedBy: flowerName)
        
        if parts.count >= 2 {
            return AnyView(
                // Text를 + 연산자로 연결하여 한 줄로 표시
                Text(parts[0]) +
                Text(flowerName)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow) +
                Text(parts.dropFirst().joined(separator: flowerName))
            )
        } else {
            // 분할에 실패한 경우 원본 메시지 반환
            return AnyView(Text(message))
        }
    }
}

// MARK: - 더 정교한 버전 (AttributedString 사용)
@available(iOS 15.0, *)
struct EnhancedARStatusView: View {
    let message: String
    
    var body: some View {
        Text(formatMessageWithAttributedString(message))
            .padding(12)
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 20)
            .animation(.easeInOut, value: message)
    }
    
    private func formatMessageWithAttributedString(_ message: String) -> AttributedString {
        var attributedString = AttributedString(message)
        
        // 꽃 이름 패턴들 (동적 flower.name 대응)
        let patterns = [
            "([가-힣a-zA-Z0-9\\s]+)\\s+모델을\\s+로드하는\\s+중",
            "위치에\\s+([가-힣a-zA-Z0-9\\s]+)이\\(가\\)\\s+배치됩니다",
            "([가-힣a-zA-Z0-9\\s]+)이\\(가\\)\\s+배치됩니다",
            "여기에\\s+([가-힣a-zA-Z0-9\\s]+)를\\s+심을까요?"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
               let range = Range(match.range(at: 1), in: message) {
                
                let flowerName = String(message[range]).trimmingCharacters(in: .whitespaces)
                
                // AttributedString에서 해당 범위 찾기
                if let attributedRange = attributedString.range(of: flowerName) {
                    attributedString[attributedRange].font = .body.bold()
                    attributedString[attributedRange].foregroundColor = .yellow
                }
                break
            }
        }
        
        return attributedString
    }
}

// MARK: - 사용 예시 (ARCameraView에서 교체)
// iOS 15.0 이상인 경우:
// EnhancedARStatusView(message: viewModel.statusMessage)

// iOS 15.0 미만인 경우:
// ARStatusView(message: viewModel.statusMessage) // 기존 개선된 버전 사용
