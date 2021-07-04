//
//  CourseViewController.swift
//  AluDash
//
//  Created by Rafael Escaleira on 04/07/21.
//

import UIKit
import AVFoundation
import AVKit

class CourseViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var courseViewModel: CourseViewModel!
    var courseSlug: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.courseViewModel = CourseViewModel(slug: courseSlug)
        self.courseViewModel.bind = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func backToDashboard() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CourseViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.courseViewModel.course?.ementa?.count ?? 0 + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.courseViewModel.course?.ementa?[section].secoes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : self.courseViewModel.course?.ementa?[section].capitulo
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CourseHeadTableViewCell", for: indexPath) as? CourseHeadTableViewCell else { return UITableViewCell() }
            let item = self.courseViewModel.course
            cell.courseTitle.text = item?.nome
            cell.courseDescription.text = "\(item?.metadescription ?? "")\n\(item?.publico_alvo ?? "")"
            cell.courseCreatedUpdated.text = "\(item?.data_criacao?.components(separatedBy: "-").reversed().joined(separator: "/") ?? "") à \(item?.data_atualizacao?.components(separatedBy: "-").reversed().joined(separator: "/") ?? "")"
            cell.testAmount.text = "\(item?.quantidade_avaliacoes ?? 0)"
            cell.hourAmount.text = "\(item?.carga_horaria ?? 0)"
            cell.activityAmount.text = "\(item?.quantidade_atividades ?? 0)"
            cell.selectionStyle = .none
            cell.backgroundColor = .secondarySystemBackground
            return cell
        } else {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.textLabel?.text = "\(indexPath.row + 1). \(self.courseViewModel.course?.ementa?[indexPath.section].secoes?[indexPath.row] ?? "")"
            cell.textLabel?.numberOfLines = 0
            cell.backgroundColor = .systemBackground
            return cell
        }
    }
}

public class CourseHeadTableViewCell: UITableViewCell {
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseDescription: UILabel!
    @IBOutlet weak var courseCreatedUpdated: UILabel!
    @IBOutlet weak var testAmount: UILabel!
    @IBOutlet weak var hourAmount: UILabel!
    @IBOutlet weak var activityAmount: UILabel!
}
