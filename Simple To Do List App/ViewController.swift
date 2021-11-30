//
//  ViewController.swift
//  Simple To Do List App
//
//  Created by Nilosh on 2021-11-30.
//

import StoreKit
import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDataSource {
   
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var items = [String]()
    var center = UNUserNotificationCenter.current()
    var isGranted : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            self.isGranted = true
        }
        
        self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        title = "To Do List"
        view.addSubview(table)
        table.dataSource = self
        table.tableFooterView = createFooter()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
    }
    
    private func createFooter() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
//        footer.backgroundColor = .secondarySystemBackground
        
        let size = (view.frame.size.width-40)/2
        
        for x in 0..<2 {
            let button = UIButton(frame: CGRect(x: CGFloat(x) * size + (CGFloat(x) + 1 * 10), y: 0, width: size, height: size - 60))
            
            footer.addSubview(button)
            button.tag = x + 1
            button.setBackgroundImage(UIImage(named: "app\(x+1)"), for: .normal)
            
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        }
        
        return footer
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        let tag = sender.tag
        
        if tag == 1 {
            // excel
            guard let url = URL(string: "ms-excel://") else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                // deep link
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            } else {
                //upsell
                let vc = SKStoreProductViewController()
                vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier  : NSNumber(value: 586683407)], completionBlock: nil)
                present(vc, animated: true)
            }
        } else if tag == 2 {
            // word
            guard let url = URL(string: "ms-word://") else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                // deep link
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                //upsell
                let vc = SKStoreProductViewController()
                vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier  : NSNumber(value: 586447913)], completionBlock: nil)
                present(vc, animated: true)
            }
        }
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = "Enter Item..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self ](_) in
            if let field = alert.textFields?.first {
                if let text = field.text, !text.isEmpty {
                    print(text)
            
                    DispatchQueue.main.async {
                        var currentItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
                        currentItems.append(text)
                        UserDefaults.standard.setValue(currentItems, forKey: "items")
                        self?.items.append(text)
                        self?.table.reloadData()
                        self?.createNotification(task: text)
                    }
                }
            }
        }))
        
        present(alert, animated: true)
    }
    
    private func createNotification(task : String) {
        if (isGranted) {
            
            let content = UNMutableNotificationContent()
            content.title = "New Task Added"
            content.body = task
            
            let date = Date().addingTimeInterval(8)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            self.center.add(request) { (error) in
                // handle any error
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    

}

