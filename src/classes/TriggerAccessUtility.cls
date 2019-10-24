public class TriggerAccessUtility {

    public static Map<String, TriggerAccessUtility> tau = new Map<String, TriggerAccessUtility>{'Case' => new TriggerAccessUtility(2, true)};
    
    private Integer max=1;
    private Integer count=0;
    private Boolean auto = false;
    
    private Integer iteration=0;

    public TriggerAccessUtility(){
    }
    public TriggerAccessUtility(Integer max){
        setMax(max);
    }
    public TriggerAccessUtility(Integer max, Boolean auto){
        setMax(max);
        this.auto = auto;
    }

    public boolean isaccessible() {
        boolean access = count<max;
        if(auto){
            iteration++;              
            count++;
            //if(count>max*2){
                //count=0;
            //}
        }
        return access;
    }

    public void increment(){
        count++;        
    }   
    public void setMax(Integer max){
        this.max=max;
    }
    public void reset(){
        count=0;
    }
    public Integer getIteration(){
        return iteration;
    }
}