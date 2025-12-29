import SwiftUI
import MapKit
import CoreLocation
internal import Combine

struct DeliveryMapView: View {
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Delivery Map")
                .font(.largeTitle.bold())
            
            Text("Tap on the map to select your delivery location.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            MapView(coordinate: $selectedCoordinate, region: $region)
                .frame(maxWidth: .infinity, maxHeight: 300)
                .cornerRadius(16)
            
            if let coordinate = selectedCoordinate {
                Text("Selected: \(coordinate.latitude), \(coordinate.longitude)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button {
                if let coordinate = selectedCoordinate {
                    print("Confirmed location: \(coordinate.latitude), \(coordinate.longitude)")
                    // TODO: Pass this coordinate back to your checkout flow
                }
            } label: {
                Text("Confirm Location")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Delivery Map")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(locationManager.$userLocation) { location in
            if let location = location {
                // Update map region to user's location
                region.center = location.coordinate
            }
        }
    }
}

// MARK: - MapView using UIViewRepresentable
struct MapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D?
    @Binding var region: MKCoordinateRegion
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.setRegion(region, animated: false)
        
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
        map.addGestureRecognizer(gesture)
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        
        if let coordinate = coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            uiView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) { self.parent = parent }
        
        @objc func mapTapped(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coord = mapView.convert(point, toCoordinateFrom: mapView)
            parent.coordinate = coord
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location
            manager.stopUpdatingLocation() // Stop updates to save battery
        }
    }
}
