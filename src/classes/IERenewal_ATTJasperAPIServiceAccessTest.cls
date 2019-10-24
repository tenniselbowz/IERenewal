@isTest
private class IERenewal_ATTJasperAPIServiceAccessTest {
	static final String BASEURL = 'https://restapi1.jasper.com/rws/api/v1/';
    static final String APIKEY = '4ef26c38-e8e7-46dd-8a5b-b38f8c0e9baa';
    static final String ENTERPRISE_ACCOUNTID = '100414901';
    static final String JASPERCC_USERNAME = 'KRoessler';
    static final String TESTDEVICEICCID = '89011704258018735310';

    class HttpCalloutMockImpl implements HttpCalloutMock {
        String validAPIKey;
        String validBaseURL;
        String validEnterpriseAccountID;
        String validJasperCCUsername;
        String restAction;
        String iccId;
        String validEndPoint;

        public HttpCalloutMockImpl( String vBaseURL, String vApiKey, String vEnterpriseAccountId, String vJasperCCUsername, String vRestAction, String vICCID , String vEndPoint) {
            validBaseURL = vBaseURL;
            validAPIKey = vApiKey;
            validEnterpriseAccountID = vEnterpriseAccountId;
            validJasperCCUsername = vJasperCCUsername;
            restAction = vRestAction;
            iccId = vICCID;
            validEndPoint = vEndPoint;
        }

        public HTTPResponse respond(HTTPRequest req) {
        	/*************************
        	* Some HTTP Status Codes:
        	* 200 OK - Standard response for successful HTTP requests
        	* 201 Created - The request has been fulfilled, resulting in the creation of a new resource
        	* 400 Bad Request - The server cannot or will not process the request due to an apparent client error
        	* 401 Unauthorized - Authentication has failed, the user does not have the necessary credentials
        	* 403 Forbidden - The request was a valid request, but the server is refusing to respond to it
        	* 404 Not Found - The requested resource could not be found but may be available in the future
        	* 405 Method Not Allowed - A request method is not supported for the requested resource
        	**************************/

            HTTPResponse resp = new HTTPResponse();
            Blob headerValue = Blob.valueOf(validJasperCCUsername + ':' + validAPIKey);
            String validHTTPBasicAuthentication = 'Basic ' + EncodingUtil.base64Encode(headerValue);

            if (req.getEndpoint().contains(validEndPoint)) {
                if ((req.getHeader('Authorization') == validHTTPBasicAuthentication) && (req.getHeader('Accept') == 'application/json')) {
                    if (req.getMethod() == 'GET') {
                        resp.setStatusCode(200);

                        String testResponseData = null;
                        if (validEndPoint.contains('?accountId='))
                        {
                        	testResponseData = '{"pageNumber":1,"devices":[{"iccid":"89011704258018734891","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018734826","status":"ACTIVATED","ratePlan":"Daikin Applied - 1GB US_CAN_MEX Plan","communicationPlan":"Daikin Applied - AT&T Data MT - INT"},{"iccid":"89011704258018735021","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252319572027","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618545","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429471","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619287","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305617448","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305617927","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618495","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619378","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618842","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018735187","status":"ACTIVATED","ratePlan":"Daikin Applied - 10MB US_CAN_MEX Plan","communicationPlan":"Daikin Applied - AT&T Data MT - INT"},{"iccid":"89011704252305618958","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619410","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429083","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252306820793","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619501","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619352","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252319571565","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619121","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618719","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018734131","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618487","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618610","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618982","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018734230","status":"ACTIVATED","ratePlan":"Daikin Applied - 20MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018734602","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618685","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018734198","status":"ACTIVATED","ratePlan":"Daikin Applied - 20MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305617596","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619519","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618784","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252319571847","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619246","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619436","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429133","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619386","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429281","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429174","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619444","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619014","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305617703","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618834","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429836","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018733802","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619261","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618180","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252306820397","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618792","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"}],"lastPage":false}';
                        }
                        else 
                        {
                        	testResponseData = '{"iccid":"89011704258018735310","imsi":"310170801873531","msisdn":"882350801873531","imei":"351579050703680","status":"ACTIVATION_READY","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA","customer":"Daikin Test","endConsumerId":null,"dateActivated":"2015-01-30 20:18:11.755+0000","dateAdded":"2014-02-14 00:11:35.784+0000","dateUpdated":"2017-01-23 19:41:44.491+0000","dateShipped":"2014-03-04 00:00:00.000+0000","accountId":"100414901","fixedIPAddress":null,"operatorCustom1":"","operatorCustom2":"","operatorCustom3":"","operatorCustom4":"","operatorCustom5":"","accountCustom1":"","accountCustom2":"","accountCustom3":"","accountCustom4":"","accountCustom5":"","accountCustom6":"","accountCustom7":"","accountCustom8":"","accountCustom9":"","accountCustom10":"","customerCustom1":"","customerCustom2":"","customerCustom3":"","customerCustom4":"","customerCustom5":"","simNotes":null,"deviceID":"Controls Lab/Simulator","modemID":"00600c:816eec","globalSimType":""}';
                        }
                        resp.setBody(testResponseData);
                    }
                    else if (req.getMethod() == 'PUT') {
                        if (!String.isEmpty(req.getBody()) && req.getHeader('Content-Type') == 'application/json')
                        {
                            resp.setStatusCode(200);
                            resp.setBody('{"iccid":"89011704258018735310"}');
                        }
                        else 
                            resp.setStatusCode(405);
                    }
                    else if (req.getMethod() == 'POST') {
                        if (!String.isEmpty(req.getBody()) && req.getHeader('Content-Type') == 'application/json')
                            resp.setStatusCode(201);
                        else 
                            resp.setStatusCode(405);
                    }
                    else {
                        resp.setStatusCode(405);
                    }
                } else {
                    resp.setStatusCode(401);
                }
            } else {
                resp.setStatusCode(404);
            }
            return resp;
        }
    }


