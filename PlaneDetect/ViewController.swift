//
//  ViewController.swift
//  PlaneDetect
//
//  Created by Nien Lam on 10/8/20.
//

import UIKit
import ARKit
import RealityKit
import Combine
import AVFoundation

class ViewController: UIViewController {

    
    @IBOutlet weak var myARView: ARView!
    
    //@IBOutlet weak var interfaceView: InterfaceView!
    // Outlet to label.
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var Label2: UILabel!
    
    @IBOutlet weak var OneDesc: UIImageView!
    @IBOutlet weak var TwoDesc: UIImageView!
    @IBOutlet weak var ThreeDesc: UIImageView!
    // Outlet to test button.
    //@IBOutlet weak var frogbutton1: UIButton!
    @IBOutlet weak var frogbutton2: UIButton!
    @IBOutlet weak var frogbutton3: UIButton!
    @IBOutlet weak var frogbuton1: UIButton!
    
    // Root entity of Reality Composer Scene.
    var myEntities: Entity!
    
    // Anchor at position [0, 0, 0].
    var originAnchor: AnchorEntity!

    // Anchor tracks camera point of view.
    var cameraAnchor: AnchorEntity!
    
    var frog1speak = AVAudioPlayer()
    var frog2speak = AVAudioPlayer()
    var frog3speak = AVAudioPlayer()

    // Cursor entity on horizontal or vertical surfaces.
    var cursor: Entity!
    
    var theFrog: Entity!
    var theBox: Entity!
    
    var FrogOne: Entity!
    var FrogTwo: Entity!
    var FrogThree: Entity!
    var FrogOnea: Entity!
    var FrogTwoa: Entity!
    var FrogThreea: Entity!
    
    // For callback methods.
    var subscriptions = Set<AnyCancellable>()

