//
//  FilterViewController.swift
//  FilterColor
//
//  Created by Vivek Patel on 08/07/24.
//

import UIKit
class FilterViewController: UIViewController {
    
    var selectedImage: UIImage?
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    let filterNames = ["Original", "Custom"]
    var filteredImages: [UIImage] = []
    
    var arrFilters :  [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedImage == nil {
            selectedImage = UIImage(named: "MI")
        }
        imageView.image = selectedImage
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        readJsonFile() // Load filters from JSON
        applyFilters() // Apply filters based on JSON data
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func readJsonFile()  {
        if let path = Bundle.main.path(forResource: "BCPCITYLIGHTSPARIS", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String:Any]{
                    if let arrFilters = jsonResult["filters"] as? [[String:Any]]{
                        self.arrFilters.append(contentsOf: arrFilters)
                    }
                }
            } catch {
                // handle error
            }
        }
    }
    
    func applyFilters() {
        guard let ciImage = CIImage(image: selectedImage!) else { return }
        let imageScale = selectedImage?.scale ?? 1.0
            let imageOrientation = selectedImage?.imageOrientation ?? .up
        filteredImages = filterNames.compactMap { filterName in
            if filterName == "Original" {
                return selectedImage ?? UIImage(named: "")!
            } else if filterName == "Custom" {
                // Apply custom filters
                let filteredCIImage = applyCustomFilters(to: ciImage)
                return filteredCIImage.flatMap { UIImage(ciImage: $0, scale: imageScale, orientation: imageOrientation) }
            } else {
                return nil
            }
        }
        collectionView.reloadData()
    }
    
    func applyCustomFilters(to image: CIImage) -> CIImage? {
        var filteredImage: CIImage? = image
        
        for filter in arrFilters {
            let filterKey = filter["key"] as? String
            let filterParams = filter["parameters"] as? [[String: Any]]
            
            switch filterKey {
            case "CIExposureAdjust":
                let value = filterParams?.first?["val"] as? Double
                let imgFilter = CIFilter(name: "CIExposureAdjust")
                imgFilter?.setValue(value, forKey: kCIInputEVKey)
                filteredImage = apply(imgFilter, for: CIImage.init(image: selectedImage!)!)
            case "SaturationFilter":
                let value = filterParams?.first?["val"] as? Double
                let imgFilter = CIFilter(name: "CIColorControls")
                imgFilter?.setValue(value, forKey: kCIInputSaturationKey)
                filteredImage = apply(imgFilter, for: filteredImage!)
            case "CISharpenLuminance":
                let value = filterParams?.first?["val"] as? Double
                let imgFilter = CIFilter(name: "CISharpenLuminance")
                imgFilter?.setValue(value, forKey: kCIInputSharpnessKey)
                filteredImage = apply(imgFilter, for: filteredImage!)
            case "CIHighlightShadowAdjust":
                let imgFilter = CIFilter(name: "CIHighlightShadowAdjust")
                for filterValue in filterParams! {
                    if let key = filterValue["key"] as? String, let inputShadow = filterValue["val"] as? Double {
                        imgFilter?.setValue(inputShadow, forKey: key)
                    }
                }
                filteredImage = apply(imgFilter, for: filteredImage!)
            case "CIToneCurve":
                let imgFilter = CIFilter(name: "CIToneCurve")
                for filterValue in filterParams! {
                    if let valuesOfVector = filterValue["val"] as? [Double], let key = filterValue["key"] as? String {
                        let vector = CIVector(x: CGFloat(valuesOfVector.first!), y: CGFloat(valuesOfVector.last!))
                        imgFilter?.setValue(vector, forKey: key)
                    }
                }
                filteredImage = apply(imgFilter, for: filteredImage!)
            case "MultiBandHSV":
                let imgFilter = MultiBandHSV() // Ensure this filter is defined and imported
                for filterValue in filterParams! {
                    if let valuesOfVector = filterValue["val"] as? [CGFloat], let key = filterValue["key"] as? String {
                        let vector = CIVector(x: valuesOfVector.first!, y: valuesOfVector[1], z: valuesOfVector.last!)
                        imgFilter.setValue(vector, forKey: key)
                    }
                }
                filteredImage = apply(imgFilter, for: filteredImage!)
            default:
                break
            }
        }
        
        return filteredImage
    }
    
    func apply(_ filter: CIFilter?, for image: CIImage) -> CIImage {
        guard let filter = filter else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        guard let filteredImage = filter.value(forKey: kCIOutputImageKey) else { return image }
        return filteredImage as! CIImage
    }
    
    func CIExposureAdjustFilter(beginImage:CIImage, value:Double) ->  CIImage{
        let filter = CIFilter(name: "CIUnsharpMask")
        filter?.setValue(beginImage, forKey: kCIInputImageKey)
        filter?.setValue(2.0, forKey: "inputIntensity")
        filter?.setValue(1.0, forKey: "inputRadius")
        return (filter?.outputImage)!
    }
    
}

extension FilterViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImagePreviewCollectionViewCell
        cell.previewImageView.image = filteredImages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilteredImage = filteredImages[indexPath.item]
        imageView.image = selectedFilteredImage
    }
    
}

