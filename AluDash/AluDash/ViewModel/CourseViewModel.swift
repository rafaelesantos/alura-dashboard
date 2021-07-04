//
//  CourseViewModel.swift
//  AluDash
//
//  Created by Rafael Escaleira on 04/07/21.
//

import Foundation
import UIKit

public class CourseViewModel {
    var bind: () -> () = {}
    private (set) var course: Course? {
        didSet { self.bind() }
    }
    
    init(slug: String) {
        self.load(slug: slug) { course in
            if let course = course { self.course = course }
        }
    }
    
    func reload(slug: String) {
        self.load(slug: slug) { course in
            if let course = course { self.course = course }
        }
    }
    
    func load(slug: String, result: @escaping (Course?) -> ()) {
        if let url = URL(string: Course.url + slug) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    let decodedData = try? JSONDecoder().decode(Course.self, from: data)
                    result(decodedData)
                }
            }.resume()
        }
    }
}
