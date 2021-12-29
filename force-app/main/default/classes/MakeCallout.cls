public class MakeCallout {
	// Method to perform callouts
	public static HttpResponse MakeCalloutWithBasicAuthentication(String endpoint, String resource, String username, String password, String method, String query, String contentType) {
		HttpResponse res;
		// check to ensure a callout can be performed using the Limits class. // This is 100 callouts per execution as of Spring 16 release
		if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
			system.debug('Maximum number of callouts has been reached.'); 
		// check for credentials error
		} else if (endpoint == null || username == null || password == null) {
            system.debug('Please verify your API Credentials.'); 
		// configure and perform the callout
		} else {
			// define transaction variables
			HttpRequest req = new HttpRequest();
			res = new HttpResponse();
			Http h = new Http();
			// Configure the request
			req.setEndpoint(endpoint + resource);
			req.setMethod(method);
			req.setTimeout(120000);
			// Add basic authentication to header // Create blob of user:pass
			Blob headerValue = Blob.valueOf(username + ':' + password);
			// Base 64 Encode the blob and prepend 'Basic '
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
			// Add the basic auth String to the Request Header
			req.setHeader('Authorization', authorizationHeader);
			// Configure standard headers
			req.setHeader('Accept', '*/*');
			// This tells the API that we are sending and receiving the data as a JSON object
			req.setHeader('Content-Type', contentType);
			// Additional headers may be needed / Refer to the API documentation.
			// Use a service like runscope.com to test everything ahead of time.
			req.setBody(query);
            
            String emailErrorSubject = 'Error with callout : ' + req.getEndpoint() + ' ' + req.getMethod();
            String emailErrorBody;
            
			// Attempt the callout - create return error on exception
			try { // Perform callout and set response
                system.debug(req);
				res = h.send(req);
				// check response
				//system.debug(res.getBody());
				if (res.getStatusCode() != 200 || res.getBody() == null) {
                    emailErrorBody = 'Error: Callout failed. System.HttpResponse[Status='+res.getStatus()+', StatusCode='+res.getStatusCode()+']';
					CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);                    
                    res = null;
				} 
			} catch (exception e) {
				// Unexpected exceptions will be caught here, like a deserialization error.
				emailErrorBody = 'Error: An exception has been encountered while calling out to Integration: '
						+ e.getMessage();
				CommonTools.emailExceptionsToIT(emailErrorSubject, emailErrorBody);
			}
		} // Return the response 
        return res;

	}

}