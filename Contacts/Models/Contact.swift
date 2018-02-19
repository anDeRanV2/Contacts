//
//  Contact.swift
//  Contacts
//
//  Created by Peter Braun on 2/18/18.
//  Copyright © 2018 anDeRan. All rights reserved.
//

import Foundation
import CoreData
import AlecrimCoreData

extension Contact {
    static let contactID      = AlecrimCoreData.Attribute<String>("contactID")
    static let firstName      = AlecrimCoreData.Attribute<String>("firstName")
    static let lastName       = AlecrimCoreData.Attribute<String>("lastName")
    static let phoneNumber    = AlecrimCoreData.Attribute<String>("phoneNumber")
    static let streetAddress1 = AlecrimCoreData.Attribute<String>("streetAddress1")
    static let streetAddress2 = AlecrimCoreData.Attribute<String>("streetAddress2")
    static let city           = AlecrimCoreData.Attribute<String>("city")
    static let state          = AlecrimCoreData.Attribute<String>("state")
    static let zipCode        = AlecrimCoreData.Attribute<String>("zipCode")
    static let createdAt      = AlecrimCoreData.Attribute<Double>("createdAt")
    static let updatedAt      = AlecrimCoreData.Attribute<Double>("updatedAt")
}
