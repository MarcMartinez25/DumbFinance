//
//  Models.swift
//  financefriend
//
//  Created by Margo Martinez on 8/3/25.
//

import SwiftUI
import SwiftData

// MARK: - Data Models

enum AccountType: String, CaseIterable, Codable {
    case checking = "Checking"
    case savings = "Savings"
    case creditCard = "Credit Card"
    
    var icon: String {
        switch self {
        case .checking:
            return "banknote"
        case .savings:
            return "piggybank"
        case .creditCard:
            return "creditcard"
        }
    }
}

@Model
class Account {
    var id: UUID
    var name: String
    var colorData: Data
    var type: AccountType
    var balance: Double
    
    init(name: String, color: Color, type: AccountType, balance: Double) {
        self.id = UUID()
        self.name = name
        self.colorData = Self.colorToData(color)
        self.type = type
        self.balance = balance
    }
    
    var color: Color {
        get {
            Self.dataToColor(colorData)
        }
        set {
            colorData = Self.colorToData(newValue)
        }
    }
    
    // Helper methods to convert Color to/from Data for SwiftData storage
    private static func colorToData(_ color: Color) -> Data {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let colorArray = [red, green, blue, alpha]
        return try! JSONEncoder().encode(colorArray)
    }
    
    private static func dataToColor(_ data: Data) -> Color {
        guard let colorArray = try? JSONDecoder().decode([CGFloat].self, from: data),
              colorArray.count == 4 else {
            return .blue // Default fallback color
        }
        
        return Color(.sRGB, red: colorArray[0], green: colorArray[1], blue: colorArray[2], opacity: colorArray[3])
    }
}
