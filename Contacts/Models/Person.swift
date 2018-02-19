//
//  Person.swift
//  Contacts
//
//  Created by Peter Braun on 2/18/18.
//  Copyright © 2018 anDeRan. All rights reserved.
//

import Foundation

struct Person: Codable {
    var contactID: String
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var streetAddress1: String
    var streetAddress2: String
    var city: String
    var state: String
    var zipCode: Int

    enum CodingKeys: String, CodingKey {
        case contactID
        case firstName
        case lastName
        case phoneNumber = "phone"
        case streetAddress1 = "address1"
        case streetAddress2 = "address2"
        case city
        case state
        case zipCode
    }
}
