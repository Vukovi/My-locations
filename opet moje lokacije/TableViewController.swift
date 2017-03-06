//
//  TableViewController.swift
//  opet moje lokacije
//
//  Created by Vuk on 7/8/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

var izabraniRedTabele: Int?
var nizGeografskihDužina = [String]()
var nizGeografskihŠirina = [String]()
var nizAdresaUlica = [String]()
var nizAdresaBrojeva = [String]()

class TableViewController: UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nizGeografskihDužina.count == 0 {
            return 0
        }
        else{
            return nizGeografskihDužina.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mojaCelija", for: indexPath)
        if nizAdresaUlica[indexPath.row] != "" {
            cell.textLabel?.text = nizAdresaUlica[indexPath.row] + " " + nizAdresaBrojeva[indexPath.row]
        }
        else{
            cell.textLabel?.text = "Neznana lokacija!"
        }
        let dugoPritisnutaĆeliija = UILongPressGestureRecognizer(target: self, action: #selector(TableViewController.stisniĆeliju(_:)))
        cell.addGestureRecognizer(dugoPritisnutaĆeliija)


        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        izabraniRedTabele = indexPath.row
        return indexPath
    }
    
    var niz1 = [String]()
    var niz2 = [String]()
    func stisniĆeliju(_ prepoznaj:UILongPressGestureRecognizer){
        tableView.isUserInteractionEnabled = true
        if prepoznaj.state == UIGestureRecognizerState.began { //opet sam dobijao dve iste vrednosti za jedan dugi klik pa sam uveo ovo da se zna da mi treba jedna vrednost
            let tacka: CGPoint = prepoznaj.location(in: self.tableView)
            let mojIndeks = tableView.indexPathForRow(at: tacka)!
            let mojaTačka: String = "\(mojIndeks)"
            niz1 = mojaTačka.components(separatedBy: "{length = 2, path = 0 - ")
            niz2 = self.niz1[1].components(separatedBy: "}")
            let indeks = Int(niz2[0])
            let alert: UIAlertController = UIAlertController(title: "Potvrdite brisanje!", message: "Obrisati izabran red?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Da", style: .destructive, handler: { (UIAlertAction) -> Void in
                if lokacije.count > 0 {
                    lokacije.remove(at: indeks!)
                }
                nizGeografskihDužina.remove(at: indeks!)
                UserDefaults.standard.set(nizGeografskihDužina, forKey: "cuvajDuzine")
                nizGeografskihŠirina.remove(at: indeks!)
                UserDefaults.standard.set(nizGeografskihŠirina, forKey: "cuvajSirine")
                nizAdresaUlica.remove(at: indeks!)
                UserDefaults.standard.set(nizAdresaUlica, forKey: "cuvajUlice")
                nizAdresaBrojeva.remove(at: indeks!)
                UserDefaults.standard.set(nizAdresaBrojeva, forKey: "cuvajBrojeve")
                self.tableView.reloadData()
                //NSUserDefaults.standardUserDefaults().setObject(lokacije, forKey: "lokacije")
            }))
            alert.addAction(UIAlertAction(title: "Ne", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "trazi" {
            izabraniRedTabele = nil
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) { // ovo sam dodao da bi radila tabela
        if UserDefaults.standard.object(forKey: "cuvajDuzine") != nil {
            nizGeografskihDužina = UserDefaults.standard.object(forKey: "cuvajDuzine") as! [String]
        }
        if UserDefaults.standard.object(forKey: "cuvajSirine") != nil {
            nizGeografskihŠirina = UserDefaults.standard.object(forKey: "cuvajSirine") as! [String]
        }
        if UserDefaults.standard.object(forKey: "cuvajUlice") != nil {
            nizAdresaUlica = UserDefaults.standard.object(forKey: "cuvajUlice") as! [String]
        }
        if UserDefaults.standard.object(forKey: "cuvajBrojeve") != nil {
            nizAdresaBrojeva = UserDefaults.standard.object(forKey: "cuvajBrojeve") as! [String]
        }
        if lokacije.count > 0 {
            for i in 0...lokacije.count - 1 {
                nizGeografskihDužina.append("\(lokacije[i].geografskaDužina)")
                UserDefaults.standard.set(nizGeografskihDužina, forKey: "cuvajDuzine")
                nizGeografskihŠirina.append("\(lokacije[i].geografskaŠirina)")
                UserDefaults.standard.set(nizGeografskihŠirina, forKey: "cuvajSirine")
                nizAdresaUlica.append("\(lokacije[i].ulica)")
                UserDefaults.standard.set(nizAdresaUlica, forKey: "cuvajUlice")
                nizAdresaBrojeva.append("\(lokacije[i].broj)")
                UserDefaults.standard.set(nizAdresaBrojeva, forKey: "cuvajBrojeve")
                
            }
        }
        print(nizGeografskihDužina)
        print(nizGeografskihŠirina)
        print(nizAdresaUlica)
        print(nizAdresaBrojeva)
        tableView.reloadData()
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */

}