    // Counter variable.
    var counter: Int = 0
    var counter1: Int = 0
    var counter2: Int = 0
    var counter3: Int = 0
    var tNum = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sound = Bundle.main.path(forResource: "frog1sound", ofType: "mp3")
        do {
            frog1speak = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        }
        catch{
            print(error)
        }
        let sound2 = Bundle.main.path(forResource: "frog2sound", ofType: "mp3")
        do {
            frog2speak = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound2!))
        }
        catch{
            print(error)
        }
        let sound3 = Bundle.main.path(forResource: "frog3sound", ofType: "mp3")
        do {
            frog3speak = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound3!))
        }
        catch{
            print(error)
        }
        
        // Load root entity from Reality Composer Project.
        myEntities = try! Experience.loadMyEntities()
        
        // Create and add origin anchor.
        originAnchor = AnchorEntity(world: float4x4(1))
        myARView.scene.addAnchor(originAnchor)
        
        // Create and add camera anchor.
        cameraAnchor = AnchorEntity(.camera)
        myARView.scene.addAnchor(cameraAnchor)

        // Add cursor. Tracks on horizontal and vertical planes.
        cursor = Guides.makeCursor()
        originAnchor.addChild(cursor)
        
        // Called every frame.
        myARView.scene.subscribe(to: SceneEvents.Update.self) { event in
            // Update cursor position.
            self.updateCursor()
        }.store(in: &subscriptions)

        // Setup tap gesture for entire screen.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        myARView.addGestureRecognizer(tapGesture)
        
        myLabel.isHidden=true;
        OneDesc.isHidden=true;
        TwoDesc.isHidden=true;
        ThreeDesc.isHidden=true;
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Running on device.
        #if !targetEnvironment(simulator)
            let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        //configuration.planeDetection = .vertical
            myARView.session.run(configuration)
        #endif
    }

    private func updateCursor() {
        // Raycast to get cursor position.
        let results = myARView.raycast(from: self.view.center,
                                       allowing: .existingPlaneGeometry,
                                       alignment: .any)
            
        // Move cursor to position if hitting plane.
        if let result = results.first {
            cursor.isEnabled = true
            cursor.move(to: result.worldTransform, relativeTo: originAnchor)
        } else {
            cursor.isEnabled = false
        }
    }

    ////////
    // Called when tapped anywhere on the screen.
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        let touchInView = sender.location(in: self.myARView)

        if let hitEntity = self.myARView.entity(at: touchInView) {
            print("➡️ TAPPED A ENTITY:", hitEntity.parent!.name)
            // Set label to entity name.
            //myLabel.text = hitEntity.parent!.name
            //myLabel.text = hitEntity.name
            //so depending on what the entities are called you can call specific things
            if (hitEntity.parent!.name == "redeyedtreefrog1" || hitEntity.parent!.name == "redeyedtreefrog_alt1") {
                frog1speak.play();
                TwoDesc.isHidden=true;
                ThreeDesc.isHidden=true;
                OneDesc.isHidden=false;
            }
            if (hitEntity.parent!.name == "australiantreefrog1" || hitEntity.parent!.name == "australiantreefrogalt1") {
                frog2speak.play();
                OneDesc.isHidden=true;
                ThreeDesc.isHidden=true;
                TwoDesc.isHidden=false;
            }
            if (hitEntity.parent!.name == "graytreefrog1" || hitEntity.parent!.name == "graytreefrog_alt1") {
                frog3speak.play();
                OneDesc.isHidden=true;
                TwoDesc.isHidden=true;
                ThreeDesc.isHidden=false;
            }
            
            myLabel.isHidden=true;
        }
    }

    ////////
 
    @IBAction func didTapfro1(_ sender: Any) {
        print("➡️ TAPPED FROG 1")
        let randomint1 = Int.random(in: 0..<2)
        if (randomint1 == 0) {
            let RETFrog = myEntities.findEntity(named: "FrogOne")!.clone(recursive: true)
            RETFrog.transform.translation = [0,0,0]
            // Append counter number to name.
            RETFrog.name = "MyClonedFrog1_" + "\(counter1)"
            
            // IMPORTANT: Need to set so hit detection works.
            RETFrog.generateCollisionShapes(recursive: true)
            
            // Move frog to cursor.
            RETFrog.transform.matrix = cursor.transformMatrix(relativeTo: originAnchor)
            // Add frog to origin anchor.
            originAnchor.addChild(RETFrog)
        }
        else{
            let RETFrog = myEntities.findEntity(named: "FrogOnea")!.clone(recursive: true)
            RETFrog.transform.translation = [0,0,0]
            // Append counter number to name.
            RETFrog.name = "MyClonedFrog1_" + "\(counter1)"
            
            // IMPORTANT: Need to set so hit detection works.
            RETFrog.generateCollisionShapes(recursive: true)
            
            // Move frog to cursor.
            RETFrog.transform.matrix = cursor.transformMatrix(relativeTo: originAnchor)
            // Add frog to origin anchor.
            originAnchor.addChild(RETFrog)
        }
        if (counter1 == 0 && counter2 == 0 && counter3 == 0) {
            myLabel.isHidden=false;
        }
        
        // Increment counter.
        counter1 += 1
    }
    
    @IBAction func didTapfrog2(_ sender: Any) {
        print("➡️ TAPPED FROG 2")
        let randomint2 = Int.random(in: 0..<2)
        if (randomint2 == 0) {
            let AGTFrog = myEntities.findEntity(named: "FrogTwo")!.clone(recursive: true)
            AGTFrog.transform.translation = [0,0,0]
            // Append counter number to name.
            AGTFrog.name = "MyClonedFrog2_" + "\(counter2)"
            
            // IMPORTANT: Need to set so hit detection works.
            AGTFrog.generateCollisionShapes(recursive: true)
            
            // Move frog to cursor.
            AGTFrog.transform.matrix = cursor.transformMatrix(relativeTo: originAnchor)
            // Add frog to origin anchor.
            originAnchor.addChild(AGTFrog)
//            let radians = -Float.pi / 2
//            AGTFrog.transform.rotation = simd_quatf(angle: radians, axis: [0,1,0])
        }
        else{
            let AGTFrog = myEntities.findEntity(named: "FrogTwoa")!.clone(recursive: true)
            AGTFrog.transform.translation = [0,0,0]
            AGTFrog.name = "MyClonedFrog2_" + "\(counter2)"
            AGTFrog.generateCollisionShapes(recursive: true)
            AGTFrog.transform.matrix = cursor.transformMatrix(relativeTo: originAnchor)
            originAnchor.addChild(AGTFrog)
//            let radians = -Float.pi / 2
//            AGTFrog.transform.rotation = simd_quatf(angle: radians, axis: [0,1,0])
        }
        
        if (counter1 == 0 && counter2 == 0 && counter3 == 0) {
            myLabel.isHidden=false;
        }
        
        // Increment counter.
        counter2 += 1
    }
    @IBAction func didTapfrog3(_ sender: Any) {
        print("➡️ TAPPED FROG 3")
        let randomint3 = Int.random(in: 0..<2)
        if (randomint3 == 0) {
            let GTFrog = myEntities.findEntity(named: "FrogThree")!.clone(recursive: true)
            GTFrog.transform.translation = [0,0,0]
            // Append counter number to name.
            GTFrog.name = "MyClonedFrog3_" + "\(counter3)"
            
            // IMPORTANT: Need to set so hit detection works.
            GTFrog.generateCollisionShapes(recursive: true)
            
            // Move frog to cursor.
            GTFrog.transform.matrix = cursor.transformMatrix(relativeTo: originAnchor)
            // Add frog to origin anchor.
            originAnchor.addChild(GTFrog)
//            let radians = -Float.pi / 2
//            GTFrog.transform.rotation = simd_quatf(angle: radians, axis: [0,1,0])
        }
        else{
            let GTFrog = myEntities.findEntity(named: "FrogThreea")!.clone(recursive: true)
            GTFrog.transform.translation = [0,0,0]
            GTFrog.name = "MyClonedFrog3_" + "\(counter3)"
            GTFrog.generateCollisionShapes(recursive: true)
            GTFrog.transform.matrix = cursor.transformMatrix(relativeTo: originAnchor)
            originAnchor.addChild(GTFrog)
//            let radians = -Float.pi / 2
//            GTFrog.transform.rotation = simd_quatf(angle: radians, axis: [0,1,0])
        }
        if (counter1 == 0 && counter2 == 0 && counter3 == 0) {
            myLabel.isHidden=false;
        }
        
        // Increment counter.
        counter3 += 1
    }

}
