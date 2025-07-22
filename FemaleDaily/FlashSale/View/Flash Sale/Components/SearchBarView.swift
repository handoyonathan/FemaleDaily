//
//  SearchBarView.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            // Tombol Back
            Image(systemName: "arrow.left")
                .foregroundColor(.red)
                .padding(.leading, 10)
                .padding(.trailing, 3)
                .fontWeight(.medium)
            
            // Search Box
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.red)
                
                TextField("Search your favorite brands here..", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.subheadline)
            }
            // atribut buat di dalem search boxnya
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            // buat diluar search boxnya
            .padding(.trailing)
            .padding(.top, 5)
            .padding(.bottom, 15)
            
            // Simbol Love
//            Image(systemName: "heart")
//                .padding(.trailing, 18)
//                .padding(.leading, 5)
//                .foregroundColor(.red)
//                .fontWeight(.medium)
        }
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
    }
}
