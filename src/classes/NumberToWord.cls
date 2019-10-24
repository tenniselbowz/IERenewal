public with sharing class NumberToWord 
{  
    static String[] to_19 = new string[]{ 'Zero', 'One',  'Two', 'Three', 'Four',  'Five',  'Six',  
        'Seven', 'Eight', 'Nine', 'Ten',  'Eleven', 'Twelve', 'Thirteen',  
        'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen' };  
    static String[] tens = new string[]{ 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'};  
    static String[] denom = new string[]{ '',  
                    'Thousand',   'Million',     'Billion',    'Trillion',    'Quadrillion',  
                    'Quintillion', 'Sixtillion',   'Septillion',  'Octillion',   'Nonillion',  
                    'Decillion',  'Undecillion',   'Duodecillion', 'Tredecillion',  'Quattuordecillion',  
                    'Sixdecillion', 'Septendecillion', 'Octodecillion', 'Novemdecillion', 'Vigintillion' };  
                        // convert a value < 100 to English.    
    public static String convert_nn(integer val) 
                    {  
                            if (val < 20)  
                                return to_19[val];  
                            if(val == 100)  
                                return 'One Hundred';  
                            for (integer v = 0; v < tens.size(); v++) 
                            {  
                                String dcap = tens[v];  
                                integer dval = 20 + 10 * v;  
                                if (dval + 10 > val) 
                                {  
                                    if (Math.Mod(val,10) != 0)  
                                        return dcap + ' ' + to_19[Math.Mod(val,10)];  
                                    return dcap;  
                                }      
                            }  
                            return 'Should never get here, less than 100 failure';  
                        }  
    
    
    
    // convert a value < 1000 to english, special cased because it is the level that kicks   
    // off the < 100 special case. The rest are more general. This also allows you to  
    // get strings in the form of "forty-five hundred" if called directly.  
    public static String convert_nnn(integer val) {  
        String word = '';  
        integer rem = val / 100;  
        integer mod = Math.mod(val,100);  
        if (rem > 0) {  
            word = to_19[rem] + ' Hundred';  
            if (mod > 0) {  
                word += ' ';  
            }  
        }  
        if (mod > 0) {  
            word += convert_nn(mod);  
        }  
        return word;  
    }  
    public static String english_number(long val) {  
        if (val < 100) {  
            return convert_nn(val.intValue());  
        }  
        if (val < 1000) {  
            return convert_nnn(val.intValue());  
        }  
        for (integer v = 0; v < denom.size(); v++) {  
            integer didx = v - 1;  
            integer dval = (integer)Math.pow(1000, v);  
            if (dval > val) {  
                integer mod = (integer)Math.pow(1000, didx);  
                integer l = (integer) val / mod;  
                integer r = (integer) val - (l * mod);  
                String ret = convert_nnn(l) + ' ' + denom[didx];  
                if (r > 0) {  
                    ret += ', ' + english_number(r);  
                }  
                return ret;  
            }  
        }  
        return 'Should never get here, bottomed out in english_number';  
    }
    
    
    public static String New_english_number(decimal val) {  
        if (val < 100) {  
            return convert_dd(val);  
        }  
        if (val < 1000) {  
            return convert_ddd(val);  
        }  
        for (integer v = 0; v < denom.size(); v++) {  
            integer didx = v - 1;  
            integer dval = (integer)Math.pow(1000, v);  
            if (dval > val) {  
                integer mod = (integer)Math.pow(1000, didx);  
                integer l = (integer) val / mod;  
                integer r = (integer) val - (l * mod);
                string strDplace=(String.valueOf(val - val.intValue()).remove('0.'));
                Integer dplace=Integer.valueOf(strDplace);
                String ret = convert_nnn(l) + ' ' + denom[didx];  
                if (r > 0) {  
                    ret += ', ' + english_number(r) + ' dollars';  
                } 
                String returnValue = convert_nn(dplace);
                System.debug('          *** return Val ' + returnValue);
                if(returnValue == 'One')  {
                    ret += ' and ' + returnValue + ' cent';
                }
                else {
                    ret += ' and ' + returnValue + ' cents';
                }
                return ret;  
            }  
        }
        
        return 'Should never get here, bottomed out in english_number';  
    }
    //convert a value < 1000.00 to English.
    public static String convert_ddd(decimal val)
    {
        
        Integer left=Integer.valueOf(String.valueOf(val).substringBefore('.'));
        string strDplace=(String.valueOf(val - (Decimal.valueOf(left) + .00)));
        Integer right = Integer.valueOf(strDplace.remove('0.'));
        if(right == 0)
        {
            return convert_nnn(val.intValue()) + ' dollars and zero cents';
        }
        else{
            if(strDplace.startsWith('0'))
            {
                if(right != 1) {
                    return convert_nnn(left) + ' dollars and ' + convert_nnn(right) + ' Cents';
                }
                else {
                    return convert_nnn(left) + ' dollars and ' + 'One Cent';

                }
            }
            else
            {
                if(right<=9)
                {
                    
                    right = Integer.valueOf(String.valueOf(right)  + '0');
                    System.debug('          ** ' + right);
                    if(right != 1) {
                        return convert_nnn(left) + ' dollars and ' + convert_nnn(right) + ' Cents';
                    }
                    else {
                        return convert_nnn(left) + ' dollars and ' + 'One Cent';

                    }
                }
                else
                {
                    System.debug('          *** ' + right);
                    return convert_nnn(left) + ' dollars and ' + convert_nnn(right) + ' Cents';
                    
                }
            }
        }
        
        
        
    }
    
    
    //convert a value < 100.00 to English.
    public static String convert_dd(decimal val)
    {
        Integer left=Integer.valueOf(String.valueOf(val).substringBefore('.'));
        string strDplace=(String.valueOf(val - val.intValue()).remove('0.'));
        Integer right=Integer.valueOf(strDplace);

        if(right == 0)
        {
            return convert_nn(val.intValue()) + ' dollars and zero cents';
        }
        else{
            if(strDplace.startsWith('0'))
            {   
                if(right != 1) {
                    return convert_nn(left) + ' dollars and ' + convert_nn(right) + ' Cents';
                }
                else {
                    return convert_nn(left) + ' dollars and ' + 'One Cent';

                }            
            }
            else
            {
                if(right<=9)
                {
                    right = Integer.valueOf(String.valueOf(right)  + '0');
                    System.debug('          **** ' + right);
                    if(right != 1) {
                        return convert_nn(left) + ' dollars and ' + convert_nn(right) + ' Cents';
                    }
                    else {
                        return convert_nn(left) + ' dollars and ' + 'One Cent';

                    }
                }
                else
                {
                    System.debug('          ***** ' + right);
                    return convert_nn(left) + ' dollars and ' + convert_nn(right) + ' Cents';
                    
                }
            }
        }
        
        
        
    }
}