//
//  TestAnnotationView.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 30/04/15.
//  Copyright (c) 2015 Danijel Huis. All rights reserved.
//

import UIKit

open class TestAnnotationView: ARAnnotationView, UIGestureRecognizerDelegate
{
    open var titleLabel: UILabel?
    open var infoButton: UIButton?

    override open func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        if self.titleLabel == nil
        {
            self.loadUi()
        }
    }
    
    func loadUi()
    {
        // Title label
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        // Info button
        self.infoButton?.removeFromSuperview()
        let button = UIButton(type: UIButtonType.detailDisclosure)
        button.isUserInteractionEnabled = false   // Whole view will be tappable, using it for appearance
        self.addSubview(button)
        self.infoButton = button
        
        // Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TestAnnotationView.tapGesture))
        self.addGestureRecognizer(tapGesture)
        
        // Other
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.layer.cornerRadius = 5
        
        if self.annotation != nil
        {
            self.bindUi()
        }
    }
    
    func layoutUi()
    {
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40
        
        self.titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width - buttonWidth - 5, height: self.frame.size.height);
        self.infoButton?.frame = CGRect(x: self.frame.size.width - buttonWidth, y: self.frame.size.height/2 - buttonHeight/2, width: buttonWidth, height: buttonHeight);
    }
    
    // This method is called whenever distance/azimuth is set
    override open func bindUi()
    {
        if let annotation = self.annotation, let title = annotation.title
        {
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1fkm", annotation.distanceFromUser / 1000) : String(format:"%.0fm", annotation.distanceFromUser)
            
            let text = String(format: "%@\nAZ: %.0f°\nDST: %@", title, annotation.azimuth, distance)
            self.titleLabel?.text = text
        }
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        self.layoutUi()
    }
    
    open func tapGesture()
    {
        if let annotation = self.annotation
        {
            
            
            let alertView = UIAlertView(title: annotation.title!, message: annotation.message!, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "Report")
            alertView.show()
 
            /*
             let alert = UIAlertController(title: annotation.title!, message: annotation.message!, preferredStyle: UIAlertControllerStyle.alert)
             let action1 = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
             let action2 = UIAlertAction(title: "Report", style: UIAlertActionStyle.default) { (action) in
             // Do something here when action was pressed
             }
             
             alert.addAction(action1)
             alert.addAction(action2)
            
            self.present(alert, animated: true, completion: nil)*/
             //alert.present(alert, animated: true, completion: nil)
            //alert.show()
            
            ////////////
            /*
           let alertController = UIAlertController(title: NSLocalizedString("OK", comment: ""), message: NSLocalizedString("My message", comment: ""), preferredStyle: .alert)
            let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in }
            alertController.addAction(OKAction)
            //self.present(alertController, animated: true)
            [UIApplication sharedApplication].keyWindow.rootViewController.present(alertController, animated: true)
            //UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)*/


        }
        
        
    }


}
