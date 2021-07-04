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
    
    private func load(token: String, result: @escaping (Dashboard?) -> ()) {
        if let url = URL(string: Dashboard.url + token) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    let decodedData = try? JSONDecoder().decode(Dashboard.self, from: data)
                    result(decodedData)
                }
            }.resume()
        }
    }
}
