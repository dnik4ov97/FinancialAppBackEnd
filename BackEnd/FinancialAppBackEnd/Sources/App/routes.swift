import Vapor
import FluentKit
import CurlDSL


extension Data: Content {
    
}

func routes(_ app: Application) throws {
    
    
    let clientName = "Niki Finance"
    let clientId = "63601ef71a807200137b674a"
    
//    let secret = "ff636de5c3dfcf4452cd512534eb6a"
//    let environment = "https://sandbox.plaid.com"
    let secret = "2dc5ba85eb536192413ea211f8d795"
    let environment = "https://development.plaid.com"
//    let environment = " https://production.plaid.com"
    
    
    app.get { req async in
        "It works!"
    }
    
    /*
     -------------------------------------------------------------------------------------------------------------------------------------------------------------------
        Create User
     -------------------------------------------------------------------------------------------------------------------------------------------------------------------
     */
    app.post("createUser") { req async -> String in
        
//        let user = UserNames(userName: "davidniki")
        do {
            let username1 = req.content
            print(username1)
            let username = try req.content.decode(Users.self)
            print(username)
            try await username.create(on: req.db)
            print(username)
//            return username.accessToken ?? ""
        } catch {
            print(error)
            return("error decoding")
        }
    
        return "ran"
    }
    
    
    
    
    
    /*
     -------------------------------------------------------------------------------------------------------------------------------------------------------------------
        1) GET UserID FROM MongoDB DATABASE???
        2) Create Link Token For Link to Accesss
     -------------------------------------------------------------------------------------------------------------------------------------------------------------------
     */
    app.post("create_link_token") { req -> String in
        let userId = "1234"
        do {
            let request = try CURL("curl -X POST \(environment)/link/token/create -H 'Content-Type: application/json' -d '{ \"client_id\": \"\(clientId)\",\"secret\": \"\(secret)\",\"client_name\": \"\(clientName)\",\"user\": { \"client_user_id\": \"\(userId)\" },\"products\": [\"transactions\"],\"country_codes\": [\"US\"],\"language\": \"en\", \"redirect_uri\": \"https://app.example.com/plaid\"}'").buildRequest()
            let (data, _) = try await URLSession.shared.data(for: request)
            let dataString =  String(data: data, encoding: .utf8)!
            
            return dataString
            
        } catch {
            return "\(error)"
        }
    }
    
    
   /*
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------
        1) Exchange Public Token From Link For An Access Token
        2) Store to MongoDB Database
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------
    */
    app.post("item_public_token_exchange") { req async -> String in
        
        do {
            
            let userAndPublicKey = try req.content.decode(EmailWithAccess.self)
            
            
            let request = try CURL("curl -X POST \(environment)/item/public_token/exchange -H 'Content-Type: application/json' -d '{\"client_id\": \"\(clientId)\", \"secret\": \"\(secret)\", \"public_token\": \"\(userAndPublicKey.publicKey)\"}'").buildRequest()
//
            let (data, _) = try await URLSession.shared.data(for: request)
//            let dataString =  String(data: data, encoding: .utf8)!
            
            let accessToken = try JSONDecoder().decode(AccessToken.self, from: data)
            
            let oldAccessArray = try await Users.query(on: req.db)
                .filter(\.$email == userAndPublicKey.email)
                .field(\.$accessToken)
                .first()
            
            var array = oldAccessArray!.accessToken
            print("oldAccessArray: \(array)")
            array.append(accessToken.access_token)
            print("newAccessArray: \(array)")
            
            
            try await Users.query(on: req.db)
                .set(\.$accessToken, to: array)
                .filter(\.$email == userAndPublicKey.email)
                .update()
//            let result = req.db.transaction { database in
//                user.save(on: database)
//            }
            return "decoded accessToken"

        } catch {
            return "\(error)"
        }
        
    }
    
    
    
    /*
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------
            GET TRANSACTIONS WITH ACCESS TOKEN (FROM DATABASE)
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------
    */
    app.post("transaction_get") { req async -> String in
        
        var transactions = ""
        
        let accessToken = req.parameters.get("accessToken") ?? ""
        
        do {
            
            let email = try req.content.decode(String.self)
            
            let access = try await Users.query(on: req.db)
                .filter(\.$email == email)
                .field(\.$accessToken)
                .first()
            
            
            let accessTokens = access?.accessToken ?? [String]()
            print("accessTokens: \(accessTokens)")
            
            for accessToken in accessTokens {
                let request = try CURL("curl -X POST \(environment)/transactions/get -H 'Content-Type: application/json' -d '{\"client_id\": \"\(clientId)\", \"secret\": \"\(secret)\", \"access_token\": \"\(accessToken)\", \"start_date\": \"2022-12-01\", \"end_date\": \"2022-12-31\"}'").buildRequest()
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let dataString =  String(data: data, encoding: .utf8)!
                transactions += dataString
                print(dataString)
                
//                return dataString
            }

        } catch {
            return "\(error)"
        }
        
        return transactions
    }
    
    
    
    /*
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------
            GET ACCOUNTS BALANCE WITH ACCESS TOKEN (FROM DATABASE)
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------
    */
    app.post("get_balance") { req async -> [Data] in
        
        var accountsForEachAccss = [Data]()
        
        do {
            
            let email = try req.content.decode(String.self)
            
            let access = try await Users.query(on: req.db)
                .filter(\.$email == email)
                .field(\.$accessToken)
                .first()
            
            
            let accessTokens = access?.accessToken ?? [String]()
            print("accessTokens: \(accessTokens)")
            
            for accessToken in accessTokens {
                let request = try CURL("curl -X POST \(environment)/accounts/balance/get -H 'Content-Type: application/json' -d '{\"client_id\": \"\(clientId)\", \"secret\": \"\(secret)\", \"access_token\": \"\(accessToken)\"}'").buildRequest()
                let (data, _) = try await URLSession.shared.data(for: request)
                accountsForEachAccss.append(data)
            }
            
        } catch {
            print(error)
        }

        print(accountsForEachAccss)
        return accountsForEachAccss
    }
    
    
}
