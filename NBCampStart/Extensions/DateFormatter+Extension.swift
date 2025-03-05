//
//  DateFormatter+Extension.swift
//  NBCampStart
//
//  Created by 서동환 on 3/4/25.
//

import Foundation

extension DateFormatter {
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        
        return formatter
    }()
    
    static func getDateFormatter() -> DateFormatter {
        return dateFormatter
    }
}
