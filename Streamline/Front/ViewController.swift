//
//  ViewController.swift
//  Streamline
//
//  Created by Xuezheng Wang on 7/26/19.
//  Copyright © 2019 Xuezheng Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - IB Property references
    @IBOutlet private weak var boardView: BoardView!
    @IBOutlet private weak var headView: Head!
    
    // MARK: - Customize variables
    var headLocation = BoardLocation(row: 0, col: 0)
    var headSize: CGFloat = 30.0 // width and height of the head
    
    var trails: [Trail] = []
    var trailWidth: CGFloat = 15.0
    
    private let ANIMATION_DURATION: Double = 0.2
    private let DAMPING_RATIO: CGFloat = 0.7

    
    
    // MARK: - View life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        boardView.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        moveHead(to: BoardLocation(row: 0, col: 0))
    }
    
    
    // MARK: - User actions
    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            //Get the tile that was tapped on
            var tappedTile: TileView? = nil
            
            let tappedLocation = sender.location(in: boardView)
            outerLoop: for row in boardView.tiles {
                for tile in row {
                    if tile.frame.contains(tappedLocation) {
                        tappedTile = tile
                        break outerLoop
                    }
                }
            }
            
            if let tile = tappedTile {
                print(advance(to: tile.location!))
            }
        }
    }
    
    // An button designed to test stuff.
    @IBAction func handleTest(_ sender: UIButton) {
        print(undo())
    }
    

    
    // MARK: - UI Actions
    
    // This is only for testing
    func setOrigin(at location: BoardLocation) {
        boardView.setColor(of: location, to: boardView.originColor)
        boardView.getTileView(at: location).type = .origin
    }
    
    
    // Move head with trail
    // MARK: Major useful function to be called
    func advance(to location: BoardLocation) -> Bool{
        // Check if this move is valid
        
        if pendingAnimation {
            return false
        }
        
        if let thisTrail = createTrail(from: headLocation, to: location) {
            pendingAnimation = true
            
            UIView.animate(withDuration: ANIMATION_DURATION, delay: 0.0, usingSpringWithDamping: DAMPING_RATIO, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
                // Animations
                self.moveHead(to: location)
                thisTrail.frame = thisTrail.targetRect!
            }, completion: { _ in
                self.pendingAnimation = false
            })
            
            return true
        } else {
            return false
        }
    }
    
    // move the headView to the given boardLocation. Everything is taken care of.
    private func moveHead(to location: BoardLocation){
        // Just move the head
        headLocation = location
        
        // A bit of math first
        let theTileFrame = boardView.getTileView(at: location).frame
        let x = theTileFrame.minX + theTileFrame.width / 2 - headSize / 2
        let y = theTileFrame.minY + theTileFrame.height / 2 - headSize / 2
        
        // Move the head
        let rect = CGRect(x: x, y: y, width: headSize, height: headSize)
        headView.frame = rect
        
        // Bring it to the front
        boardView.bringSubviewToFront(headView)
        boardView.setNeedsDisplay()
    }
    
    // Create a trail. true means success, false means the given params are illegal
    private func createTrail(from start: BoardLocation, to end: BoardLocation) -> Trail? {
        // Check if the trail is horizontal or vertical
        if start.row == end.row {
            // Horizontal
            var leftTileFrame: CGRect?
            var rightTileFrame: CGRect?
            var willReverseAnimate = false
            
            if start.column < end.column {
                leftTileFrame = boardView.getTileView(at: start).frame
                rightTileFrame = boardView.getTileView(at: end).frame
            } else if start.column > end.column {
                leftTileFrame = boardView.getTileView(at: end).frame
                rightTileFrame = boardView.getTileView(at: start).frame
                
                willReverseAnimate = true
            } else {
                // start and end are the same tile! no way!
                return nil
            }
            
            // Math time!
            let x: CGFloat = leftTileFrame!.minX + leftTileFrame!.width / 2 - trailWidth / 2
            let y: CGFloat = leftTileFrame!.minY + leftTileFrame!.width / 2 - trailWidth / 2
            let width: CGFloat = rightTileFrame!.maxX - rightTileFrame!.width / 2 + trailWidth / 2 - x
            
            // will animate from initRect to targetRect
            let targetRect = CGRect(x: x, y: y, width: width, height: trailWidth)
            var initRect = CGRect(x: x, y: y, width: trailWidth, height: trailWidth)
            
            if willReverseAnimate {
                initRect = CGRect(x: width + x - trailWidth, y: y, width: trailWidth, height: trailWidth)
            }
            
            // Setup the new trail
            let newTrail = Trail(frame: initRect)
            newTrail.initRect = initRect
            newTrail.targetRect = targetRect
            newTrail.startLocation = start
            newTrail.endLocation = end
            
            trails.append(newTrail)
            boardView.addSubview(newTrail)

            
            return newTrail
            
        } else if start.column == end.column {
            // Vertical
            var topTileFrame: CGRect?
            var bottomTileFrame: CGRect?
            
            var willReverseAnimate = false
            
            print("Called!")
            
            if start.row > end.row {
                topTileFrame = boardView.getTileView(at: end).frame
                bottomTileFrame = boardView.getTileView(at: start).frame
                
                willReverseAnimate = true
            } else if start.row < end.row {
                topTileFrame = boardView.getTileView(at: start).frame
                bottomTileFrame = boardView.getTileView(at: end).frame
            } else {
                // start and end are the same tile! no way!
                return nil
            }
            
            // Math time!
            let x: CGFloat = topTileFrame!.minX + topTileFrame!.width / 2 - trailWidth / 2
            let y: CGFloat = topTileFrame!.minY + topTileFrame!.height / 2 - trailWidth / 2
            let height: CGFloat = bottomTileFrame!.maxY - bottomTileFrame!.height / 2 + trailWidth / 2 - y
            
            // calculate initRect and targetRect
            var initRect = CGRect(x: x, y: y, width: trailWidth, height: trailWidth)
            let targetRect = CGRect(x: x, y: y, width: trailWidth, height: height)
            
            if willReverseAnimate {
                initRect = CGRect(x: x, y: y + height - trailWidth, width: trailWidth, height: trailWidth)
            }
            
            // Setup the newTrail
            let newTrail = Trail(frame: initRect)
            newTrail.targetRect = targetRect
            newTrail.initRect = initRect
            newTrail.startLocation = start
            newTrail.endLocation = end
            
            // Add this trail to subview and the array
            trails.append(newTrail)
            boardView.addSubview(newTrail)
            
            return newTrail
        } else {
            // Not on the same row nor columns
            return nil
        }
    }
    
    
    
    // Undo the last movement
    // Return Value: Whether the undo was a success
    func undo() -> Bool {
        
        // Safe check if animation is in process
        if pendingAnimation {
            return false
        }
        
        // If there's another trail, then we can redo it
        if let lastTrail = trails.last {
            let undoLocation = lastTrail.startLocation
            
            // Animate the going back movement
            pendingAnimation = true            
            
            UIView.animate(withDuration: ANIMATION_DURATION, delay: 0.0, usingSpringWithDamping: DAMPING_RATIO, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
                // Animation actions
                self.moveHead(to: undoLocation!)
                lastTrail.frame = lastTrail.initRect!
            }, completion: { success in
                // Completion code
                if success {
                    self.trails.removeLast()
                    lastTrail.removeFromSuperview()
                }
                self.pendingAnimation = false
            })
            return true
        }
        
        return false
    }
    
    var pendingAnimation = false
    
    
}
