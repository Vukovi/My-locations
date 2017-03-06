//
//  ViewController.swift
//  opet moje lokacije
//
//  Created by Vuk on 7/8/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PosećeneLokacije{
    var geografskaDužina: CLLocationDegrees
    var geografskaŠirina: CLLocationDegrees
    var ulica: String
    var broj: String
    init(geografskaDužina: CLLocationDegrees, geografskaŠirina: CLLocationDegrees, ulica: String, broj: String){
        self.geografskaDužina = geografskaDužina
        self.geografskaŠirina = geografskaŠirina
        self.ulica = ulica
        self.broj = broj
    }
}

var lokacije = [PosećeneLokacije]()

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    let menadzerLokacije = CLLocationManager()
    
    override func viewDidLoad() {
        //if NSUserDefaults.standardUserDefaults().objectForKey("lokacije") != nil {
        //lokacije = NSUserDefaults.standardUserDefaults().objectForKey("lokacije") as! [PosećeneLokacije]
        //}
        super.viewDidLoad()
        menadzerLokacije.delegate = self
        menadzerLokacije.desiredAccuracy = kCLLocationAccuracyBest
        
        if izabraniRedTabele == nil {
            menadzerLokacije.requestWhenInUseAuthorization()
            menadzerLokacije.startUpdatingLocation()
        }
        if izabraniRedTabele != nil{
            
            let gDužina: CLLocationDegrees = CLLocationDegrees(nizGeografskihDužina[izabraniRedTabele!])!
            let gŠirina: CLLocationDegrees = CLLocationDegrees(nizGeografskihŠirina[izabraniRedTabele!])!
            let mojaLokacija: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: gDužina, longitude: gŠirina)
            
            let zumGDužina: CLLocationDegrees = 0.01
            let zumGVisina: CLLocationDegrees = 0.01
            let zumiranje: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: zumGDužina, longitudeDelta: zumGVisina)
            
            let region: MKCoordinateRegion = MKCoordinateRegion(center: mojaLokacija, span: zumiranje)
            mapa.setRegion(region, animated: true)
            
            let ulicaLokaliteta = nizAdresaUlica[izabraniRedTabele!]
            let brojLokaliteta = nizAdresaBrojeva[izabraniRedTabele!]
            let marker = MKPointAnnotation()
            marker.coordinate = mojaLokacija
            marker.title = "\(ulicaLokaliteta) \(brojLokaliteta)"
            self.mapa.addAnnotation(marker) //zavrsio sam sa pravljenjem markera
            
        }
        
        let dugiStisak = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.pritisak(_:)))
        mapa.addGestureRecognizer(dugiStisak)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let korisnik: CLLocation = locations[0] 
        let gDužina: CLLocationDegrees = korisnik.coordinate.latitude
        let gŠirina: CLLocationDegrees = korisnik.coordinate.longitude
        let lokacija: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: gDužina, longitude: gŠirina)
        
        let zumGDužina: CLLocationDegrees = 0.01
        let zumGVisina: CLLocationDegrees = 0.01
        let zumiranje: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: zumGDužina, longitudeDelta: zumGVisina)
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: lokacija, span: zumiranje)
        mapa.setRegion(region, animated: true)
        
        
        let marker = MKPointAnnotation()
        CLGeocoder().reverseGeocodeLocation(korisnik, completionHandler: { (mojaMesta, greska) in
            var ulicaLokaliteta = ""
            var brojLokaliteta = ""
            if greska != nil {
                print("Nešto nije u redu sa lokacijom")
            }
            else{
                if let lokacije = mojaMesta?[0]{
                    if lokacije.subThoroughfare != nil {
                        brojLokaliteta = lokacije.subThoroughfare!
                    }
                    if lokacije.thoroughfare != nil {
                        ulicaLokaliteta = lokacije.thoroughfare!
                    }
                }
            }//ovde sam završio sa onim za šta mi Geocoder treba, a dalje koristim kložer da napravim marker i popunim tabelu
            
            
            
            marker.coordinate = lokacija
            if ulicaLokaliteta == "" && brojLokaliteta == ""{
                marker.title = String(describing: Date()) // ukoliko ne može da uhvati najbližu adresu, ispisaće datum kad je marker postavljen
            }
            else{
                marker.title = "\(ulicaLokaliteta) \(brojLokaliteta)"
            }
            self.mapa.addAnnotation(marker) //zavrsio sam sa pravljenjem markera
            
        })
    }
    
    var adresaBroj = ""
    var adresaUlica = ""
    var koordinata: CLLocationCoordinate2D?
    
    func pritisak(_ stisak: UILongPressGestureRecognizer){
        if stisak.state == UIGestureRecognizerState.began { // ovo je ubačeno jer je prilikom testiranja na jedan stisak 2X printovao STISNUTO
            stisak.minimumPressDuration = 2
            //print("Stisnuto")
            let pritisnutaTačka = stisak.location(in: mapa)
            //print("pritisnuta je tačka sa koordinatama X = \(pritisnutaTačka.x) i Y = \(pritisnutaTačka.y)")
            koordinata = mapa.convert(pritisnutaTačka, toCoordinateFrom: mapa)
            //print("pritisnuta je tačka sa geografskim koordinatama X = \(koordinata.latitude) i Y = \(koordinata.longitude)")
            let novaLokacija = CLLocation(latitude: koordinata!.latitude, longitude: koordinata!.longitude) // zato što Geocoder ne prihvata ni promenljivu KOORDINATA, ni CLLocationCoordinate2D, već isključivo CLLocation
            
            //pomoću Geocodera dobijam najbližu adresu, ali ću u njegovom kložeru ispisati i kod za ubacivanje novih lokacija u tabelu
            
            CLGeocoder().reverseGeocodeLocation(novaLokacija, completionHandler: { (mojaMesta, greska) in
                
                if greska != nil {
                    print("Nešto nije u redu sa lokacijom")
                }
                else{
                    if let lokacije = mojaMesta?[0]{
                        if lokacije.subThoroughfare != nil {
                            self.adresaBroj = lokacije.subThoroughfare!
                        }
                        if lokacije.thoroughfare != nil {
                            self.adresaUlica = lokacije.thoroughfare!
                        }
                    }
                }//ovde sam završio sa onim za šta mi Geocoder treba, a dalje koristim kložer da napravim marker i popunim tabelu
                
                
                let marker = MKPointAnnotation()
                marker.coordinate = self.koordinata!
                if self.adresaBroj == "" && self.adresaUlica == ""{
                    marker.title = String(describing: Date()) // ukoliko ne može da uhvati najbližu adresu, ispisaće datum kad je marker postavljen
                }
                else{
                    marker.title = "\(self.adresaUlica) \(self.adresaBroj)"
                }
                self.mapa.addAnnotation(marker) //zavrsio sam sa pravljenjem markera
                
                
                
                lokacije.append(PosećeneLokacije(geografskaDužina: self.koordinata!.latitude, geografskaŠirina: self.koordinata!.longitude, ulica: self.adresaUlica, broj: self.adresaBroj))
                
            })
        }
        
        
    }
    
}
//dodao bzvz
