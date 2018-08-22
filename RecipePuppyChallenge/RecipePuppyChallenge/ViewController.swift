//
//  ViewController.swift
//  RecipePuppyChallenge
//
//  Created by Henry Savit on 8/21/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    private let recipePuppyViewModel = RecipePuppyViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar
            .rx
            .text // observable property
            .throttle(0.5, scheduler: MainScheduler.instance) // wait 0.5 seconds for changes
            .distinctUntilChanged() // check if the new value is the same as the old one
            .filter {
                if let chars = $0 {
                    return chars.count > 0
                }
                return false
            } // filter for a non-empty query
            .bind(to: recipePuppyViewModel.searchText)
            .disposed(by: disposeBag)
        
        recipePuppyViewModel.recipes.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "RecipeCell")) { (row, element, cell) in
                cell.textLabel?.text = self.recipePuppyViewModel.recipes.value[row].title
            }
            .disposed(by: disposeBag)
    }
}
