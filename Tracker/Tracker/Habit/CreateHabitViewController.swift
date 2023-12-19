//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Dinara on 02.12.2023.
//

import UIKit
import SnapKit

final class CreateHabitViewController: UIViewController {

    // MARK: - ScheduleViewControllerDelegate
    weak var delegate: ScheduleViewControllerDelegate?

    // MARK: - Private properties
    private var selectedWeekDays: [WeekDay] = []
    private var newTracker: NewTracker?
    private var trackers: [Tracker] = []
    private lazy var category: String? =  TrackerCategory(title: "Домашние дела", trackers: self.trackers).title

    // MARK: -  UI
    private lazy var navBarLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.rightView = clearTextFieldButton
        textField.rightViewMode = .whileEditing
        return textField
    }()


    private lazy var clearTextFieldButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "clear_icon"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(clearTextFieldButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CreateHabitCell.self,
                           forCellReuseIdentifier: CreateHabitCell.cellID)
        tableView.backgroundColor = UIColor(named: "YP Gray")?.withAlphaComponent(0.3)
        tableView.layer.cornerRadius = 16
        return tableView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: "YP Red"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,
                                                    weight: .medium)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(named: "YP Red")?.cgColor
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,
                                                    weight: .medium)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YP Dark Gray")
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = UIColor.white
        textFieldContainerView.addSubview(trackersNameTextField)
        trackersNameTextField.addSubview(clearTextFieldButton)

        [navBarLabel,
         textFieldContainerView,
         tableView,
         cancelButton,
         createButton
        ].forEach  {
            view.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
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

        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-34)
            make.height.equalTo(60)
            make.width.equalTo(166)
        }

        createButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-34)
            make.height.equalTo(60)
            make.width.equalTo(161)
        }
    }

    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func createButtonTapped() {
        //TODO
    }

    @objc private func clearTextFieldButtonTapped() {
        trackersNameTextField.text = ""
        clearTextFieldButton.isHidden = true
    }
}

// MARK: - UITextFieldDelegate
extension CreateHabitViewController: UITextFieldDelegate {
    // MARK: - Text Field Change Handler
    @objc private func textFieldDidChange() {
        if let text = trackersNameTextField.text, !text.isEmpty {
            clearTextFieldButton.isHidden = false
        } else {
            clearTextFieldButton.isHidden = true
        }
    }
}

// MARK: - UITableViewDataSource
extension CreateHabitViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CreateHabitCell.cellID,
            for: indexPath) as? CreateHabitCell else {
            fatalError("Could not cast to CreateTrackerCell")
        }

        if indexPath.row == 0 {
            cell.configureCell(with: "Категория", subtitle: category, isFirstCell: true)
        }  else if indexPath.row == 1 {
            let schedule = selectedWeekDays.isEmpty ? "" : selectedWeekDays.map { $0.shortTitle }.joined(separator: ", ")
            cell.configureCell(with: "Расписание", subtitle: schedule, isFirstCell: false)
        }

        let imageView = UIImageView(image: UIImage(named: "right_array_icon"))
        cell.accessoryView = imageView
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CreateHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            print("Category Selected")
        } else if indexPath.row == 1 {
            let viewController = ScheduleViewController()
            viewController.delegate = self
            self.delegate?.didSelectDays(self.selectedWeekDays)
            present(viewController, animated: true, completion: nil)
        }
    }
}

// MARK: - ScheduleViewControllerDelegate
extension CreateHabitViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        selectedWeekDays = days
        tableView.reloadData()
    }
}
