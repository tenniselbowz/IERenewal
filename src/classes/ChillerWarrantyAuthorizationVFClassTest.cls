@isTest
public class ChillerWarrantyAuthorizationVFClassTest {
    
    @isTest
   static void cwac_Method()
        
    {
       
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        Account a = new Account(Name = 'Test'
                    , IE_Sync_Status__c = 'Pending'
                    , IE_ID__c = '123'
                    , IE_Account__c = true
                    );
        insert a;
        
        Account a2 = new Account(Name = 'Test'
                                , IE_Sync_Status__c = 'Pending'
                                , BillingStreet = '1234\n4567\n8910'
                                , BillingCity = 'Mlps'
                                , BIllingState = 'Minnesota'
                                , BillingCountry = 'United States'
                                , BillingPostalCode = '55441'
                                );
        insert a2;
        Contact con = new Contact();
        con.LastName = 'Solunus Test Contact';
        con.Email = 'solunus@test.com';
        con.phone = '08038290232';
        con.AccountId = a.id;
        insert con;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
        Id RecordTypeIdChildCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();

        Product2 pd = new Product2();
        pd.Vendor_Supplier_Long__c = 'Daikin Applied Americas INC';
        pd.Vendor_Supplier__c = 'DA US';
        pd.Product_Category__c = 'Light Commercial';
        pd.Product_Sub_Category__c = 'Light Commercial';
        pd.Product_Group__c = 'DPS';
        pd.Name = 'Package System';
        pd.Description = 'Package System';
        pd.TRC_Group__c = 'TRC - AAH';
        pd.Apttus_Config2__ConfigurationType__c = 'Standalone';
        pd.DW_Product_Business_Unit__c = 'Applied Air Handler';
        pd.DW_Product_Family__c = 'Rooftop Systems';
        pd.DW_PCL_Description__c  = 'REBEL RT UNIT';
        pd.DW_Product_Class__c = '0425';
        pd.DW_Product_Line__c = 'Rebel [DPS]';
        insert pd;
        
        Asset ast = new Asset();
        ast.AccountId = a2.id;
        ast.ContactId = con.id;
        ast.Name = 'Test Asset';
        ast.SerialNumber = 'FB86J17878123';
        ast.Product2Id = pd.id;
        insert ast;
         Asset ast1 = new Asset();
        ast1.AccountId = a2.id;
        ast1.ContactId = con.id;
        ast1.Name = 'Test Asset';
        ast1.SerialNumber = 'FB86J17871458123';
        ast1.Product2Id = pd.id;
        insert ast1;
        
        Case pcase = new Case();
        pcase.Origin = 'Email';
        pcase.Subject = 'Test Soluns';
        pcase.AccountId = a2.id;
        pcase.Status = 'Warranty Review';
        pcase.Case_Category__c = 'Claim';
        pcase.RecordTypeId = RecordTypeIdCase;
        insert pcase;
        

        
        Case case1 = new Case();
        case1.RecordTypeId = RecordTypeIdChildCase;
        case1.ParentId = pcase.id;
        case1.Origin = 'Email';
        case1.Subject = 'Test Soluns';
        case1.AccountId = a2.id;
        case1.Status = 'Warranty Review';
        case1.Case_Category__c = 'Claim';
        case1.AssetId = ast.id;
        case1.Hours_Approved__c = 12.0;
        case1.Labor_Amount_Approved__c = 200;
        case1.Additional_Materials_Amount_Approved__c = 120;
        case1.X3rd_Party_Parts_Amount_Approved__c = 90;
        case1.Daikin_Parts_Amount_Approved__c = 92;
        insert case1;
        //CaseNumber,Hours_Approved__c,Labor_Amount_Approved__c,Additional_Materials_Amount_Approved__c,X3rd_Party_Parts_Amount_Approved__c,Daikin_Parts_Amount_Approved__c
        Case case2 = new Case();
        case2.RecordTypeId = RecordTypeIdChildCase;
        case2.ParentId = pcase.id;
        case2.Origin = 'Email';
        case2.Subject = 'Test Soluns';
        case2.AccountId = a2.id;
        case2.ContactId = con.id;
        case2.Status = 'Warranty Review';
        case2.Case_Category__c = 'Claim';
        case2.AssetId = ast1.id;
        case2.Hours_Approved__c = 12.0;
        case2.Labor_Amount_Approved__c = 200;
        case2.Additional_Materials_Amount_Approved__c = 120;
        case2.X3rd_Party_Parts_Amount_Approved__c = 90;
        case2.Daikin_Parts_Amount_Approved__c = 92;
        insert case2;
        
       /* Case_Service_Code__c cscode = new Case_Service_Code__c();
        cscode.Case__c = case1.id;
        cscode.Hours_Approved__c = 20.00;
        cscode.Labor_Amount_Approved__c = 2000;
        cscode.Additional_Materials_Amount_Approved__c = 120;
        cscode.X3rd_Party_Parts_Amount_Approved__c = 40;
        cscode.Daikin_Parts_Amount_Approved__c = 60;
        insert cscode;
        System.debug('Warranty class'+cscode.WarrantyClassCode__c);*/
      
        List<Case> caseToDisplay = new List<Case>();
      
        List<Case> cases = [SELECT Id,(SELECT Id,Serial_Number__c,CaseNumber,Hours_Approved__c,Labor_Amount_Approved__c,Additional_Materials_Amount_Approved__c,X3rd_Party_Parts_Amount_Approved__c,Daikin_Parts_Amount_Approved__c from Cases) FROM Case WHERE Case.Id=:pcase.id];
        Set<Id> csid = new Set<Id>();
        Map<String, List<Case_Service_Code__c>> cscodeList = new Map<String, List<Case_Service_Code__c>>();
        List<Case_Service_Code__c> csccodes = [SELECT Id, Name,Case__c,WarrantyClassCode__r.Name,Asset_PCL__c,WarrantyClassCode__r.Label__c FROM Case_Service_Code__c where Case__c IN :caseToDisplay];
        for(Case_Service_Code__c ccv :csccodes)
        {
            if(cscodeList.containsKey(ccv.Case__c)){
                cscodeList.get(ccv.Case__c).add(ccv);    
            }else{
                cscodeList.put(ccv.Case__c, new List<Case_Service_Code__c>{ccv});  
            }
        }
        
        
        test.startTest();
        ChillerWarrantyAuthorizationVFClass caseController = new ChillerWarrantyAuthorizationVFClass();
        caseController.caseIdValue=pcase.Id;
		List<case> caseList=caseController.casess;
        List<case> caseList1=caseController.warrantyChildcasess;
        case caseObj=caseController.caseValues;   
    	cscodeList = caseController.getservicecodes;
        caseController.csid = csid;
      
        test.stopTest();
        
    }

}