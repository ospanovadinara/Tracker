//
//  AddCategoryViewController.swift
//  Tracker
//
//  Created by Dinara on 05.03.2024.
//

import UIKit
import SnapKit

protocol AddCategoryViewControllerDelegate: AnyObject {
    func addCategory(_ category: TrackerCategory)
}

final class AddCategoryViewController: UIViewController {
    weak var delegate: AddCategoryViewControllerDelegate?
    private let trackerCategoryStore = TrackerCategoryStore.shared

    // MARK: - UI
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.textColor = UIColor(named: "YP Black")
        textField.backgroundColor = UIColor(named: "YP TextField Gray")
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldTapped(sender:)), for: .editingChanged)
        textField.delegate = self
        let leftView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 16, 
                height: 0
            )
        )
        textField.leftView = leftView
        textField.leftViewMode = .always

        return textField
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,
                                                    weight: .medium)
        button.backgroundColor = UIColor(named: "YP Dark Gray")
        button.addTarget(self, action: #selector(doneButtonTapped(sender:)), for: .touchUpInside)
        button.layer.cornerRadius = 16
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
}

private extension AddCategoryViewController {
    // MARK: - Setup Views
    func setupViews() {
        view.backgroundColor = UIColor.white
        navigationItem.title = "Новая категория"

        [textField,
         doneButton
        ].forEach {
            view.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
    func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(84)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(75)
        }

        doneButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-54)
            make.height.equalTo(60)
        }
    }

    // MARK: - Actions
    @objc private func textFieldTapped(sender: AnyObject) {
        guard let text = textField.text else { return }
        if text.isEmpty {
            doneButton.backgroundColor = UIColor(named: "YP TextField Gray")
            doneButton.isEnabled = false
        } else {
            doneButton.backgroundColor = UIColor(named: "YP Black")
            doneButton.isEnabled = true
        }
    }

    @objc private func doneButtonTapped(sender: AnyObject) {
        guard let title = textField.text else { return }
        let category = TrackerCategory(
            title: title,
            trackers: []
        )
        try? trackerCategoryStore.addNewTrackerCategory(category)
        delegate?.addCategory(category)
        dismiss(animated: true)
    }
}

extension AddCategoryViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.isEmpty ?? false {
            doneButton.isEnabled = false
            doneButton.backgroundColor = UIColor(named: "YP TextField Gray")
        } else {
            doneButton.isEnabled = true
            doneButton.backgroundColor = UIColor(named: "YP Black")
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
