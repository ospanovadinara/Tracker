//
//  TrackersCreationViewController.swift
//  Tracker
//
//  Created by Dinara on 02.12.2023.
//

import UIKit
import SnapKit

final class CreateTrackersViewController: UIViewController {

    // MARK: -  UI
    private lazy var navBarLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private lazy var textFieldContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YP Gray")?.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var trackersNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textAlignment = .left
        textField.placeholder = "Введите название трекера"
        textField.textColor = UIColor.black
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CreateTrackerCell.self,
                           forCellReuseIdentifier: CreateTrackerCell.cellID)
        tableView.backgroundColor = UIColor(named: "YP Gray")?.withAlphaComponent(0.3)
        tableView.layer.cornerRadius = 16
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        view.backgroundColor = UIColor.white
        textFieldContainerView.addSubview(trackersNameTextField)

        [navBarLabel,
         textFieldContainerView,
         tableView
        ].forEach  {
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        navBarLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
        }

        textFieldContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(88)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(75)
        }

        trackersNameTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(75)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(textFieldContainerView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(150)
        }
    }
}

// MARK: - UITextFieldDelegate
extension CreateTrackersViewController: UITextFieldDelegate {
    // MARK: - Text Field Change Handler
    @objc private func textFieldDidChange(_ textField: UITextField) {
    }
}

// MARK: - UITableViewDataSource
extension CreateTrackersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CreateTrackerCell.cellID,
            for: indexPath) as? CreateTrackerCell else {
            fatalError("Could not cast to CreateTrackerCell")
        }

        if indexPath.row == 0 {
            cell.configureCell(with: "Категория", isFirstCell: true)
        }  else {
            cell.configureCell(with: "Расписание", isFirstCell: false)
        }
        
        let imageView = UIImageView(image: UIImage(named: "right_array_icon"))
        cell.accessoryView = imageView
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CreateTrackersViewController: UITableViewDelegate {

}
