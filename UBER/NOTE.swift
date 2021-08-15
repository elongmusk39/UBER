//
//  NOTE.swift
//  UBER
//
//  Created by Long Nguyen on 4/18/21.
//

/*
 ok, so when we download the "GoogleService-Info.plist", we gotta make sure that it doesnt have any number indicated by its side. U gotta download it and drag+drop it in this project
 
 the terminal, gotta import these pods (gotta import CocoaPods in needed):
 
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'Firebase/Storage'
    pod 'GeoFire'
 
 Since we are using Realtime Database, we need to use the database_url, or ask uncle Google if we run into issues relating to Realtime Database "https://stackoverflow.com/questions/47730910/failed-to-get-firebasedatabase-instance-specify-databaseurl-within-firebaseapp"
 
 Now after implementing the MapView, we need to access user's location, and ask user for permission:
 -go to "info.plist", add "Privacy - Location Always Usage Description", then "Privacy - Location Always and When In Use Usage Description", and finally add "Privacy - Location When In Use Usage Description". we need all 3 keys for the simulator to work. In the real phone, we only need to access the location only when the app is opened
 -then go to "HomeController" and write out some code, use locationManager and implement some cases for it
 -complete all the UI shit, fetch user info and display it on the app
 -remember to work with annotation, zoom in and out on the map
 -
 
 
 
 
 */