	@isTest static void test_getDeviceByICCID() {
        list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
		String endPoint = BASEURL + 'devices' + '/' + TESTDEVICEICCID;
		HttpCalloutMockImpl mock = new HttpCalloutMockImpl (BASEURL, APIKEY, ENTERPRISE_ACCOUNTID, JASPERCC_USERNAME, 'devices', TESTDEVICEICCID, endPoint);

		Blob headerValue = Blob.valueOf(JASPERCC_USERNAME + ':' + APIKEY);
	    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
	    String testResponseData = '{"iccid":"89011704258018735310","imsi":"310170801873531","msisdn":"882350801873531","imei":"351579050703680","status":"ACTIVATION_READY","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA","customer":"Daikin Test","endConsumerId":null,"dateActivated":"2015-01-30 20:18:11.755+0000","dateAdded":"2014-02-14 00:11:35.784+0000","dateUpdated":"2017-01-23 19:41:44.491+0000","dateShipped":"2014-03-04 00:00:00.000+0000","accountId":"100414901","fixedIPAddress":null,"operatorCustom1":"","operatorCustom2":"","operatorCustom3":"","operatorCustom4":"","operatorCustom5":"","accountCustom1":"","accountCustom2":"","accountCustom3":"","accountCustom4":"","accountCustom5":"","accountCustom6":"","accountCustom7":"","accountCustom8":"","accountCustom9":"","accountCustom10":"","customerCustom1":"","customerCustom2":"","customerCustom3":"","customerCustom4":"","customerCustom5":"","simNotes":null,"deviceID":"Controls Lab/Simulator","modemID":"00600c:816eec","globalSimType":""}';
		String testRequestData = '\nGET ' + endPoint;
		testRequestData += '\nHeaders';
		testRequestData += '\n--------';
		testRequestData += '\nAuthorization: ' + authorizationHeader;
		testRequestData += '\nAccept: ' + 'application/json';
		testRequestData += '\nBody';
		testRequestData += '\n-----';
		testRequestData += '\n[none]\n';

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock );
            IERenewal_ATTJasperAPIServiceResponseObj respObj = new IERenewal_ATTJasperAPIServiceResponseObj();
			IERenewal_ATTJasperAPIServiceAccess restGetDevice = new IERenewal_ATTJasperAPIServiceAccess(BASEURL, APIKEY, 'devices', JASPERCC_USERNAME, ENTERPRISE_ACCOUNTID);
			respObj = restGetDevice.getDeviceByICCID(TESTDEVICEICCID, integrationErrorList);
        Test.stopTest();

