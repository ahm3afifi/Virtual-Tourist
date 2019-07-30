//
//  TravelLocationMapViewController.swift
//  Virtual Tourist
//
//  Created by Ahmed Afifi on 7/28/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import MapKit
import UIKit
import CoreData

class TravelLocationMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var gestureRecognizer: UILongPressGestureRecognizer!
    
    var pin: Pin!
    var objectID: NSManagedObjectID!
    var objectToPass: NSManagedObject!
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    fileprivate func loadPins() {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
        
            var annotations = [MKPointAnnotation]()
        
            for object in fetchedObjects {
                
                let lat = CLLocationDegrees(object.latitude)
                let long = CLLocationDegrees(object.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                //create annotation
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotations.append(annotation)
            }
            
            //add annotation to map
            self.mapView.addAnnotations(annotations)
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        self.loadPins()
    }
    
    
    @IBAction func getTouchLocation(_ sender: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            
            //add map annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            //add annotation to map
            self.mapView.addAnnotation(annotation)
            
            //save pin and coordinate
            addPin(coordinate: coordinate)
        }
    }
    
    func addPin(coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        pin.id = String(arc4random())
        try! dataController.viewContext.save()
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.red
            pinView?.animatesDrop = false
        } else {
            pinView!.annotation = annotation
        }
         return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if checkForMatching(coordinate: view.annotation!.coordinate) {
            self.performSegue(withIdentifier: "showPhotoAlbum", sender: self)
        } else {
            print("can't segue")
            return
        }
    }
    
    func checkForMatching(coordinate: CLLocationCoordinate2D) -> Bool {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed to match pin location data: \(error.localizedDescription)")
        }
        
        if let savedPins = fetchedResultsController.fetchedObjects {
            for pin in savedPins {
                
                if pin.latitude == coordinate.latitude && pin.longitude == coordinate.longitude{
                    self.pin = pin
                    return true
                } else {
                    //print("numbers don't match")
                }
            }
        }
        return false
    }
    
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoAlbum" {
            let vc = segue.destination as? PhotoAlbumViewController
            let coordinate = self.mapView.selectedAnnotations[0].coordinate
            
            vc?.currentCoordinate = coordinate
            vc?.dataController = dataController
            vc?.objectID = self.objectID
            vc?.pin = self.pin
        }
    }
}
