//
//  File.swift
//  
//
//  Created by David Nikiforov on 12/31/22.
//

import Foundation
import Fluent

//final class UserNames: Model {
//    static let schema = "users"
//    
//    @ID(key: .id)
//    var id: UUID?
//    
//    @Field(key: "user_name")
//    var userName: String
//    
//    @Field(key: "access_token")
//    var accessToken: String
//    
//    init() {}
//    
//    init(id: UUID? = nil, userName: String, accessToken: String) {
//        self.id = id
//        self.userName = userName
//        self.accessToken = accessToken
//    }
//}

final class Users: Model {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "last_name")
    var lastName: String
    
    @Field(key: "access_token")
    var accessToken: [String]
    
   
    
    init() {}
    
    init(id: UUID? = nil, email: String, password: String ,firstName: String, lastName: String, accessToken: [String]) {
        self.id = id
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.accessToken = accessToken
    }
}

struct EmailWithAccess: Codable {
    var email: String
    var publicKey: String
}

struct AccessToken: Codable {
    var access_token: String
    var item_id: String
    var request_id: String
}