        System.assertEquals(200, respObj.getResponseCode(), 'If the endpoint is valid and header has the correct API, the mock class should return 200');
        System.assertEquals(null, respObj.getResponseMessage(), 'Since the response message is not set, the mock class should return null');
        System.assertEquals(testResponseData, respObj.getResponseData(), 'Response data is not correct!');
        System.assertEquals(testRequestData, respObj.getRequestData(), 'Request data is not correct!');
	}


	@isTest static void test_getDevicesByAccountID() {
        list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
		String modifiedSinceDate = '2016-12-18T17%3A31%3A34%2B00%3A00';
		String simFilterStatus = 'ACTIVATED';
		String endPoint = BASEURL + 'devices' + '?accountId=' + ENTERPRISE_ACCOUNTID + '&modifiedSince=' + modifiedSinceDate + '&status=' + simFilterStatus + '&pageSize=50&pageNumber=1';
		HttpCalloutMockImpl mock = new HttpCalloutMockImpl (BASEURL, APIKEY, ENTERPRISE_ACCOUNTID, JASPERCC_USERNAME, 'devices', TESTDEVICEICCID, endPoint);

		Blob headerValue = Blob.valueOf(JASPERCC_USERNAME + ':' + APIKEY);
	    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
	    String testResponseData = '{"pageNumber":1,"devices":[{"iccid":"89011704258018734891","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018734826","status":"ACTIVATED","ratePlan":"Daikin Applied - 1GB US_CAN_MEX Plan","communicationPlan":"Daikin Applied - AT&T Data MT - INT"},{"iccid":"89011704258018735021","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252319572027","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618545","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429471","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619287","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305617448","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305617927","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618495","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619378","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618842","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018735187","status":"ACTIVATED","ratePlan":"Daikin Applied - 10MB US_CAN_MEX Plan","communicationPlan":"Daikin Applied - AT&T Data MT - INT"},{"iccid":"89011704252305618958","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619410","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429083","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252306820793","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619501","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619352","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252319571565","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619121","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618719","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018734131","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618487","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618610","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618982","status":"ACTIVATED","ratePlan":"Daikin Applied - 500MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018734230","status":"ACTIVATED","ratePlan":"Daikin Applied - 20MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018734602","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618685","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018734198","status":"ACTIVATED","ratePlan":"Daikin Applied - 20MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305617596","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619519","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618784","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252319571847","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619246","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619436","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429133","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619386","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429281","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429174","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619444","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619014","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305617703","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618834","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305429836","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704258018733802","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305619261","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618180","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252306820397","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"},{"iccid":"89011704252305618792","status":"ACTIVATED","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"}],"lastPage":false}';
		String testRequestData = '\nGET ' + endPoint;
		testRequestData += '\nHeaders';
		testRequestData += '\n--------';
		testRequestData += '\nAuthorization: ' + authorizationHeader;
		testRequestData += '\nAccept: ' + 'application/json';
		testRequestData += '\nBody';
		testRequestData += '\n-----';
		testRequestData += '\n[none]\n';

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock );
            IERenewal_ATTJasperAPIServiceResponseObj respObj = new IERenewal_ATTJasperAPIServiceResponseObj();
			IERenewal_ATTJasperAPIServiceAccess restGetDevices = new IERenewal_ATTJasperAPIServiceAccess(BASEURL, APIKEY, 'devices', JASPERCC_USERNAME, ENTERPRISE_ACCOUNTID);
			respObj = restGetDevices.getDevicesByAccountID(modifiedSinceDate, simFilterStatus, integrationErrorList);
        Test.stopTest();

        System.assertEquals(200, respObj.getResponseCode(), 'If the endpoint is valid and header has the correct API, the mock class should return 200');
        System.assertEquals(null, respObj.getResponseMessage(), 'Since the response message is not set, the mock class should return null');
        System.assertEquals(testResponseData, respObj.getResponseData(), 'Response data is not correct!');
        System.assertEquals(testRequestData, respObj.getRequestData(), 'Request data is not correct!');
	}


	@isTest static void test_updateDeviceByICCID1() {
        list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
		String endPoint = BASEURL + 'devices' + '/' + TESTDEVICEICCID;
		HttpCalloutMockImpl mock = new HttpCalloutMockImpl (BASEURL, APIKEY, ENTERPRISE_ACCOUNTID, JASPERCC_USERNAME, 'devices', TESTDEVICEICCID, endPoint);

		String status = 'ACTIVATION_READY';
		//String ratePlan = 'Daikin Applied - 50MB Plan';
        //String communicationPlan = 'Daikin Applied - AT&T Data MT - IFA';
		//String customer = 'Daikin Test';
		String deviceID = 'Controls Lab/Simulator';
		String modemID = '00600c:816eec';
		IERenewal_ATTJasperAPIServiceAccess.IE_Device_Request4 ieDevicePut = new IERenewal_ATTJasperAPIServiceAccess.IE_Device_Request4();
		ieDevicePut.status = status;
		//ieDevicePut.ratePlan = ratePlan;
        //ieDevicePut.communicationPlan = communicationPlan;
		//ieDevicePut.customer = customer;
		ieDevicePut.deviceID = deviceID;
		ieDevicePut.modemID = modemID;
		String jsonBody = JSON.serialize(ieDevicePut);
		// {"status":"ACTIVATION_READY","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA","modemID":"00600c:816eec","deviceID":"Controls Lab/Simulator","customer":"Daikin Test"}


		Blob headerValue = Blob.valueOf(JASPERCC_USERNAME + ':' + APIKEY);
	    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
	    String testResponseData = '{"iccid":"89011704258018735310"}';
		String testRequestData = '\nPUT ' + endPoint;
		testRequestData += '\nHeaders';
		testRequestData += '\n--------';
		testRequestData += '\nAuthorization: ' + authorizationHeader;
		testRequestData += '\nAccept: ' + 'application/json';
		testRequestData += '\nContent-Type: ' + 'application/json';
		testRequestData += '\nBody';
		testRequestData += '\n-----';
		testRequestData += '\n' + jsonBody + '\n';

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock );
            IERenewal_ATTJasperAPIServiceResponseObj respObj = new IERenewal_ATTJasperAPIServiceResponseObj();
			IERenewal_ATTJasperAPIServiceAccess restPutDevice = new IERenewal_ATTJasperAPIServiceAccess(BASEURL, APIKEY, 'devices', JASPERCC_USERNAME, ENTERPRISE_ACCOUNTID);
			respObj = restPutDevice.updateDeviceByICCID(TESTDEVICEICCID, status, null, null, null, deviceID, modemID, integrationErrorList);
        Test.stopTest();

        System.assertEquals(200, respObj.getResponseCode(), 'If the endpoint is valid and header has the correct API, the mock class should return 200');
        System.assertEquals(null, respObj.getResponseMessage(), 'Since the response message is not set, the mock class should return null');
        System.assertEquals(testResponseData, respObj.getResponseData(), 'Response data is not correct!');
        System.assertEquals(testRequestData, respObj.getRequestData(), 'Request data is not correct!');
	}


    @isTest static void test_updateDeviceByICCID2() {
        list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
        String endPoint = BASEURL + 'devices' + '/' + TESTDEVICEICCID;
        HttpCalloutMockImpl mock = new HttpCalloutMockImpl (BASEURL, APIKEY, ENTERPRISE_ACCOUNTID, JASPERCC_USERNAME, 'devices', TESTDEVICEICCID, endPoint);

        //String status = 'ACTIVATION_READY';
        //String ratePlan = 'Daikin Applied - 50MB Plan';
        //String communicationPlan = 'Daikin Applied - AT&T Data MT - IFA';
        //String customer = 'Daikin Test';
        String deviceID = 'Controls Lab/Simulator';
        String modemID = '00600c:816eec';
        IERenewal_ATTJasperAPIServiceAccess.IE_Device_Request2 ieDevicePut = new IERenewal_ATTJasperAPIServiceAccess.IE_Device_Request2();
        //ieDevicePut.status = status;
        //ieDevicePut.ratePlan = ratePlan;
        //ieDevicePut.communicationPlan = communicationPlan;
        //ieDevicePut.customer = customer;
        ieDevicePut.deviceID = deviceID;
        ieDevicePut.modemID = modemID;
        String jsonBody = JSON.serialize(ieDevicePut);
        // {"modemID":"00600c:816eec","deviceID":"Controls Lab/Simulator","customer":"Daikin Test"}


        Blob headerValue = Blob.valueOf(JASPERCC_USERNAME + ':' + APIKEY);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String testResponseData = '{"iccid":"89011704258018735310"}';
        String testRequestData = '\nPUT ' + endPoint;
        testRequestData += '\nHeaders';
        testRequestData += '\n--------';
        testRequestData += '\nAuthorization: ' + authorizationHeader;
        testRequestData += '\nAccept: ' + 'application/json';
        testRequestData += '\nContent-Type: ' + 'application/json';
        testRequestData += '\nBody';
        testRequestData += '\n-----';
        testRequestData += '\n' + jsonBody + '\n';

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock );
            IERenewal_ATTJasperAPIServiceResponseObj respObj = new IERenewal_ATTJasperAPIServiceResponseObj();
            IERenewal_ATTJasperAPIServiceAccess restPutDevice = new IERenewal_ATTJasperAPIServiceAccess(BASEURL, APIKEY, 'devices', JASPERCC_USERNAME, ENTERPRISE_ACCOUNTID);
            respObj = restPutDevice.updateDeviceByICCID(TESTDEVICEICCID, null, null, null, null, deviceID, modemID, integrationErrorList);
        Test.stopTest();

        System.assertEquals(200, respObj.getResponseCode(), 'If the endpoint is valid and header has the correct API, the mock class should return 200');
        System.assertEquals(null, respObj.getResponseMessage(), 'Since the response message is not set, the mock class should return null');
        System.assertEquals(testResponseData, respObj.getResponseData(), 'Response data is not correct!');
        System.assertEquals(testRequestData, respObj.getRequestData(), 'Request data is not correct!');
    }


    @isTest static void test_updateDeviceByICCID3() {
        list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
        String endPoint = BASEURL + 'devices' + '/' + TESTDEVICEICCID;
        HttpCalloutMockImpl mock = new HttpCalloutMockImpl (BASEURL, APIKEY, ENTERPRISE_ACCOUNTID, JASPERCC_USERNAME, 'devices', TESTDEVICEICCID, endPoint);

        String status = 'ACTIVATION_READY';
        //String ratePlan = 'Daikin Applied - 50MB Plan';
        //String communicationPlan = 'Daikin Applied - AT&T Data MT - IFA';
        //String customer = 'Daikin Test';
        //String deviceID = 'Controls Lab/Simulator';
        //String modemID = '00600c:816eec';
        IERenewal_ATTJasperAPIServiceAccess.IE_Device_Request1 ieDevicePut = new IERenewal_ATTJasperAPIServiceAccess.IE_Device_Request1();
        ieDevicePut.status = status;
        //ieDevicePut.ratePlan = ratePlan;
        //ieDevicePut.communicationPlan = communicationPlan;
        //ieDevicePut.customer = customer;
        //ieDevicePut.deviceID = deviceID;
        //ieDevicePut.modemID = modemID;
        String jsonBody = JSON.serialize(ieDevicePut);
        // {"status":"ACTIVATION_READY"}


        Blob headerValue = Blob.valueOf(JASPERCC_USERNAME + ':' + APIKEY);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String testResponseData = '{"iccid":"89011704258018735310"}';
        String testRequestData = '\nPUT ' + endPoint;
        testRequestData += '\nHeaders';
        testRequestData += '\n--------';
        testRequestData += '\nAuthorization: ' + authorizationHeader;
        testRequestData += '\nAccept: ' + 'application/json';
        testRequestData += '\nContent-Type: ' + 'application/json';
        testRequestData += '\nBody';
        testRequestData += '\n-----';
        testRequestData += '\n' + jsonBody + '\n';

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock );
            IERenewal_ATTJasperAPIServiceResponseObj respObj = new IERenewal_ATTJasperAPIServiceResponseObj();
            IERenewal_ATTJasperAPIServiceAccess restPutDevice = new IERenewal_ATTJasperAPIServiceAccess(BASEURL, APIKEY, 'devices', JASPERCC_USERNAME, ENTERPRISE_ACCOUNTID);
            respObj = restPutDevice.updateDeviceByICCID(TESTDEVICEICCID, status, null, null, null, null, null, integrationErrorList);
        Test.stopTest();

        System.assertEquals(200, respObj.getResponseCode(), 'If the endpoint is valid and header has the correct API, the mock class should return 200');
        System.assertEquals(null, respObj.getResponseMessage(), 'Since the response message is not set, the mock class should return null');
        System.assertEquals(testResponseData, respObj.getResponseData(), 'Response data is not correct!');
        System.assertEquals(testRequestData, respObj.getRequestData(), 'Request data is not correct!');
    }


	/*
    @isTest static void test_updateDeviceByICCID4() {
        list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
        String endPoint = BASEURL + 'devices' + '/' + TESTDEVICEICCID;
        HttpCalloutMockImpl mock = new HttpCalloutMockImpl (BASEURL, APIKEY, ENTERPRISE_ACCOUNTID, JASPERCC_USERNAME, 'devices', TESTDEVICEICCID, endPoint);

        //String status = 'ACTIVATION_READY';
        String ratePlan = 'Daikin Applied - 50MB Plan';
        String communicationPlan = 'Daikin Applied - AT&T Data MT - IFA';
        //String customer = 'Daikin Test';
        //String deviceID = 'Controls Lab/Simulator';
        //String modemID = '00600c:816eec';
        IERenewal_ATTJasperAPIServiceAccess.IE_Device_Request3 ieDevicePut = new IERenewal_ATTJasperAPIServiceAccess.IE_Device_Request3();
        //ieDevicePut.status = status;
        ieDevicePut.ratePlan = ratePlan;
        ieDevicePut.communicationPlan = communicationPlan;
        //ieDevicePut.customer = customer;
        //ieDevicePut.deviceID = deviceID;
        //ieDevicePut.modemID = modemID;
        String jsonBody = JSON.serialize(ieDevicePut);
        // {"ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA"}


        Blob headerValue = Blob.valueOf(JASPERCC_USERNAME + ':' + APIKEY);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String testResponseData = '{"iccid":"89011704258018735310"}';
        String testRequestData = '\nPUT ' + endPoint;
        testRequestData += '\nHeaders';
        testRequestData += '\n--------';
        testRequestData += '\nAuthorization: ' + authorizationHeader;
        testRequestData += '\nAccept: ' + 'application/json';
        testRequestData += '\nContent-Type: ' + 'application/json';
        testRequestData += '\nBody';
        testRequestData += '\n-----';
        testRequestData += '\n' + jsonBody + '\n';

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock );
            IERenewal_ATTJasperAPIServiceResponseObj respObj = new IERenewal_ATTJasperAPIServiceResponseObj();
            IERenewal_ATTJasperAPIServiceAccess restPutDevice = new IERenewal_ATTJasperAPIServiceAccess(BASEURL, APIKEY, 'devices', JASPERCC_USERNAME, ENTERPRISE_ACCOUNTID);
            respObj = restPutDevice.updateDeviceByICCID(TESTDEVICEICCID, null, ratePlan, communicationPlan, null, null, null, integrationErrorList);
        Test.stopTest();

        System.assertEquals(200, respObj.getResponseCode(), 'If the endpoint is valid and header has the correct API, the mock class should return 200');
        System.assertEquals(null, respObj.getResponseMessage(), 'Since the response message is not set, the mock class should return null');
        System.assertEquals(testResponseData, respObj.getResponseData(), 'Response data is not correct!');
        System.assertEquals(testRequestData, respObj.getRequestData(), 'Request data is not correct!');
    }*/


}