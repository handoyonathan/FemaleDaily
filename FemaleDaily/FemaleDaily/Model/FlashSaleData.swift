//
//  FlashSaleData.swift
//  FlashSale
//
//  Created by Daven Karim on 21/07/25.
//

import Foundation

struct FlashSaleData {
    static var events: [FlashSaleEvent] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        // Tanggal-tanggal yang ditentukan
        let date3 = dateFormatter.date(from: "2025/07/03")!
        let date4 = dateFormatter.date(from: "2025/07/04")!
        let date5 = dateFormatter.date(from: "2025/07/05")!
        let date6 = dateFormatter.date(from: "2025/07/06")!
        
        let sampleBrandDetail = BrandDetail(
            name: "Brand Name",
            description: "Sample description",
            images: ["placeholder1", "placeholder2"],
            flashSaleSchedule: "12:00 - 14:00",
            products: [
                Product(name: "Produk A", description: "Deskripsi A", image: "product1"),
                Product(name: "Produk B", description: "Deskripsi B", image: "product2"),
                Product(name: "Produk C", description: "Deskripsi C", image: "product3"),
                Product(name: "Produk D", description: "Deskripsi D", image: "product4")
            ]
        )
        return [
            // Tanggal 3 Juli
            // Jam 12:00
            FlashSaleEvent(
                brandName: "Brand A",
                description: "Description for Brand A",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date3)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date3)!,
                date: date3,
                brandDetail: sampleBrandDetail
            ),
            FlashSaleEvent(
                brandName: "Brand B",
                description: "Description for Brand B",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date3)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date3)!,
                date: date3,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand C",
                description: "Description for Brand C",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date3)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date3)!,
                date: date3,
                brandDetail: sampleBrandDetail

            ),
            // Jam 13:00
            FlashSaleEvent(
                brandName: "Brand D",
                description: "Description for Brand D",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date3)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date3)!,
                date: date3,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand E",
                description: "Description for Brand E",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date3)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date3)!,
                date: date3,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand F",
                description: "Description for Brand F",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date3)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date3)!,
                date: date3,
                brandDetail: sampleBrandDetail

            ),
            
            // Tanggal 4 Juli
            // Jam 12:00
            FlashSaleEvent(
                brandName: "Brand G",
                description: "Description for Brand G",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date4)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date4)!,
                date: date4,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand H",
                description: "Description for Brand H",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date4)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date4)!,
                date: date4,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand I",
                description: "Description for Brand I",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date4)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date4)!,
                date: date4,
                brandDetail: sampleBrandDetail

            ),
            // Jam 13:00
            FlashSaleEvent(
                brandName: "Brand J",
                description: "Description for Brand J",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date4)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date4)!,
                date: date4,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand K",
                description: "Description for Brand K",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date4)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date4)!,
                date: date4,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand L",
                description: "Description for Brand L",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date4)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date4)!,
                date: date4,
                brandDetail: sampleBrandDetail

            ),
            
            // Tanggal 5 Juli
            // Jam 12:00
            FlashSaleEvent(
                brandName: "Brand M",
                description: "Description for Brand M",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date5)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date5)!,
                date: date5,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand N",
                description: "Description for Brand N",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date5)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date5)!,
                date: date5,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand O",
                description: "Description for Brand O",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date5)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date5)!,
                date: date5,
                brandDetail: sampleBrandDetail

            ),
            // Jam 13:00
            FlashSaleEvent(
                brandName: "Brand P",
                description: "Description for Brand P",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date5)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date5)!,
                date: date5,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand Q",
                description: "Description for Brand Q",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date5)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date5)!,
                date: date5,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand R",
                description: "Description for Brand R",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date5)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date5)!,
                date: date5,
                brandDetail: sampleBrandDetail

            ),
            
            // Tanggal 6 Juli
            // Jam 12:00
            FlashSaleEvent(
                brandName: "Brand S",
                description: "Description for Brand S",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date6)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date6)!,
                date: date6,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand T",
                description: "Description for Brand T",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date6)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date6)!,
                date: date6,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand U",
                description: "Description for Brand U",
                startTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date6)!,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date6)!,
                date: date6,
                brandDetail: sampleBrandDetail

            ),
            // Jam 13:00
            FlashSaleEvent(
                brandName: "Brand V",
                description: "Description for Brand V",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date6)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date6)!,
                date: date6,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand W",
                description: "Description for Brand W",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date6)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date6)!,
                date: date6,
                brandDetail: sampleBrandDetail

            ),
            FlashSaleEvent(
                brandName: "Brand X",
                description: "Description for Brand X",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date6)!,
                endTime: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: date6)!,
                date: date6,
                brandDetail: sampleBrandDetail

            )
        ]
    }
}
