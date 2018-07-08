//Scenario - Bank Account Management System (Access Information)

//Import Ballerina http library packages
//Package contains fuctions annotaions and connectores

import ballerina/http;
import ballerina/io;
import ballerina/runtime;

//This service is accessible at port no 9091

//Ballerina client can be used to connect to the created HTTPS listener.
//The client needs to provide values for 'trustStoreFile' and 'trustStorePassword'
endpoint http:SecureListener ep {
    port: 9092	,

    secureSocket: {
        keyStore: {
            path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        },
        trustStore: {
            path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
    }
};

map<json> bankDetails;

//authConfiguration comprise Authentication and Authorization
//Authentication can set as 'enable' 
//Authorization based on scpoe
@http:ServiceConfig {
    basePath: "/hello",
    authConfig: {
        authentication: { enabled: true },
        scopes: ["scope1"]
    }
}

service<http:Service> accountMgt bind ep {
@http:ResourceConfig {
        methods: ["GET"],
        path: "/account",
	authConfig: {
        scopes: ["scope2"]
        }
    }

retriveBankAccountDetails(endpoint client, http:Request req) {
	http:Response response;
        string filePath = "./files/sample.json";	        
    	
	io:ByteChannel byteChannel = io:openFile(filePath, io:READ);

        io:CharacterChannel ch = new io:CharacterChannel(byteChannel, "UTF8");
	//int size = ch.size("./files/sample.json");
        match ch.readJson() {
            json result => {
		
		//int size = ch.size("./files/sample.json");		
		//io:print(size);

		 int j = 0;
    			while (j < 10) {
			 runtime:sleep(1000);
       			 io:println(j+ " Waiting ");
				
        			j = j + 1;

       			 if (j == 9) {
          			  break;
        		}
    		}
             
       		
		//characterChannel.close();
		
		response.setJsonPayload(result);               
       		 _ = client->respond(response);

                io:println(result);
		
            }
            error err => {
		response.statusCode = 404;
		json payload = " JSON file cannot read ";
                response.setJsonPayload(payload);  
		
       		 _ = client->respond(response);
		//characterChannel.close();
                throw err;
            }
        }
       		 


}


@http:ResourceConfig {
        methods: ["POST"],
        path: "/account/hi",
        authConfig: {
            scopes: ["scope2"]
        }
    }


enterBankAccountDetails(endpoint client, http:Request req) {
	http:Response response;
	json accountReq = check req.getJsonPayload();
        json Bank_Account_No = accountReq.Account_Details.Bank_Account_No;

        // Check the Bank_Account_No is null or not entered
        if(Bank_Account_No == null || Bank_Account_No.toString().length() == 0)	{
            json payload = { status: " Please Enter Your Bank Account Number "};
            http:Response response;
            response.setJsonPayload(payload);

            // Set 204 "No content" response code in the response message.
            response.statusCode = 204;
            _ = client->respond(response);
        }

        else {

            string accountId = Bank_Account_No.toString();
            bankDetails[accountId] = accountReq;

	
        string filePath = "./files/sample.json";	        
    	
	io:ByteChannel byteChannel = io:openFile(filePath, io:WRITE);

        io:CharacterChannel ch = new io:CharacterChannel(byteChannel, "UTF8");

        match ch.writeJson(accountReq) {
            
		error err => {
           	io:println(accountReq);
            	throw err;
        	}
		
		
            
            	() => {
		
		
		int j = 0;
    			while (j < 10) {
			 runtime:sleep(1000);
       			 io:println(j+ " Waiting ");
				
        			j = j + 1;

       			 if (j == 9) {
          			  break;
        		}
    		}

            	
		json payload = " Content written successfully ";
		//response.statusCode = 201;
                response.setJsonPayload(payload);  
		
       		 _ = client->respond(response);
            	//io:println("Content written successfully");
            }
        }
	
	
	
       		 


}}






}
