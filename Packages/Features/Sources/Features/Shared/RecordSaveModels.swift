import CoreLocation
import UIKit

public struct RecordSaveSheetInfo {
    let flower: ARFlower
    let location: CLLocation
    let address: String
}

public struct FinalRecordData {
    let images: [UIImage]
    let description: String
}
