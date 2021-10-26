//
//  ViewController.swift
//  testOne
//
//  Created by sleman on 14.10.21.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    
    
    let tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(StreetTableViewCell.self, forCellReuseIdentifier: "contactCell")
        return tableView
    }()
    let buttonAddCell: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(("+"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.tintColor = .white
        button.titleLabel!.font = UIFont(name: "Arial", size: 60)
        button.titleLabel!.textAlignment = .center
        button.heightAnchor.constraint(equalToConstant: 70).isActive = true
        button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        button.layer.cornerRadius = 70 / 2.0
        button.addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
        return button
    }()
    
    let viewTop: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // cancel demo

    var arrayStreet: [Street] = []
    var indexCellWherePutImages: Int?
    var streetWhyPick: Street!
    let store = Storage.storage()

    override func viewDidLoad() {
        super.viewDidLoad()
        startSetting()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseDatabaseProject.ref.observe(.value) { [weak self] snapshot in
            var arrayStreetTwo = [Street]()
            for item in snapshot.children {
                guard let snapshot = item as? DataSnapshot,
                    let street = Street(snapshot: snapshot) else { continue }
                arrayStreetTwo.append(street)
            }
            self?.arrayStreet = arrayStreetTwo
            self?.tableView.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirebaseDatabaseProject.ref.removeAllObservers()
    }
    
    
    private func startSetting() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        
        view.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        view.addSubview(viewTop)
        setupViewTop()
        view.addSubview(tableView)
        setupTableView()
        
        view.addSubview(buttonAddCell)
        setupButton()
    }
    
    

    @objc func pressed(_ sender: UIButton) {
        let newStreetTask = Street(lable: "Название локации")
        arrayStreet.append(newStreetTask)
        let newSteet = FirebaseDatabaseProject.ref.child("location\(arrayStreet.count)")
        newSteet.setValue(newStreetTask.convertStreetDictionary())
    }
    
    func uploadImageFireStorege(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let storeRef = store.reference().child("photo").child(GetDate.time)
        guard let data = photo.jpegData(compressionQuality: 0.4) else { return }
        let metaDate = StorageMetadata()
        metaDate.contentType = "image/jpeg"

        storeRef.putData(data, metadata: metaDate) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            storeRef.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }


    func setupTableView() {
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: viewTop.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
   
    // кнопка addCell
    func setupButton() {
        buttonAddCell.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
        buttonAddCell.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
    }
    // верхняя часть
    func setupViewTop() {
        viewTop.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        viewTop.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        viewTop.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        viewTop.heightAnchor.constraint(equalToConstant: 150).isActive = true
        let imageTop = UIImageView()
        imageTop.image = #imageLiteral(resourceName: "logo")
        imageTop.translatesAutoresizingMaskIntoConstraints = false
        viewTop.addSubview(imageTop)
        imageTop.centerYAnchor.constraint(equalTo: viewTop.centerYAnchor).isActive = true
        imageTop.centerXAnchor.constraint(equalTo: viewTop.centerXAnchor).isActive = true
        let labelTop = UILabel()
        labelTop.text = "ЛОКАЦИИ"
        labelTop.textAlignment = .center
        labelTop.textColor = #colorLiteral(red: 0.1294117647, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
        labelTop.font = UIFont(name: "Oswald-Regular", size: 40)
        labelTop.translatesAutoresizingMaskIntoConstraints = false
        viewTop.addSubview(labelTop)
        labelTop.centerYAnchor.constraint(equalTo: viewTop.centerYAnchor).isActive = true
        labelTop.centerXAnchor.constraint(equalTo: viewTop.centerXAnchor).isActive = true
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayStreet.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! StreetTableViewCell
        
//        cell.delegate = self
        cell.indexStreet = indexPath.row
        let street = arrayStreet[indexPath.row]
        cell.oneIsStreet = street
        cell.textFieldMain.placeholder = street.lable
        
        if street.arrayImage.count >= 1 {
            cell.stackViewFive.isHidden = false
//            cell.collectionView.reloadData()
        } else {
            cell.stackViewFive.isHidden = true
//            cell.collectionView.reloadData()
        }
        return cell
    }
}
