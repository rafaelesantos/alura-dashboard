//
//  Dashboard.swift
//  AluDash
//
//  Created by Rafael Escaleira on 03/07/21.
//

import Foundation

struct Dashboard: Codable {
    static let url: String = "https://www.alura.com.br/api/dashboard/"
    let id: Int?
    let courseProgresses: [CourseProgresses]?
    let guides: [Guides]?
    
    struct CourseProgresses: Codable {
        let slug: String?
        let finished: Bool?
        let name: String?
        let lastAccessTime: Int?
        let id: Int?
        let progress: Int?
        let readyToFinish: Bool?
    }
    
    struct Guides: Codable {
        let id: Int?
        let code: String?
        let name: String?
        let url: String?
        let lastAccessTime: Int?
        let kind: String?
        let totalCourses: Int?
        let finishedCourses: Int?
        let totalSteps: Int?
        let finishedSteps: Int?
        let color: String?
        let author: String?
    }
}
