//
//  TaskListViewController.swift
//  TaskList
//
//  Created by Shamkhan Mutuskhanov on 31.07.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    // MARK: - Private Properties
    private let storageManager = StorageManager.shared
    private let cellID = "task"
    
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigatorBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        storageManager.fetchData()
        
    }
    
    // MARK: - Private Methods
    private func setupNavigatorBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", message: "What do you want to do?", placeholder: "New Task")
    }
}

// MARK: - UITableView Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        storageManager.taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = storageManager.taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskToUpdate = storageManager.taskList[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        showAlert(
            withTitle: "Change the task",
            message: "Do you want to change the task?",
            placeholder: "Update the task",
            taskToUpdate: taskToUpdate
        )
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            storageManager.deleteTask(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UIAlertController
extension TaskListViewController {
    private func showAlert(withTitle title: String, message: String, placeholder: String, taskToUpdate: Task? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            
            if let taskToUpdate = taskToUpdate {
                storageManager.updateTask(taskToUpdate, with: task)
                tableView.reloadData()
            } else {
                storageManager.saveTask(task)
                let cellIndex = IndexPath(row: storageManager.taskList.count - 1, section: 0)
                tableView.insertRows(at: [cellIndex], with: .automatic)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = placeholder
            if let taskToUpdate = taskToUpdate {
                textField.text = taskToUpdate.title
            }
        }
        present(alert, animated: true)
    }
}

