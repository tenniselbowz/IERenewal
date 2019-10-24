@isTest
public class Sandbox_Refresh_Test{
    public static @isTest void runTest(){
        Sandbox_Refresh ClassInstance = new Sandbox_Refresh();
        Test.testSandboxPostCopyScript(new Sandbox_Refresh(), UserInfo.getOrganizationId(), '07E1A00000057BO', 'sandbox2');
        
        String uName = 'daniel.ludowise@daikinapplied.com.sandbox2';
        List<User> users = [select Email, Username, IsActive, Profile.Name from User where IsActive=true and Profile.Name='System Administrator' and Username=:uName];
        for (User u :users){
            System.assertEquals('daniel.ludowise@daikinapplied.com', u.Email, 'Email address matched.');
        }        
    }
}