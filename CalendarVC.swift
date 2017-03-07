//
//  CalendarVC.swift
//  Live2DProject
//
//  Created by Blake on 2017/3/6.
//  Copyright © 2017年 Blake. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2
import GoogleSignIn

class CalendarVC: UIViewController {
    
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "YOUR_CLIENT_ID_HERE"
    private let scopes = [kGTLAuthScopeCalendarReadonly]
    let service = GTLServiceCalendar()
    let output = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.textColor = UIColor.black
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(output)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = kClientID
        GIDSignIn.sharedInstance().scopes = scopes
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == false {
            GIDSignIn.sharedInstance().signIn()
        } else {
            if let user = GIDSignIn.sharedInstance().currentUser {
                service.authorizer = user.authentication.fetcherAuthorizer()
                fetchEvents()
            } else {
                GIDSignIn.sharedInstance().signInSilently()
            }
        }
    }
    
    func fetchEvents() {
        let query = GTLQueryCalendar.queryForEventsList(withCalendarId: "primary")
        query?.maxResults = 10
        query?.timeMin = GTLDateTime(date: Date(), timeZone: TimeZone.ReferenceType.local)
        query?.singleEvents = true
        query?.orderBy = kGTLCalendarOrderByStartTime
    
        service.executeQuery(query!, delegate: self, didFinish: #selector(self.displayResultWithTicket(ticket:finishedWithObject: error:))
        )
    }
    
    func displayResultWithTicket(ticket: GTLServiceTicket, finishedWithObject response: GTLCalendarEvents, error: NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var eventString = ""
        
        if let events = response.items(), events.isEmpty == false {
            for event in events as! [GTLCalendarEvent] {
                let start: GTLDateTime! = event.start.dateTime ?? event.start.date
                let startString = DateFormatter.localizedString(from: start.date, dateStyle: .short, timeStyle: .short)
                eventString += "\(startString) - \(event.summary!)\n"
            }
        } else {
            eventString = "no upcoming events found"
        }
        
        output.text = eventString
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CalendarVC: GIDSignInUIDelegate, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if user != nil {
            service.authorizer = user.authentication.fetcherAuthorizer()
            fetchEvents()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        DispatchQueue.main.async {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true, completion: nil)

    }
}
