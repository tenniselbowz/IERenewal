global class Sandbox_Refresh implements SandboxPostCopy {
  global void runApexClass(SandboxContext context) {
        //String uName = 'daniel.ludowise@daikinapplied.com.'+context.sandboxName();
        //List<User> users = [select Email, Username, IsActive, Profile.Name from User where IsActive=true and Profile.Name='System Administrator' and Username=:uName];

        List<User> users = [select Email, Username, IsActive, Profile.Name from User where IsActive=true and Profile.Name='System Administrator'];
        for (User u :users){
            Integer i = u.Username.lastIndexOf(context.sandboxName())-1;
            if(i>0){
                u.Email = u.Username.Substring(0, i);
                Update u;
            }
        }
    }
}