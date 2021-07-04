//
//  DashboardViewModel.swift
//  AluDash
//
//  Created by Rafael Escaleira on 03/07/21.
//

import Foundation
import UIKit

public class DashboardViewModel {
    var bind: () -> () = {}
    private (set) var dashboard: Dashboard? {
        didSet { self.bind() }
    }
    
    init(token: String) {
        self.load(token: token) { dashboard in
            if let dashboard = dashboard { self.dashboard = dashboard }
        }
    }
    
    func reload(token: String) {
        self.load(token: token) { dashboard in
            if let dashboard = dashboard { self.dashboard = dashboard }
        }
    }
    
    func load(token: String, result: @escaping (Dashboard?) -> ()) {
        if let url = URL(string: Dashboard.url + token) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    var decodedData = try? JSONDecoder().decode(Dashboard.self, from: data)
                    decodedData?.guides?.sort(by: { prev, next in
                        let prevProgress = Float(prev.finishedCourses ?? 0) / Float(prev.totalCourses ?? 1)
                        let nextProgress = Float(next.finishedCourses ?? 0) / Float(next.totalCourses ?? 1)
                        return prevProgress > nextProgress
                    })
                    decodedData?.courseProgresses?.sort(by: { prev, next in
                        let prevProgress = Float(prev.progress ?? 0)
                        let nextProgress = Float(next.progress ?? 0)
                        return prevProgress > nextProgress
                    })
                    result(decodedData)
                }
            }.resume()
        }
    }
}
