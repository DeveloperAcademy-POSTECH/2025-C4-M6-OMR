//
//  BottomSheetType.swift
//  Features
//
//  Created by eunsong on 7/26/25.
//

enum BottomSheetType: Identifiable {
    case flowerSelection
    case recordDetail
    case saveSheet

    var id: String {
        switch self {
        case .flowerSelection: return "flowerSelection"
        case .recordDetail: return "recordDetail"
        case .saveSheet: return "saveSheet"
        }
    }
}
