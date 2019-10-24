/* Class to access the Warranty REST Web Service published by Oracle EBS to query and maintain the warranty repository */

public with sharing class DaikinOracleEBSWarrantyServiceAccess  {
    private String oAuthTokenUrl;
    private String warrantyFunctionUrl;
    private String password;
    private String userName;
    private String getTokenService;
    private String getWarrInfoService;
    private String getStartupDatesService;
    private String setStartupDatesService;


    public DaikinOracleEBSWarrantyServiceAccess(String oAuthTokenUrl, String warrantyFunctionUrl, String password, String userName, String getTokenService, String getWarrInfoService, String getStartupDatesService, String setStartupDatesService) {
        this.oAuthTokenUrl = oAuthTokenUrl;
        this.warrantyFunctionUrl = warrantyFunctionUrl;
        this.password = password;
        this.userName = userName;
        this.getTokenService = getTokenService;
        this.getWarrInfoService = getWarrInfoService;
        this.getStartupDatesService = getStartupDatesService;
        this.setStartupDatesService = setStartupDatesService;
    }


    public HTTPResponse getClientOAuthToken(list<Integration_Error__c> integrationErrorList) {
        HTTPResponse resp = null;
        String requestToString = null;

        try {
            // For example,
            // oAuthTokenUrl = https://oracle<instance>.daikinapplied.com/ords/war/oauth/
            // getTokenService = token

            HTTPRequest r = new HTTPRequest();
            String endPoint = oAuthTokenUrl + getTokenService + '?grant_type=client_credentials';

            //use basic http authentication
            Blob headerValue = Blob.valueOf(userName + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

            r.setTimeOut(120000);
            r.setEndpoint(endPoint);
            r.setHeader('Authorization', authorizationHeader);
            r.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            r.setMethod('POST');

            HTTP auth = new HTTP();
            resp = auth.send(r);


            requestToString = '\nPOST ' + endPoint;
            requestToString += '\nHeaders';
            requestToString += '\n--------';
            requestToString += '\nAuthorization: ' + authorizationHeader;
            requestToString += '\nContent-Type: ' + 'application/x-www-form-urlencoded';
            requestToString += '\nBody';
            requestToString += '\n-----';
            requestToString += '\n[none]\n';


            if (resp.getStatusCode() != 200) {
                // Not successful
                // log the error
                integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                        , Error_Description__c = trim('Transmission Error ['+resp.getStatusCode()+' ] '+'-'+resp.getBody(), 10000)
                                        , Integration_Object__c = 'Oracle EBS Warranty Service'
                                        , Integration_Point__c = 'Oracle'
                                        , Request_Data__c = requestToString ));
            }

            System.debug(LoggingLevel.ERROR, 'getClientOAuthToken: ' + resp.getStatusCode());
            System.debug(LoggingLevel.ERROR, 'getClientOAuthToken: ' + resp.getBody());
        }
        catch (Exception ex) {
            //log the error
            System.debug(LoggingLevel.ERROR, 'getClientOAuthToken: ' + ex);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                        , Error_Description__c = trim('CALLOUT_EXCEPTION: ' + ex.getMessage(), 10000)
                                        , Integration_Object__c = 'Oracle EBS Warranty Service'
                                        , Integration_Point__c = 'Oracle'
                                        , Request_Data__c = requestToString ));
        }

        if (integrationErrorList.size() > 0)
            System.debug(LoggingLevel.ERROR, 'getClientOAuthToken: ' + integrationErrorList);


        return resp;
    }


    public HTTPResponse findWarrantyInformation(String orderNumber, String serialNumber, String token, list<Integration_Error__c> integrationErrorList) {
        HTTPResponse resp = null;
        String requestToString = null;

        try {
            // For example,
            // warrantyFunctionUrl = https://oracle<instance>.daikinapplied.com/ords/war/warranty/v1/
            // getWarrInfoService = find

            String jsonBody = null;
            HTTPRequest r = new HTTPRequest();
            String endPoint = warrantyFunctionUrl + getWarrInfoService;

            //use bearer token authentication
            String authorizationHeader = 'Bearer ' + token;

            //create the json body
            FindWarrantyRequest wReq = new FindWarrantyRequest();
            wReq.order_number = orderNumber;
            wReq.serial_number = serialNumber;
            jsonBody = JSON.serialize(wReq);

            r.setTimeOut(120000);
            r.setEndpoint(endPoint);
            r.setHeader('Authorization', authorizationHeader);
            r.setHeader('Content-Type', 'application/json');
            r.setMethod('POST');
            r.setBody(jsonBody);

            HTTP auth = new HTTP();
            resp = auth.send(r);


            requestToString = '\nPOST ' + endPoint;
            requestToString += '\nHeaders';
            requestToString += '\n--------';
            requestToString += '\nAuthorization: ' + authorizationHeader;
            requestToString += '\nContent-Type: ' + 'application/json';
            requestToString += '\nBody';
            requestToString += '\n-----';
            requestToString += '\n' + jsonBody + '\n';


            if (resp.getStatusCode() != 200) {
                // Not successful
                // log the error
                integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                        , Error_Description__c = trim('Transmission Error ['+resp.getStatusCode()+' ] '+'-'+resp.getBody(), 10000)
                                        , Integration_Object__c = 'Oracle EBS Warranty Service'
                                        , Integration_Point__c = 'Oracle'
                                        , Request_Data__c = requestToString ));
            }

            System.debug(LoggingLevel.ERROR, 'findWarrantyInformation: ' + resp.getStatusCode());
            System.debug(LoggingLevel.ERROR, 'findWarrantyInformation: ' + resp.getBody());
        }
        catch (Exception ex) {
            //log the error
            System.debug(LoggingLevel.ERROR, 'findWarrantyInformation: ' + ex);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                        , Error_Description__c = trim('CALLOUT_EXCEPTION: ' + ex.getMessage(), 10000)
                                        , Integration_Object__c = 'Oracle EBS Warranty Service'
                                        , Integration_Point__c = 'Oracle'
                                        , Request_Data__c = requestToString ));
        }

        if (integrationErrorList.size() > 0)
            System.debug(LoggingLevel.ERROR, 'findWarrantyInformation: ' + integrationErrorList);


        return resp;
    }


    public HTTPResponse getStartupDates(String orderNumber, String serialNumber, String token, list<Integration_Error__c> integrationErrorList) {
        HTTPResponse resp = null;
        String requestToString = null;

        try {
            // For example,
            // warrantyFunctionUrl = https://oracle<instance>.daikinapplied.com/ords/war/warranty/v1/
            // getStartupDatesService = getStartupDates

            String jsonBody = null;
            HTTPRequest r = new HTTPRequest();
            String endPoint = warrantyFunctionUrl + getStartupDatesService;

            //use bearer token authentication
            String authorizationHeader = 'Bearer ' + token;

            //create the json body
            GetStartupDatesRequest wReq = new GetStartupDatesRequest();
            wReq.order_number = orderNumber;
            wReq.serial_number = serialNumber;
            jsonBody = JSON.serialize(wReq);

            r.setTimeOut(120000);
            r.setEndpoint(endPoint);
            r.setHeader('Authorization', authorizationHeader);
            r.setHeader('Content-Type', 'application/json');
            r.setMethod('POST');
            r.setBody(jsonBody);

            HTTP auth = new HTTP();
            resp = auth.send(r);


            requestToString = '\nPOST ' + endPoint;
            requestToString += '\nHeaders';
            requestToString += '\n--------';
            requestToString += '\nAuthorization: ' + authorizationHeader;
            requestToString += '\nContent-Type: ' + 'application/json';
            requestToString += '\nBody';
            requestToString += '\n-----';
            requestToString += '\n' + jsonBody + '\n';


            if (resp.getStatusCode() != 200) {
                // Not successful
                // log the error
                integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                        , Error_Description__c = trim('Transmission Error ['+resp.getStatusCode()+' ] '+'-'+resp.getBody(), 10000)
                                        , Integration_Object__c = 'Oracle EBS Warranty Service'
                                        , Integration_Point__c = 'Oracle'
                                        , Request_Data__c = requestToString ));
            }

            System.debug(LoggingLevel.ERROR, 'getStartupDates: ' + resp.getStatusCode());
            System.debug(LoggingLevel.ERROR, 'getStartupDates: ' + resp.getBody());
        }
        catch (Exception ex) {
            //log the error
            System.debug(LoggingLevel.ERROR, 'getStartupDates: ' + ex);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                        , Error_Description__c = trim('CALLOUT_EXCEPTION: ' + ex.getMessage(), 10000)
                                        , Integration_Object__c = 'Oracle EBS Warranty Service'
                                        , Integration_Point__c = 'Oracle'
                                        , Request_Data__c = requestToString ));
        }

        if (integrationErrorList.size() > 0)
            System.debug(LoggingLevel.ERROR, 'getStartupDates: ' + integrationErrorList);


        return resp;
    }


    public HTTPResponse setStartupDates(SetStartupDatesRequest req, String token, list<Integration_Error__c> integrationErrorList) {
        HTTPResponse resp = null;
        String requestToString = null;

        try {
            // For example,
            // warrantyFunctionUrl = https://oracle<instance>.daikinapplied.com/ords/war/warranty/v1/
            // setStartupDatesService = setStartupDates

            String jsonBody = null;
            HTTPRequest r = new HTTPRequest();
            String endPoint = warrantyFunctionUrl + setStartupDatesService;

            //use bearer token authentication
            String authorizationHeader = 'Bearer ' + token;

            //create the json body
            jsonBody = JSON.serialize(req);

            r.setTimeOut(120000);
            r.setEndpoint(endPoint);
            r.setHeader('Authorization', authorizationHeader);
            r.setHeader('Content-Type', 'application/json');
            r.setMethod('POST');
            r.setBody(jsonBody);

            HTTP auth = new HTTP();
            resp = auth.send(r);


            requestToString = '\nPOST ' + endPoint;
            requestToString += '\nHeaders';
            requestToString += '\n--------';
            requestToString += '\nAuthorization: ' + authorizationHeader;
            requestToString += '\nContent-Type: ' + 'application/json';
            requestToString += '\nBody';
            requestToString += '\n-----';
            requestToString += '\n' + jsonBody + '\n';


            if (resp.getStatusCode() != 200) {
                // Not successful
                // log the error
                integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                        , Error_Description__c = trim('Transmission Error ['+resp.getStatusCode()+' ] '+'-'+resp.getBody(), 10000)
                                        , Integration_Object__c = 'Oracle EBS Warranty Service'
                                        , Integration_Point__c = 'Oracle'
                                        , Request_Data__c = requestToString ));
            }

            System.debug(LoggingLevel.ERROR, 'setStartupDates: ' + resp.getStatusCode());
            System.debug(LoggingLevel.ERROR, 'setStartupDates: ' + resp.getBody());
        }
        catch (Exception ex) {
            //log the error
            System.debug(LoggingLevel.ERROR, 'setStartupDates: ' + ex);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                        , Error_Description__c = trim('CALLOUT_EXCEPTION: ' + ex.getMessage(), 10000)
                                        , Integration_Object__c = 'Oracle EBS Warranty Service'
                                        , Integration_Point__c = 'Oracle'
                                        , Request_Data__c = requestToString ));
        }

        if (integrationErrorList.size() > 0)
            System.debug(LoggingLevel.ERROR, 'setStartupDates: ' + integrationErrorList);


        return resp;
    }






    //------Request Objects---------------

    public class FindWarrantyRequest
    {
        public string order_number{get;set;}
        public string serial_number{get;set;}
    }

    public class GetStartupDatesRequest
    {
        public string order_number{get;set;}
        public string serial_number{get;set;}
    }

    public class SetStartupDatesRequest
    {
        public list<OrderLine2> order_lines{get;set;}  // Payload - List of order lines
    }

    public class OrderLine2
    {
        public String order_number{get;set;}
        public String serial_number{get;set;}
        public String startup_date{get;set;}
    }




    //------Response Objects--------------

    public class ClientOAuthTokenResponse
    {
        public String access_token{get;set;}  // authentication token used in all the web service calls
        public String token_type{get;set;}  // bearer
        public Integer expires_in{get;set;}  // how long the token is valid for (ie, 3600 sec or 1 hour)
    }


    //----

    public class WarrantyInformationResponse
    {
        public String status{get;set;}  // S (Success) or E (Error) 
        public String message{get;set;}  // An optional error message
        public list<OrderWarranty> orders{get;set;}  // List of orders that match the query
    }

    public class OrderWarranty
    {
        public OrderLevelInfo order_info{get;set;}  // Includes Order Level Information
        public list<Line> lines{get;set;}  // List of Lines for an order
    }

    public class OrderLevelInfo
    {
        public String operating_unit{get;set;}
        public String order_number{get;set;}
        public String order_source{get;set;}
        public String source_order_number{get;set;}
        public String ordered_date{get;set;}
        public String job_name{get;set;}
        public String customer_name{get;set;}
        public String customer_number{get;set;}
    }

    public class Line
    {
        public LineLevelInfo line_info{get;set;}  // Includes Line Level Information
        public List<Warranty> warranties{get;set;}  // List of warranties for a line
    }

    public class LineLevelInfo
    {
        public String source_line_number{get;set;}
        public String line_number{get;set;}
        public String ordered_item{get;set;}
        public String model{get;set;}
        public String pcl{get;set;}
        public String shipped_quantity{get;set;}
        public String serial_number{get;set;}
        public String ship_date{get;set;}
        public String ship_to_address1{get;set;}
        public String ship_to_address2{get;set;}
        public String ship_to_city{get;set;}
        public String ship_to_state{get;set;}
        public String ship_to_postal_code{get;set;}
        public String startup_date{get;set;}  // This attribute will not exist if a particular unit has not been started
        public String status{get;set;}
    }

    public class Warranty
    {
        public String warranty_item{get;set;}
        public String warranty_desc{get;set;}
        public String warranty_item_type{get;set;}
        public String warranty_type{get;set;}
        public String warranty_subtype{get;set;}
        public String warranty_start_date{get;set;}
        public String warranty_end_date{get;set;}
        public String warranty_status{get;set;}
    }


    //----

    public class GetStartupDatesResponse
    {
        public String status{get;set;}  // S (Success) or E (Error) 
        public String message{get;set;}  // An optional error message
        public list<OrderLine1> order_lines{get;set;}  // List of order lines that match the query
    }

    public class OrderLine1
    {
        public String order_number{get;set;}
        public String line_number{get;set;}
        public String shipment_number{get;set;}
        public String item_number{get;set;}
        public String model{get;set;}
        public String shipped_serial_number{get;set;}
        public String startup_date{get;set;}  // This attribute will not exist if a particular unit has not been started
    }


    //----

    public class SetStartupDatesResponse
    {
        public String status{get;set;}  // S (Success) or E (Error) or W (Warning) 
        public String message{get;set;}  // An optional error message
        public list<OrderLine3> order_lines{get;set;}  // List of order lines with update status
    }

    public class OrderLine3
    {
        public String order_number{get;set;}
        public String serial_number{get;set;}
        public String status{get;set;}
    }
    
    private String trim(String str, Integer len){
        if(str.length()>len){return str.substring(0, len);
        }
        return str;
    }

}