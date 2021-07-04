//
//  DashboardViewController.swift
//  AluDash
//
//  Created by Rafael Escaleira on 03/07/21.
//

import UIKit
import SafariServices

class DashboardViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!
    private var dashboardViewModel: DashboardViewModel!
    private var searchController = UISearchController(searchResultsController: nil)
    private var token: String? = UserDefaults.standard.string(forKey: "Token")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dashboardViewModel = DashboardViewModel(token: self.token ?? "")
        self.reloadButton()
        self.dashboardViewModel.bind = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        self.setSearchBar(searchController: self.searchController, placeholder: "Informe o token", self, self)
    }
    
    @IBAction func reloadButton() {
        self.dashboardViewModel.reload(token: self.token ?? "")
    }
    
    func setSearchBar(searchController: UISearchController, placeholder: String = "Search", _ searchBarDelegate: UISearchBarDelegate, _ searchResultsUpdater: UISearchResultsUpdating) {
        searchController.searchResultsUpdater = searchResultsUpdater
        searchController.searchBar.delegate = searchBarDelegate
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = placeholder
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty == false {
            UserDefaults.standard.setValue(searchController.searchBar.text!, forKey: "Token")
            self.dashboardViewModel.reload(token: searchController.searchBar.text!)
        }
    }
}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.dashboardViewModel.dashboard == nil) { return "" }
        return section == 0 ? nil : section == 1 ? "Cursos em Andamento" : "Progresso na Formação"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (self.dashboardViewModel.dashboard == nil ? 1 : 0) : section == 1 ? self.dashboardViewModel.dashboard?.courseProgresses?.count ?? 0 : self.dashboardViewModel.dashboard?.guides?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoData", for: indexPath)
            cell.selectionStyle = .none
            cell.accessoryType = .none
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseProgressesTableViewCell", for: indexPath) as? CourseProgressesTableViewCell
            cell?.approvedImage.image = self.dashboardViewModel.dashboard?.courseProgresses?[indexPath.row].finished == true ? UIImage(systemName: "checkmark.seal.fill") : UIImage(systemName: "xmark.seal.fill")
            cell?.approvedImage.tintColor = self.dashboardViewModel.dashboard?.courseProgresses?[indexPath.row].progress == 0 ? .systemPink : self.dashboardViewModel.dashboard?.courseProgresses?[indexPath.row].progress == 100 ? .systemGreen : .systemOrange
            cell?.courseTitle.text = self.dashboardViewModel.dashboard?.courseProgresses?[indexPath.row].name
            cell?.coursePercent.text = "\(self.dashboardViewModel.dashboard?.courseProgresses?[indexPath.row].progress ?? 0)%"
            cell?.courseProgress.setProgress(Float(self.dashboardViewModel.dashboard?.courseProgresses?[indexPath.row].progress ?? 0) / 100.0, animated: true)
            cell?.courseProgress.tintColor = self.dashboardViewModel.dashboard?.courseProgresses?[indexPath.row].progress == 0 ? .systemPink : self.dashboardViewModel.dashboard?.courseProgresses?[indexPath.row].progress == 100 ? .systemGreen : .systemOrange
            let date = Date(timeIntervalSince1970: TimeInterval(self.dashboardViewModel.dashboard?.courseProgresses?[indexPath.row].lastAccessTime ?? 0) / 1000)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            cell?.courseDate.text = formatter.string(from: date)
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
            return cell ?? tableView.dequeueReusableCell(withIdentifier: "NoData", for: indexPath)
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseProgressesTableViewCell", for: indexPath) as? CourseProgressesTableViewCell
            cell?.approvedImage.image = UIImage(systemName: "video.bubble.left.fill")
            cell?.approvedImage.tintColor = self.dashboardViewModel.dashboard?.guides?[indexPath.row].finishedCourses == 0 ? .systemPink : self.dashboardViewModel.dashboard?.guides?[indexPath.row].finishedCourses == self.dashboardViewModel.dashboard?.guides?[indexPath.row].totalCourses ? .systemGreen : .systemOrange
            cell?.courseTitle.text = self.dashboardViewModel.dashboard?.guides?[indexPath.row].name
            cell?.coursePercent.text = "\(Int((Float(self.dashboardViewModel.dashboard?.guides?[indexPath.row].finishedCourses ?? 0) / Float(self.dashboardViewModel.dashboard?.guides?[indexPath.row].totalCourses ?? 1)) * 100.0))%"
            cell?.courseProgress.setProgress((Float(self.dashboardViewModel.dashboard?.guides?[indexPath.row].finishedCourses ?? 0) / Float(self.dashboardViewModel.dashboard?.guides?[indexPath.row].totalCourses ?? 1)), animated: true)
            cell?.courseProgress.tintColor = self.dashboardViewModel.dashboard?.guides?[indexPath.row].finishedCourses == 0 ? .systemPink : self.dashboardViewModel.dashboard?.guides?[indexPath.row].finishedCourses == self.dashboardViewModel.dashboard?.guides?[indexPath.row].totalCourses ? .systemGreen : .systemOrange
            let date = Date(timeIntervalSince1970: TimeInterval(self.dashboardViewModel.dashboard?.guides?[indexPath.row].lastAccessTime ?? 0) / 1000)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            cell?.courseDate.text = formatter.string(from: date)
            cell?.selectionStyle = .default
            cell?.accessoryType = .disclosureIndicator
            return cell ?? tableView.dequeueReusableCell(withIdentifier: "NoData", for: indexPath)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if let url = URL(string: "https://www.alura.com.br" + (self.dashboardViewModel.dashboard?.guides?[indexPath.row].url ?? "")) {
                let safariViewController = SFSafariViewController(url: url)
                self.present(safariViewController, animated: true, completion: nil)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

public class CourseProgressesTableViewCell: UITableViewCell {
    @IBOutlet weak var approvedImage: UIImageView!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var coursePercent: UILabel!
    @IBOutlet weak var courseDate: UILabel!
    @IBOutlet weak var courseProgress: UIProgressView!
}
