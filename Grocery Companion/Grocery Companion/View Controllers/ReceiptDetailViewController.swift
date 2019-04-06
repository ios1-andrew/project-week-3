//
//  ReceiptDetailViewController.swift
//  Grocery Companion
//
//  Created by Andrew Dhan on 10/31/18.
//  Copyright © 2018 Andrew Dhan. All rights reserved.
//

import UIKit
import Vision
import SwiftOCR

class ReceiptDetailViewController: UIViewController, CameraPreviewViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transactionID = UUID()
        transactionController.clearLoadedItems()
        
        //TEST
        let testImages = [UIImage(named: "test-oranges" )!,UIImage(named: "test-produce")!, UIImage(named: "test-safeway")!]
        for image in testImages{
            swiftOCR.recognize(image) { recognizedString in
                print(recognizedString)
            }

        }
        
    }
    //MARK: - CameraPreviewViewControllerDelegate method
    
    func didFinishProcessingImage(image: UIImage) {
        let cgImage = image.cgImage!
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        
        let request = VNDetectTextRectanglesRequest(completionHandler: handleRectangles(request:error:))
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
        
    }
    //MARK: - IBActions
    
    @IBAction func addItem(_ sender: Any) {
        //TODO: change for auto population of nearby stores
        guard let storeText = storeTextField.text?.lowercased() else {return}
        self.store = storeText.contains("trader")
            ? StoreController.stores[StoreName.traderJoes.rawValue]
            : StoreController.stores[StoreName.wholeFoods.rawValue]
        
        guard let store = self.store,
            let dateString = dateTextField.text,
            let newItemName = addItemNameField.text,
            let newItemCostString = addItemCostField.text,
            let newItemCost = Double(newItemCostString),
            let date = dateString.toDate(withFormat: .short),
            let transactionID = transactionID else {return}
        
        transactionController.loadItems(name: newItemName, cost: newItemCost, store: store, date: date, transactionID: transactionID)
        addItemCostField.text = ""
        addItemNameField.text = ""
        tableView.reloadData()
    }
    
    @IBAction func submitReceipt(_ sender: Any) {
        guard let store = self.store,
            let dateString = dateTextField.text,
            let totalString = totalTextField.text,
            let total = Double(totalString),
            let date = dateString.toDate(withFormat: .short),
            let transactionID = transactionID else {return}
        
        transactionController.create(store: store, date: date, total: total, identifier: transactionID)
        
        let alertController = UIAlertController(title: "Success", message: "Your receipt has been successfully submitted", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.clearViewText()
            self.transactionID = UUID()
        }
        
        alertController.addAction(okAction)
        present(alertController,animated: true, completion: nil)
    }
    
    //processes VNTextObservation and run OCR on it
    private func handleRectangles(request: VNRequest, error: Error?){
        if let error = error {
            NSLog("Error handling request: \(error)")
            return
        }
        
        guard let results = request.results as? [VNTextObservation] else {
            return
        }
        
        print(results.count)
    }
    
    private func resultsToText() -> [DetectedText]{
        return []
    }
    //MARK: - UITableViewDelegate MEthods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionController.loadedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptItemCell", for: indexPath) as! ReceiptItemTableViewCell
        cell.transactionID = transactionID
        cell.groceryItem = transactionController.loadedItems[indexPath.row]
        
        return cell
    }
    
    //MARK: - Private Methods
    func clearViewText(){
        totalTextField.text = ""
        storeTextField.text = ""
        dateTextField.text = ""
        addItemNameField.text = ""
        addItemCostField.text = ""
        transactionController.clearLoadedItems()
        tableView.reloadData()
    }
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScanReceipt" {
            let destinationVC = segue.destination as! CameraPreviewViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    //MARK: - Properties
    private let swiftOCR = SwiftOCR()
    private var store: Store?
    private var transactionID: UUID?
    
    private let transactionController = TransactionController.shared
    private let groceryItemController = GroceryItemController.shared
    
    @IBOutlet weak var addItemNameField: UITextField!
    @IBOutlet weak var addItemCostField: UITextField!
    
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var storeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
}
