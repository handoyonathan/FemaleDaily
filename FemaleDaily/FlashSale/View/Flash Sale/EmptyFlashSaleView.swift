//
//  EmptyFlashSaleView.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import SwiftUI

struct EmptyFlashSaleView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No flash sales scheduled for this day")
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct EmptyFlashSaleView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyFlashSaleView()
    }
}
