//
//  BrandCard.swift
//  FemaleDaily
//
//  Created by Valencia Sutanto on 21/07/25.
//

import SwiftUI

struct BrandCard: View{
    
    var namaBrand: String
    var kategoriBrand: String
    var landmarkBrand: String
    @State private var isLiked = false
    
    var body: some View{
        HStack{
            Image(systemName: "Test")
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red, lineWidth: 2)
                )
                .padding(.leading, 20)

                
            VStack(alignment: .leading){
                VStack(alignment: .leading, spacing: 2){
                    HStack{
                        Text(namaBrand)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                                .onTapGesture {
                                    isLiked.toggle()
                                }
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.red)
                            .padding(.trailing, 20)
                    }
        
                    Text(kategoriBrand)
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                }
             
                Text(landmarkBrand)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .font(.system(size: 12))
                    .frame(width: 138, height: 25)
                    .overlay { RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.red, lineWidth: 1)
                    }
            }
            .padding(.leading, 20)
            
     
            Spacer()
            
        }
        .frame(width: 369, height: 111)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: 5)
        
    }
}

#Preview{
    BrandCard(namaBrand: "Skintific", kategoriBrand: "Makeup and Skincare", landmarkBrand: "Pond's Glow Tunnel")
}
