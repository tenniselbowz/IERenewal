@isTest
public class ChangeOwnerTestClass {
    
    public static testMethod void changeOwnerUpdateMethod(){
        
        test.startTest();
        PageReference pageRef = Page.ChangeOwner;
        
        
        Opportunity  testOppty = new Opportunity();
        testOppty.name='testOpp';
        testOppty.StageName='Define Opportunity';
        testOppty.CloseDate=System.today();
        testOppty.Vertical_Market__c='Airports & Transportation';
        insert testOppty;
        
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',testOppty.id);
        ChangeOwner changeOwnerIns = new ChangeOWner();
        changeOwnerIns.sendEmailNotification();        
        test.stopTest();
    }
    
}