//
//  RecipePuppyViewModel.swift
//  RecipePuppyChallenge
//
//  Created by Henry Savit on 8/21/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//


import Foundation
import RxSwift
import SwiftyJSON


class RecipePuppyViewModel {
    let disposeBag = DisposeBag()
    var recipes = Variable<[Recipe]>([])
    var searchText = Variable<String?>("")
    
    var failiureCounter = 0
    
    init() {
        searchText.asObservable()
            .subscribe({_ in
                
                //classic, iterative approach
//                self.getRecipes()
                
                // RxSwift approach
                self.get()
            })
            .disposed(by: disposeBag)
    }
    
    private func get() {
        RecipeAPI.getRecipes(with: "\(searchText.value ?? "" )")
            // Set 3 attempts to get response
            .retry(3)
            
            // BONUS
            // This is what a retry strategy would look like (if I could get it working)
//            .retryWhen(errors ->
//                errors
//                    .scan((errCount, err) -> {
//                        if (errCount > MAX_RETRIES)
//                        throw err;
//
//                        return errCount + 1;
//                        }, 0)
//                    .flatMap(
//                        retryCount -> Observable.timer((long) Math.pow(4, retryCount), TimeUnit.SECONDS)
//                )
//            )
            // Set 2 seconds timeout
            .timeout(2, scheduler: MainScheduler.instance)
            // Subscribe in background thread
//            .subscribeOn(backgroundWorkScheduler)
            // Observe in main thread
            .observeOn(MainScheduler.instance)
            // Subscribe on observer
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
    }
    
    private func getRecipes() {
        recipes.value.removeAll()
        
        guard searchText.value != nil && searchText.value != "" else {return}
        
        RecipeAPI.getRecipes(with: "\(searchText.value ?? "" )") { result in
            let object = JSON(result)
            for rs in object["results"] {
                let recipe = Recipe(json: rs.1)
                self.recipes.value.append(recipe)
            }
        }
    }
}
