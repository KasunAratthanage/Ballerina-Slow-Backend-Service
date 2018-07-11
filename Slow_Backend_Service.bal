//Scenario - Bank Account Management System (Access Information)

//Import Ballerina http library packages
//Package contains fuctions annotaions and connectores

import ballerina/http;
import ballerina/io;
import ballerina/runtime;
import ballerina/log;

//This service is accessible at port no 9091

//Ballerina client can be used to connect to the created HTTPS listener.
//The client needs to provide values for 'trustStoreFile' and 'trustStorePassword'
endpoint http:SecureListener ep {
    port: 9095	,

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
    basePath: "/banktest",
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
	
	http:Request newRequest = new;
	
	//Check whether 'sleeptime' header exisits in the invoking request  
        if (!req.hasHeader("sleeptime")) {
            http:Response errorResponse = new;
	//If not included 'sleeptime' in header print this as a error message  
            errorResponse.statusCode = 500;
            json errMsg = { "error": "'sleeptime' header is not found" };
            errorResponse.setPayload(errMsg);
            client->respond(errorResponse) but {
                error e => log:printError("Error sending response", err = e) };
            done;
        }

	//String to integer type conversion
        string nameString = req.getHeader("sleeptime");

	int delay = 0;
   	var intResult = <int>nameString;
   	match intResult {
        	int value => delay=value;
        	error err => io:println("error: " + err.message);
   	}
	
	
	http:Response response;
        string filePath = "./files/sample.json";	        
    	
	//Create the byte channel	
	io:ByteChannel byteChannel = io:openFile(filePath, io:READ);

	//Derive the character channel from above byte channel
        io:CharacterChannel ch = new io:CharacterChannel(byteChannel, "UTF8");
	
        match ch.readJson() {
            json result => {
		
		 int j = 0;
    			while (j < 10) {
			 runtime:sleep(delay);
       			 io:println(j+ " Waiting ");
				
        			j = j + 1;

       			 if (j == 1) {
          			  break;
        		}
    		}
             
       		//close the charcter channel after reading process
		ch.close() but {
        	error e =>
         	log:printError("Error occurred while closing character stream",
                          err = e)
   		};
		
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
        path: "/account/banktest1",
        authConfig: {
            scopes: ["scope2"]
        }
    }


enterBankAccountDetails(endpoint client, http:Request req) {
	http:Response response;

	http:Request newRequest = new;
	
	//Check whether 'sleeptime' header exisits in the invoking request  
        if (!req.hasHeader("sleeptime")) {
            http:Response errorResponse = new;
	//If not included 'sleeptime' in header print this as a error message  
            errorResponse.statusCode = 500;
            json errMsg = { "error": "'sleeptime' header is not found" };
            errorResponse.setPayload(errMsg);
            client->respond(errorResponse) but {
                error e => log:printError("Error sending response", err = e) };
            done;
        }

	//String to integer type conversion
        string nameString = req.getHeader("sleeptime");

	int delay = 0;
   	var intResult = <int>nameString;
   	match intResult {
        	int value => delay=value;
        	error err => io:println("error: " + err.message);
   	}


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
	
    	//Create the byte channel
	io:ByteChannel byteChannel = io:openFile(filePath, io:WRITE);
	
	//Derive the character channel from above byte channel
        io:CharacterChannel ch = new io:CharacterChannel(byteChannel, "UTF8");

        match ch.writeJson(accountReq) {
            
		error err => {
           	io:println(accountReq);
            	throw err;
        	}
		
            
            	() => {
		
		
		int j = 0;
    			while (j < 10) {
			 runtime:sleep(delay);
       			 io:println(j+ " Waiting ");
				
        			j = j + 1;

       			 if (j == 1) {
          			  break;
        		}
    		}
	
		//close the charcter channel after writing process
		ch.close() but {
        	error e =>
         	log:printError("Error occurred while closing character stream",
                        err = e)
   		};

            	
		json payload = " Content written successfully ";
		//response.statusCode = 201;
                response.setJsonPayload(payload);  
		
       		 _ = client->respond(response);
            	//io:println("Content written successfully");
            }
        }     		 

}
}


}
