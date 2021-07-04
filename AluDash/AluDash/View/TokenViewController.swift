//
//  TokenViewController.swift
//  AluDash
//
//  Created by Rafael Escaleira on 04/07/21.
//

import UIKit

protocol TokenDelegate {
    func token(_ token: String)
}

class TokenViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tokenField: UITextField!
    
    var dashboardViewModel: DashboardViewModel!
    var delegate: TokenDelegate!
    private var tokens: [String] = UserDefaults.standard.value(forKey: "tokens") as? [String] ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func saveTokenButton() {
        self.view.endEditing(true)
        if let token = tokenField.text, token.isEmpty == false, self.tokens.contains(token) == false {
            self.dashboardViewModel.load(token: token) { dashboard in
                DispatchQueue.main.async {
                    if dashboard != nil {
                        self.tokens.append(token)
                        UserDefaults.standard.setValue(self.tokens, forKey: "tokens")
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

extension TokenViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.tokens[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .systemBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tokens Adicionados"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.setValue(self.tokens[indexPath.row], forKey: "selected_token")
        self.delegate.token(self.tokens[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
