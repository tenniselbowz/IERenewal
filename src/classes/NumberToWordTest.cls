@isTest
private class NumberToWordTest {
    
    /*decimal value <100 without 00 after decimal point.*/
    static testMethod void testconvert_dd()
    {
        decimal val=95.35;
        string expected='Ninety Five dollars and Thirty Five Cents';
        test.startTest();
        	String result= NumberToWord.convert_dd(val);
        test.stopTest();
        System.assertEquals(expected, result,'Result is not equal to expected value');
        
    }
    /*decimal value <100 with 00 after decimal point */
     static testMethod void testconvert_ddzeroaterdecimal()
    {
        decimal val=95.00;
        string expected='Ninety Five dollars and zero cents';
        test.startTest();
           string result= NumberToWord.convert_dd(val);
        test.stopTest();
        System.assertEquals(expected, result,'Result is not equal to expected value');
    }

     static testMethod void singleDigitCentsTest()
    {
        decimal val=95.02;
        string expected='Ninety Five dollars and Two Cents';
        test.startTest();
           string result= NumberToWord.convert_dd(val);
        test.stopTest();
        System.assertEquals(expected, result,'Result is not equal to expected value');
    }
    
     /*decimal value <100 with less than 9 after decimal point*/
     static testMethod void testconvert_ddlessthanNine()
    {
        decimal val=95.05;
        string expected='Ninety Five dollars and Five Cents';
        test.startTest();
        	string result= NumberToWord.convert_dd(val);
        test.stopTest();
        System.assertEquals(expected, result,'Result is not equal to expected value');
        
    }
    
     static testMethod void testconvert_ddmorethanNine()
    {
        decimal val=95.5;
        string expected='Ninety Five dollars and Fifty Cents';
        test.startTest();
        	string result= NumberToWord.convert_dd(val);
        test.stopTest();
        System.assertEquals(expected, result,'Result is not equal to expected value');
        
    }
     /*decimal value <1000 without 00 after decimal point*/
     static testMethod void testconvert_ddd()
    {
        decimal val=195.35;
        string expected='One Hundred Ninety Five dollars and Thirty Five Cents';
        test.startTest();
        	string result= NumberToWord.convert_ddd(val);
        test.stopTest();
        System.assertEquals(expected, result,'Result is not equal to expected value');
        
    }
    
    /*decimal value <1000 with 00 after decimal point*/
     static testMethod void testconvert_dddwithoutzero()
    {
        decimal val=195.00;
        string expected='One Hundred Ninety Five dollars and zero cents';
        test.startTest();
       		string result= NumberToWord.convert_ddd(val);
        test.stopTest();
        System.assertEquals(expected, result,'Result is not equal to expected value');
        
    }
      /*decimal value <1000 with 00  and less than nine after decimal point*/
      static testMethod void testconvert_dddwithzerolessthannine()
    {
        decimal val=195.05;
        string expected='One Hundred Ninety Five dollars and Five Cents';
        test.startTest();
        	string result= NumberToWord.convert_ddd(val);
        test.stopTest();
        System.assertEquals(expected, result,'Result is not equal to expected value');

    }
   
   /*decimal value <1000 without 00  and more than nine after decimal point*/
     static testMethod void testconvert_dddwithoutzeromorethannine()
    {
        decimal val=195.5;
        string expected='One Hundred Ninety Five dollars and Fifty Cents';
        test.startTest();
        	string result= NumberToWord.convert_ddd(val);
        test.stopTest();
        System.assertEquals(expected, result,'Result is not equal to expected value');
  
    }
   
    static testMethod void testNew_english_number()
    {  
        decimal val=1234567890.45;
        string expected='One Billion, Two Hundred Thirty Four Million, Five Hundred Sixty Seven Thousand, Eight Hundred Ninety dollars and Forty Five cents';
        test.startTest();
        	string result= NumberToWord.New_english_number(val);
        test.stopTest();  
        system.debug(expected);
        system.debug(result);
        System.assertEquals(expected, result,'Result is not equal to expected value');
    }

}