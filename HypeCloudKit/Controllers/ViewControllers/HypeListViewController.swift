//
//  HypeListViewController.swift
//  HypeCloudKit
//
//  Created by Jon Corn on 2/4/20.
//  Copyright © 2020 Jon Corn. All rights reserved.
//

import UIKit

class HypeListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var hypeTableView: UITableView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    // MARK: - Actions
    @IBAction func composeButtonTapped(_ sender: Any) {
        presentAddHypeAlert(for: nil)
    }
    
    // MARK: - Methods
    func setupViews() {
        hypeTableView.dataSource = self
        hypeTableView.delegate = self
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.hypeTableView.reloadData()
        }
    }
    
    func loadData() {
        HypeController.shared.fetchAllHypes { (result) in
            switch result {
            case .success(let hypes):
                HypeController.shared.hypes = hypes
                self.updateViews()
            case .failure(let error):
                print(error.errorDescription ?? error)
            }
        }
    }
}

// MARK: - TableviewDelegate, DataSource ext
extension HypeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypeController.shared.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        let hype = HypeController.shared.hypes[indexPath.row]
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = hype.timestamp.formatToString()
        return cell
    }
}

// MARK: - AlertController ext
extension HypeListViewController {
    func presentAddHypeAlert(for hype: Hype?) {
        let alertController = UIAlertController(title: "Get Hype!", message: "What is hype may never die", preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            textfield.delegate = self
            textfield.placeholder = "What is hype today?"
            textfield.autocorrectionType = .yes
            textfield.autocapitalizationType = .sentences
        }
        let addHypeAction = UIAlertAction(title: "Send", style: .default) { (_) in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else {return}
            if let hype = hype {
                hype.body = text
                HypeController.shared.update(hype) { (result) in
                    self.updateViews()
                }
            } else {
                HypeController.shared.saveHype(with: text) { (result) in
                    switch result {
                    case .success(let hype):
                        guard let hype = hype else {return}
                        HypeController.shared.hypes.insert(hype, at: 0)
                        self.updateViews()
                    case .failure(let error):
                        print(error.errorDescription ?? error)
                    }
                }
            }
        }
        let cancelHypeAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(addHypeAction)
        alertController.addAction(cancelHypeAction)
        self.present(alertController, animated: true)
    }
}

// MARK: - UITextFieldDelegate ext
extension HypeListViewController: UITextFieldDelegate {
    
}
