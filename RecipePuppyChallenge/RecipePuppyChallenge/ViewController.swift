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
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()

    var recipes = Variable<[Recipe]>([])

    private func getStuff(text: String?) -> Observable<AnyObject> {
        return RecipeAPI.getRecipes(with: "\(text ?? "" )")
            // BONUS
            // This is what a retry strategy would look like (if I could get it working)
//            .retryWhen(errors ->
//                errors
//                    .scan((errCount, err) -> {
//                        if (errCount > MAX_RETRIES)
//                            throw err
//
//                        return errCount + 1
//                        }, 0)
//                    .flatMap(
//                        retryCount -> Observable.timer((long) Math.pow(4, retryCount), TimeUnit.SECONDS)
//                )
//            )
            // Observe in main thread
            .observeOn(MainScheduler.instance)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        searchBar
            .rx
            .text // observable property
            .debounce(0.5, scheduler: MainScheduler.instance) // wait 0.5 seconds for changes
            .filter {
                if let chars = $0 {
                    return chars.count > 0
                }
                return false
            } // filter for a non-empty query
            .flatMapLatest({ (string: String?) -> Observable<AnyObject> in
                self.getStuff(text: string)
            })
//            .bind(to: self.tableView.rx.items(cellIdentifier: "RecipeCell")) { (row, element, cell) in
//
//                cell.textLabel?.text = self.recipes.value[row].title
//            }
            .subscribe(
                onNext: { data in
                    self.recipes.value = []
                    let object = JSON(data)
                    for rs in object["results"] {
                        let recipe = Recipe(json: rs.1)
                        self.recipes.value.append(recipe)
                    }
                },
                onError: { error in
                    
                    //retry on timeout
                    print(error)
                    
                    // show error in top cell
                    self.recipes.value = []
                    let recipe = Recipe.init(title: "ERROR GETTING RESULTS")
                    self.recipes.value.append(recipe)
                },
                onCompleted: {
                    print("Completed")
                },
                onDisposed: {
                    print("Disposed")
                }
            )
            .disposed(by: disposeBag)
        
        self.recipes.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "RecipeCell")) { (row, element, cell) in
                cell.textLabel?.text = self.recipes.value[row].title
            }
            .disposed(by: disposeBag)
    }
}
