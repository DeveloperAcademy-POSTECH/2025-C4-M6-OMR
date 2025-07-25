import SwiftUI
import CoreLocation
import DesignSystem

struct MyRecordBottomSheet: View {
    @Binding var selectedPosition: SheetPosition
    @ObservedObject var viewModel: MyRecordBottomSheetViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Drag Indicator
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
            
            
                VStack (alignment: .leading) {
                    Text("내 꽃")
                        .font(DesignSystem.Font.Title1.semibold)
                        .padding(.bottom, 8)
                    
                    Text("\(viewModel.allMotes.count)개의 꽃")
                        .font(DesignSystem.Font.Title3.semibold)
                        .foregroundColor(DesignSystem.Color.Gray_03)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
            
            
            Spacer(minLength: 0)
        }
        .background(Color.white)
        
        .cornerRadius(16)
        .onAppear {
            viewModel.loadAllMotes()
        }
        
    }
    
}
