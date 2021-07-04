//
//  DashboardViewController.swift
//  AluDash
//
//  Created by Rafael Escaleira on 03/07/21.
//

import UIKit
import SafariServices

class DashboardViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    private var dashboardViewModel: DashboardViewModel!
    private var token: String? = UserDefaults.standard.string(forKey: "selected_token")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(macCatalyst)
        self.leftConstraint.constant = 70
        self.rightConstraint.constant = 70
        #endif
        self.dashboardViewModel = DashboardViewModel(token: self.token ?? "")
        self.reloadButton()
        self.dashboardViewModel.bind = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func reloadButton() {
        guard let controller = storyboard?.instantiateViewController(identifier: "TokenViewController") as? TokenViewController else { return }
        controller.dashboardViewModel = self.dashboardViewModel
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
}

extension DashboardViewController: TokenDelegate {
    func token(_ token: String) {
        self.dashboardViewModel.reload(token: token)
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
            cell?.approvedImage.image = UIImage(systemName: "circle.dashed.inset.fill")
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
            cell?.accessoryType = .disclosureIndicator
            return cell ?? tableView.dequeueReusableCell(withIdentifier: "NoData", for: indexPath)
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseProgressesTableViewCell", for: indexPath) as? CourseProgressesTableViewCell
            cell?.approvedImage.image = UIImage(systemName: "circle.dashed")
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
        } else if indexPath.section == 1 {
            guard let controller = storyboard?.instantiateViewController(identifier: "CourseViewController") as? CourseViewController else { return }
            controller.courseSlug = self.dashboardViewModel.dashboard?.courseProgresses?[indexPath.row].slug
            self.present(controller, animated: true, completion: nil)
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
