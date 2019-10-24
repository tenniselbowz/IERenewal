@isTest
public class CloneCaseWithCaseAssetControllerTest{
    
    public static testmethod void cloneCaseWithAsset(){
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        List<Case> caseList = TestingUtils.createCases(1,'Test Case',true);
    
        List<Account> accList = TestingUtils.createAccounts(1, 'Test Account', true);
    
        List<Asset> assetList = TestingUtils.createAssets(1,accList[0],false);    
        assetList[0].Intel_ID__c = 111;
        assetList[0].SerialNumber = 'ABCXYZ';
        insert AssetList;
    
        List<Case_Asset__c> caseAssetList = TestingUtils.createCaseAssets(caseList,assetList,false);
        caseAssetList[0].Asset__c = assetList[0].id;
        insert caseAssetList;
    
        CaseAssetFields__c ca = new CaseAssetFields__c();
        ca.Name ='Test';
        ca.API__c = 'Asset__c';
        insert ca;
    
        Test.startTest();
            PageReference pageRef = Page.CloneCaseWithCaseAsset;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(caseList[0]);
            ApexPages.currentPage().getParameters().put('id',caseList[0].Id);
            CloneCaseWithCaseAssetController ec = new CloneCaseWithCaseAssetController(sc);
            
            String newCaseId = ec.save();
            System.assertNotEquals(newCaseId,null);
            
       
            PageReference savePage = ec.saveCase();
            System.assertNotEquals(savePage.getURL(),null);
            
            PageReference saveAndNewPage = ec.saveAndNewCase();
            System.assertEquals('/setup/ui/recordtypeselect.jsp?ent=Case&retURL=%2F500%2Fo&save_new_url=%2F500%2Fe%3FretURL%3D%2F500%2Fo', saveAndNewPage.getURL());
            
            PageReference saveAndClosePage = ec.saveAndClose();
            System.assertNotEquals(saveAndClosePage.getURL(),null);
        Test.stopTest();

        Case newCase = [SELECT Id, Number_of_Tasks__c, Number_of_Events__c 
                        FROM Case 
                        WHERE Id = :newCaseId][0];
        System.assertEquals(0, newCase.Number_of_Tasks__c, 'This should be 0 by default');
        System.assertEquals(0, newCase.Number_of_Events__c, 'This should be 0 by default');
        
    }
}