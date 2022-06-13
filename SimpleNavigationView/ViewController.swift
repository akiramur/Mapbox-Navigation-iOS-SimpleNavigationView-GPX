//
//  ViewController.swift
//  SimpleNavigationView
//
//  Created by Akira Murao on 2022/05/20.
//

import UIKit
import MapboxDirections
import MapboxCoreNavigation
import MapboxMaps
import MapboxNavigation
import CoreLocation

class ViewController: UIViewController {
    
    let coordinates = [
        CLLocationCoordinate2D(latitude: 47.18714396691307, longitude: 27.564500233819288),
        CLLocationCoordinate2D(latitude: 47.18733343526054, longitude: 27.564257657289705),
        CLLocationCoordinate2D(latitude: 47.186476694193814, longitude: 27.563533460855684),
        CLLocationCoordinate2D(latitude: 47.18607201594545, longitude: 27.56264296746274),
        CLLocationCoordinate2D(latitude: 47.182431877449886, longitude: 27.565717449890503),
        CLLocationCoordinate2D(latitude: 47.17925426005481, longitude: 27.568436759360026)
    ]
    
    internal var mapView: MapView!
    
    var routeButton: UIButton!
    var matchedRouteButton: UIButton!
    var matchedRoute2Button: UIButton!
    var matchedRoute3Button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let styleURI = StyleURI(rawValue: "mapbox://styles/mapbox/streets-v11")
        let mapInitOptions = MapInitOptions(styleURI: styleURI)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        addRouteButton()
        addMatchedRouteButton()
        addMatchedRoute2Button()
        addMatchedRoute3Button()
        
        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            guard let self = self else {
                return
            }
            
            // Set the center coordinate and zoom level.
            guard let originCoordinate = self.coordinates.first, let destinationCoordinate = self.coordinates.last else {
                return
            }
            
            let camera = CameraOptions(center: originCoordinate, zoom: 12.0)
            self.mapView.mapboxMap.setCamera(to: camera)
            
