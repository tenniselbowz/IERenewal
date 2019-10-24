public with sharing class IERenewal_ATTJasperAPIServiceAccess {
	private String baseUrl;
	private String apiKey;
	private String restAction;
	private String attJasperControlCenterUserName;
	private String accountId;

	public IERenewal_ATTJasperAPIServiceAccess(String baseUrl, String apiKey, String restAction, String userName, String accountId) {
		this.baseUrl = baseUrl;
		this.apiKey = apiKey;
		this.restAction = restAction;
		this.attJasperControlCenterUserName = userName;
		this.accountId = accountId;
	}

	public class IE_Device_Request1
	{
	    public string status{get;set;}
	}

	public class IE_Device_Request2
	{
	    //public string customer{get;set;}
	    public string deviceID{get;set;}
	    public string modemID{get;set;}
	}

	/*public class IE_Device_Request3
	{
	    public string ratePlan{get;set;}
	    public string communicationPlan{get;set;}
	}*/

	public class IE_Device_Request4
	{
		public string status{get;set;}
	    //public string customer{get;set;}
	    public string deviceID{get;set;}
	    public string modemID{get;set;}
	    //public string ratePlan{get;set;}
	    //public string communicationPlan{get;set;}
	}



	public IERenewal_ATTJasperAPIServiceResponseObj getDeviceByICCID(String iccId, list<Integration_Error__c> integrationErrorList) {
		IERenewal_ATTJasperAPIServiceResponseObj responseObject = new IERenewal_ATTJasperAPIServiceResponseObj();
		//list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();

		try {
			HTTPRequest r = new HTTPRequest();
			String endPoint = baseUrl + restAction + '/' + iccId;

			//use basic http authentication
	        Blob headerValue = Blob.valueOf(attJasperControlCenterUserName + ':' + apiKey);
	        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

			r.setTimeOut(120000);
			r.setEndpoint(endPoint);
			r.setHeader('Authorization', authorizationHeader);
			r.setMethod('GET');
			r.setHeader('Accept', 'application/json');

			HTTP auth = new HTTP();
			HTTPResponse resp = null;
			resp = auth.send(r);

			String requestToString = '\nGET ' + endPoint;
			requestToString += '\nHeaders';
			requestToString += '\n--------';
			requestToString += '\nAuthorization: ' + authorizationHeader;
			requestToString += '\nAccept: ' + 'application/json';
			requestToString += '\nBody';
			requestToString += '\n-----';
			requestToString += '\n[none]\n';

			responseObject.setRequestData(requestToString);
			responseObject.setResponseCode(resp.getStatusCode());
			responseObject.setResponseMessage(resp.getHeader('error_message'));
			responseObject.setResponseData('');
			if (resp.getStatusCode() == 200) {
				responseObject.setResponseData(resp.getBody());
			}
			else { 
	        	//log the error
	        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
										, Error_Description__c = 'Transmission Error ['+resp.getStatusCode()+' ] '+'-'+resp.getBody()
										, Integration_Object__c = 'AT&T Control Center'
										, Integration_Point__c = 'IE'
										, Request_Data__c = requestToString ));
		    }

			System.debug(LoggingLevel.ERROR, 'getDeviceByICCID: ' + resp.getStatusCode());
			System.debug(LoggingLevel.ERROR, 'getDeviceByICCID: ' + resp.getBody());
		}
		catch (Exception ex) {
			//log the error
			System.debug(LoggingLevel.ERROR, 'getDeviceByICCID: ' + ex);
			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
										, Error_Description__c = 'CALLOUT_EXCEPTION'
										, Integration_Object__c = 'AT&T Control Center'
										, Integration_Point__c = 'IE'
										, Request_Data__c = ex.getMessage() ));
		}

		if (integrationErrorList.size() > 0)
		{
			System.debug(LoggingLevel.ERROR, 'getDeviceByICCID: ' + integrationErrorList);
            //insert integrationErrorList;
		}


        System.debug(LoggingLevel.ERROR, 'getDeviceByICCID: ' + responseObject);

		return responseObject;

	}


	public IERenewal_ATTJasperAPIServiceResponseObj getDevicesByAccountID(String modifiedSinceDate, String simFilterStatus, list<Integration_Error__c> integrationErrorList) {
		IERenewal_ATTJasperAPIServiceResponseObj responseObject = new IERenewal_ATTJasperAPIServiceResponseObj();
		//list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();

		try {
			HTTPRequest r = new HTTPRequest();
			String endPoint = baseUrl + restAction + '?accountId=' + accountId + '&modifiedSince=' + modifiedSinceDate + '&status=' + simFilterStatus + '&pageSize=50&pageNumber=1';

			//use basic http authentication
	        Blob headerValue = Blob.valueOf(attJasperControlCenterUserName + ':' + apiKey);
	        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

			r.setTimeOut(120000);
			r.setEndpoint(endPoint);
			r.setHeader('Authorization', authorizationHeader);
			r.setMethod('GET');
			r.setHeader('Accept', 'application/json');

			HTTP auth = new HTTP();
			HTTPResponse resp = null;
			resp = auth.send(r);

			String requestToString = '\nGET ' + endPoint;
			requestToString += '\nHeaders';
			requestToString += '\n--------';
			requestToString += '\nAuthorization: ' + authorizationHeader;
			requestToString += '\nAccept: ' + 'application/json';
			requestToString += '\nBody';
			requestToString += '\n-----';
			requestToString += '\n[none]\n';

			responseObject.setRequestData(requestToString);
			responseObject.setResponseCode(resp.getStatusCode());
			responseObject.setResponseMessage(resp.getHeader('error_message'));
			responseObject.setResponseData('');
			if (resp.getStatusCode() == 200) {
				responseObject.setResponseData(resp.getBody());
			}
			else { 
	        	//log the error
	        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
										, Error_Description__c = 'Transmission Error ['+resp.getStatusCode()+' ] '+'-'+resp.getBody()
										, Integration_Object__c = 'AT&T Control Center'
										, Integration_Point__c = 'IE'
										, Request_Data__c = requestToString ));
		    }

			System.debug(LoggingLevel.ERROR, 'getDevicesByAccountID: ' + resp.getStatusCode());
			System.debug(LoggingLevel.ERROR, 'getDevicesByAccountID: ' + resp.getBody());
		}
		catch (Exception ex) {
			//log the error
			System.debug(LoggingLevel.ERROR, 'getDevicesByAccountID: ' + ex);
			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
										, Error_Description__c = 'CALLOUT_EXCEPTION'
										, Integration_Object__c = 'AT&T Control Center'
										, Integration_Point__c = 'IE'
										, Request_Data__c = ex.getMessage() ));
		}

		if (integrationErrorList.size() > 0) {
			System.debug(LoggingLevel.ERROR, 'getDevicesByAccountID: ' + integrationErrorList);
            //insert integrationErrorList;
		}

		System.debug(LoggingLevel.ERROR, 'getDevicesByAccountID: ' + responseObject);

		return responseObject;

	}


	public IERenewal_ATTJasperAPIServiceResponseObj updateDeviceByICCID(String iccId, String status, String ratePlan, String communicationPlan, String customer, String deviceID, String modemID, list<Integration_Error__c> integrationErrorList) {
		//NOTE: The following parameters customer, ratePlan, communicationPlan are no longer setable

		//Edit device details, using a json request body
		//Use this to set the following parameters,
		// SIM Status Values: "ACTIVATED", "DEACTIVATED", "ACTIVATION_READY"
		// Rate Plan Values: "Daikin Applied - 50MB Plan", "Daikin Applied - 50MB US_CAN_MEX Plan"
		//		"Daikin Applied - 100MB Plan", "Daikin Applied - 100MB US_CAN_MEX Plan"
		// 		"Daikin Applied - 10MB Plan", "Daikin Applied - 10MB US_CAN_MEX Plan"
		// 		"Daikin Applied - 150MB Plan", "Daikin Applied - 150MB Intl Plan"
		// 		"Daikin Applied - 1GB Plan", "Daikin Applied - 1GB US_CAN_MEX Plan"
		// 		"Daikin Applied - 20MB Plan", "Daikin Applied - 20MB US_CAN_MEX Plan"
		// 		"Daikin Applied - 500MB Plan", "Daikin Applied - 500MB Intl Plan", "Daikin Applied - 500MB US_CAN_MEX Plan"
		// Communication Plan Values: "Daikin Applied - AT&T Data MT - IFA", "Daikin Applied - AT&T Data MT - INT"
		// Customer Values: "Unassigned", "Daikin Test"
		// Device ID Value: <Serial Number (Order Tag)>
		// Modem ID Value: <MAC Address>
		/* ------Example JSON Request Body for Controls Lab Test Device, iccid = 89011704258018735310
		{
		"status": "ACTIVATION_READY",
		"ratePlan": "Daikin Applied - 50MB Plan",
		"communicationPlan": "Daikin Applied - AT&T Data MT - IFA",
		"customer": "Daikin Test",
		"deviceID": "Controls Lab/Simulator",
		"modemID": "00600c:816eec"
		}
		*/
		IERenewal_ATTJasperAPIServiceResponseObj responseObject = new IERenewal_ATTJasperAPIServiceResponseObj();
		//list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();

		try {
			String jsonBody = null;
			IE_Device_Request1 ieDevicePut1 = null;
			IE_Device_Request2 ieDevicePut2 = null;
			//IE_Device_Request3 ieDevicePut3 = null;
			IE_Device_Request4 ieDevicePut4 = null;

			if ((ratePlan == null) && (communicationPlan == null) && (customer == null) && (deviceID == null) && (modemID == null)) {
				// Set the Status request parameter only
				ieDevicePut1 = new IE_Device_Request1();
				ieDevicePut1.status = status;
				jsonBody = JSON.serialize(ieDevicePut1);
			}
			else if ((status == null) && (ratePlan == null) && (communicationPlan == null)) {
				// Set the Device Id and Modem Id request parameters only
				ieDevicePut2 = new IE_Device_Request2();
				//ieDevicePut2.customer = customer;
				ieDevicePut2.deviceID = deviceID;
				ieDevicePut2.modemID = modemID;
				jsonBody = JSON.serialize(ieDevicePut2);
			}
			/*else if ((status == null) && (customer == null) && (deviceID == null) && (modemID == null)) {
				// Set the Rate Plan and Communication Plan request parameters only
				ieDevicePut3 = new IE_Device_Request3();
				ieDevicePut3.ratePlan = ratePlan;
				ieDevicePut3.communicationPlan = communicationPlan;
				jsonBody = JSON.serialize(ieDevicePut3);
			}*/
			else {
				// Set all of the request parameters
				ieDevicePut4 = new IE_Device_Request4();
				ieDevicePut4.status = status;
				//ieDevicePut4.ratePlan = ratePlan;
				//ieDevicePut4.communicationPlan = communicationPlan;
				//ieDevicePut4.customer = customer;
				ieDevicePut4.deviceID = deviceID;
				ieDevicePut4.modemID = modemID;
				jsonBody = JSON.serialize(ieDevicePut4);
			}

			
			HTTPRequest r = new HTTPRequest();
			String endPoint = baseUrl + restAction + '/' + iccId;

			//use basic http authentication
	        Blob headerValue = Blob.valueOf(attJasperControlCenterUserName + ':' + apiKey);
	        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

			r.setTimeOut(120000);
			r.setEndpoint(endPoint);
			r.setHeader('Authorization', authorizationHeader);
			r.setMethod('PUT');
			r.setHeader('Accept', 'application/json');
			r.setHeader('Content-Type', 'application/json');

			r.setBody(jsonBody);

			HTTP auth = new HTTP();
			HTTPResponse resp = null;
			resp = auth.send(r);

			String requestToString = '\nPUT ' + endPoint;
			requestToString += '\nHeaders';
			requestToString += '\n--------';
			requestToString += '\nAuthorization: ' + authorizationHeader;
			requestToString += '\nAccept: ' + 'application/json';
			requestToString += '\nContent-Type: ' + 'application/json';
			requestToString += '\nBody';
			requestToString += '\n-----';
			requestToString += '\n' + jsonBody + '\n';

			responseObject.setRequestData(requestToString);
			responseObject.setResponseCode(resp.getStatusCode());
			responseObject.setResponseMessage(resp.getHeader('error_message'));
			responseObject.setResponseData('');
			if (resp.getStatusCode() == 200) {
				responseObject.setResponseData(resp.getBody());
			}
			else { 
	        	//log the error
	        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
										, Error_Description__c = 'Transmission Error ['+resp.getStatusCode()+' ] '+'-'+resp.getBody()
										, Integration_Object__c = 'AT&T Control Center'
										, Integration_Point__c = 'IE'
										, Request_Data__c = requestToString ));
		    }

			System.debug(LoggingLevel.ERROR, 'updateDeviceByICCID: ' + resp.getStatusCode());
			System.debug(LoggingLevel.ERROR, 'updateDeviceByICCID: ' + resp.getBody());
		}
		catch (Exception ex) {
			//log the error
			System.debug(LoggingLevel.ERROR, 'updateDeviceByICCID: ' + ex);
			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
										, Error_Description__c = 'CALLOUT_EXCEPTION'
										, Integration_Object__c = 'AT&T Control Center'
										, Integration_Point__c = 'IE'
										, Request_Data__c = ex.getMessage() ));
		}

		if (integrationErrorList.size() > 0) {
			System.debug(LoggingLevel.ERROR, 'updateDeviceByICCID: ' + integrationErrorList);
            //insert integrationErrorList;
		}

		System.debug(LoggingLevel.ERROR, 'updateDeviceByICCID: ' + responseObject);

		return responseObject;

	}
}