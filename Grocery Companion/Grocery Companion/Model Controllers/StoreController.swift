//
//  StoreController.swift
//  Grocery Companion
//
//  Created by Andrew Dhan on 11/1/18.
//  Copyright © 2018 Andrew Liao. All rights reserved.
//

import Foundation

//temporary enum before incorporating Yelp API

enum StoreName: Int{
    case traderJoes = 0
    case wholeFoods = 1
}

class StoreController{
    static let shared = StoreController()
    //MARK: - Methods
    func bestStoreToBuyItems(_ items: [GroceryItem]) -> [Store]{
        guard !items.isEmpty else {return [Store]()}
        
        //Creates an array of Stores by running cheapestPlaceToBuy on each item in items
        let bestPriceFrequency = items.compactMap{ $0.cheapestPlaceToBuy() }
        guard !bestPriceFrequency.isEmpty else {return [Store]()}
        
        //Creates an directory where key is the store and value is the frequency of appearance in bestPriceFrequency
        var lowPriceDirectory = [Store:Int]()
        bestPriceFrequency.forEach{lowPriceDirectory[$0] = (lowPriceDirectory[$0] ?? 0) + 1}
        //Convert directory to a sorted array of tuples
        let lowPriceTuples = lowPriceDirectory.convertToTupleArray().sorted {$0.1 > $1.1}
        
        //Create an array of stores containing stores with the heighest frequency. All stores in array will have same frequency
        let highestFrequency = lowPriceTuples.first!.1
        return lowPriceTuples.compactMap{ $0.1 == highestFrequency ? $0.0 : nil}
    }
    
    func estimatedCostForGroceries(store: Store, items: [GroceryItem]) -> Double {
        //$0 is result, $1 is groceryItem
        return 0.0
    }
    
    //MARK: - Properties
    static let stores =
        [Store(name: "Trader Joe's", latitude:37.790780, longitude:-122.418039),
         Store(name: "Whole Foods", latitude:37.781130,longitude:-122.399671)]
}