            self.addPointAnnotations(coordinates: [originCoordinate, destinationCoordinate])
        }
        
    }
    
    // MARK: calculate route with waypoints
    
    private func addRouteButton() {
        routeButton = UIButton(frame: CGRect(x: 20, y: 100, width: 160, height: 50))
        routeButton.setTitle("Route", for: .normal)
        routeButton.backgroundColor = .blue
        routeButton.addTarget(self, action: #selector(routeButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(routeButton)
    }
    
    @objc func routeButtonTapped(sender: UIButton) {
        self.calculateRoute()
    }
    
    private func calculateRoute() {
        
        guard let originCoordinate = coordinates.first, let destinationCoordinate = coordinates.last else {
            return
        }
        
        // Define two waypoints to travel between
        let origin = Waypoint(coordinate: originCoordinate, name: "Origin")
        let destination = Waypoint(coordinate: destinationCoordinate, name: "Destination")
        
        // Set options
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination])
        
        // Request a route using MapboxDirections.swift
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let self = self else { return }
                
                // Pass the first generated route to the the NavigationViewController
                let viewController = NavigationViewController(for: response, routeIndex: 0, routeOptions: routeOptions)
                
                viewController.delegate = self
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: calculate matched route from geocoordinates
    
    private func addMatchedRouteButton() {
        matchedRouteButton = UIButton(frame: CGRect(x: 20, y: 200, width: 160, height: 50))
        matchedRouteButton.setTitle("Matched Route", for: .normal)
        matchedRouteButton.backgroundColor = .blue
        matchedRouteButton.addTarget(self, action: #selector(matchedRouteButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(matchedRouteButton)
    }
    
    @objc func matchedRouteButtonTapped(sender: UIButton) {
        self.calculateMatchedRoute()
    }
    
    private func calculateMatchedRoute() {

        let matchOptions = NavigationMatchOptions(coordinates: coordinates, profileIdentifier: .automobile)
        matchOptions.includesSteps = true
        matchOptions.waypointIndices = IndexSet([0, coordinates.count - 1])
        matchOptions.distanceMeasurementSystem = .metric

        Directions.shared.calculateRoutes(matching: matchOptions) { [weak self] (_, result) in
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let self = self else {
                    return
                }
                    
                guard let route = response.routes?.first, let _ = route.legs.first else {
                    return
                }
                
                let routeOptions = NavigationRouteOptions(navigationMatchOptions: matchOptions)
                                
                let viewController = NavigationViewController(for: response, routeIndex: 0, routeOptions: routeOptions, navigationOptions: NavigationOptions())
                                
                viewController.delegate = self
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: calculate matched route from geocoordinates 2
    
    private func addMatchedRoute2Button() {
        matchedRoute2Button = UIButton(frame: CGRect(x: 20, y: 300, width: 160, height: 50))
        matchedRoute2Button.setTitle("Matched Route 2", for: .normal)
        matchedRoute2Button.backgroundColor = .blue
        matchedRoute2Button.addTarget(self, action: #selector(matchedRoute2ButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(matchedRoute2Button)
    }
    
    @objc func matchedRoute2ButtonTapped(sender: UIButton) {
        self.calculateMatchedRoute2()
    }
    
    // use repsonse from calculateRoutes to create navigationService
    // This causes follwoing fatal error as soon as tried to start navigation
    //Fatal error: NavigationViewController(navigationService:) must recieve `navigationService` created with `RouteOptions`.
    private func calculateMatchedRoute2() {

        let matchOptions = NavigationMatchOptions(coordinates: coordinates, profileIdentifier: .automobile)
        matchOptions.includesSteps = true
        matchOptions.waypointIndices = IndexSet([0, coordinates.count - 1])
        matchOptions.distanceMeasurementSystem = .metric

        Directions.shared.calculateRoutes(matching: matchOptions) { [weak self] (_, result) in
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let self = self else {
                    return
                }
                    
                guard let route = response.routes?.first, let _ = route.legs.first else {
                    return
                }
                
                let routeOptions = NavigationRouteOptions(navigationMatchOptions: matchOptions)
                
                print("response.options: \(response.options)")

                let navigationService = MapboxNavigationService(
                    routeResponse: response,
                    routeIndex: 0,
                    routeOptions: routeOptions,
                    customRoutingProvider: NavigationSettings.shared.directions,
                    credentials: NavigationSettings.shared.directions.credentials,
                    simulating: .onPoorGPS)
                
                let viewController = NavigationViewController(navigationService: navigationService)
                viewController.delegate = self
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
                
                
                let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0)
                viewController.navigationService.router.updateRoute(with: indexedRouteResponse,
                                                                                    routeOptions: routeOptions,
                                                                                    completion: nil)
            }
        }
    }
    
    
    // MARK: calculate matched route from geocoordinates 3
    
    private func addMatchedRoute3Button() {
        matchedRoute3Button = UIButton(frame: CGRect(x: 20, y: 400, width: 160, height: 50))
        matchedRoute3Button.setTitle("Matched Route 3", for: .normal)
        matchedRoute3Button.backgroundColor = .blue
        matchedRoute3Button.addTarget(self, action: #selector(matchedRoute3ButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(matchedRoute3Button)
    }
    
    @objc func matchedRoute3ButtonTapped(sender: UIButton) {
        self.calculateMatchedRoute3()
    }
    
    // create routing response from match response wich is returned from calculateRoutes to navigationService
    // This causes follwoing fatal error as soon as tried to start navigation
    // Fatal error: NavigationViewController(navigationService:) must recieve `navigationService` created with `RouteOptions`.
    private func calculateMatchedRoute3() {

        let matchOptions = NavigationMatchOptions(coordinates: coordinates, profileIdentifier: .automobile)
        matchOptions.includesSteps = true
        matchOptions.waypointIndices = IndexSet([0, coordinates.count - 1])
        matchOptions.distanceMeasurementSystem = .metric

        Directions.shared.calculate(matchOptions) { [weak self] (_, result) in
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let matchResponse):
                guard let self = self else {
                    return
                }
                
                var routingResponse: RouteResponse?
                do {
                    routingResponse = try RouteResponse(matching: matchResponse, options: matchOptions, credentials: NavigationSettings.shared.directions.credentials)
                }
                catch {
                    print("try RouteResponse failed")
                }
                
                guard let response = routingResponse, let route = response.routes?.first, let _ = route.legs.first else {
                    return
                }
                
                let routeOptions = NavigationRouteOptions(navigationMatchOptions: matchOptions)
                
                print("response.options: \(response.options)")

                let navigationService = MapboxNavigationService(
                    routeResponse: response,
                    routeIndex: 0,
                    routeOptions: routeOptions,
                    customRoutingProvider: NavigationSettings.shared.directions,
                    credentials: NavigationSettings.shared.directions.credentials,
                    simulating: .onPoorGPS)
                
                let viewController = NavigationViewController(navigationService: navigationService)
                viewController.delegate = self
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
                
                
                let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0)
                viewController.navigationService.router.updateRoute(with: indexedRouteResponse,
                                                                                    routeOptions: routeOptions,
                                                                                    completion: nil)
            }
        }
    }
    
    // MARK: other private methods
    private func addPointAnnotations(coordinates: [CLLocationCoordinate2D]) {
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        
    var annotations: [PointAnnotation] = []
        for coordinate in coordinates {
            var annotation = PointAnnotation(coordinate: coordinate)
            annotation.image = .init(image: UIImage(named: "red_pin")!, name: "red_pin")
            
            annotations.append(annotation)
        }
        
        pointAnnotationManager.annotations = annotations
    }
}

extension ViewController: NavigationViewControllerDelegate {
    func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        print("distanceRemaining: \(progress.distanceRemaining)")
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, shouldRerouteFrom location: CLLocation) -> Bool {
        return false
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didRerouteAlong route: Route) {
        print("didRerouteAlong: \(route.description)")
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        return true
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, willRerouteFrom location: CLLocation?) {
        print("willRerouteFrom: \(location?.coordinate.longitude)")
    }
    
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        dismiss(animated: true, completion: nil)
    }
}
