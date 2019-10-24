/**
 * Class: APTS_AvalaraTaxException 
 * Description : This class is used while throwing exception from Avalara Tax Integration.
 * Author : Hardik Shah , @Apttus
 **/

public with sharing class APTS_AvalaraTaxException extends Exception  {

  public APTS_AvalaraTaxException(String sMessage, String additionalMessage){
  		setMessage(sMessage);
 	 }
 }