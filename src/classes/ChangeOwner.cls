public class ChangeOwner {
    public String id;
    public ChangeOwner(){
        id = apexpages.currentpage().getparameters().get('id');
    }
    public pageReference sendEmailNotification(){
        return new pageReference('/'+id+'/a?sendMail=1&retURL='+id);
    }
}