//
//  Dashboard.swift
//  AluDash
//
//  Created by Rafael Escaleira on 03/07/21.
//

import Foundation

struct Dashboard: Codable {
    static let url: String = "https://www.alura.com.br/api/dashboard/"
    var id: Int?
    var courseProgresses: [CourseProgresses]?
    var guides: [Guides]?
    
    struct CourseProgresses: Codable {
        var slug: String?
        var finished: Bool?
        var name: String?
        var lastAccessTime: Int?
        var id: Int?
        var progress: Int?
        var readyToFinish: Bool?
    }
    
    struct Guides: Codable {
        var id: Int?
        var code: String?
        var name: String?
        var url: String?
        var lastAccessTime: Int?
        var kind: String?
        var totalCourses: Int?
        var finishedCourses: Int?
        var totalSteps: Int?
        var finishedSteps: Int?
        var color: String?
        var author: String?
    }
}
