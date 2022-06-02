public with sharing class GetDealershipDetails {
    
 
  // Used by LWC
  @AuraEnabled
  public static Account getDealershipByPACode(String paCode) {

    List<Account> dealerships = [
        SELECT Name,DealerPrimaryPAAccountCode__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,
        Sales_Hours__c,Services_Offered__c,Participating_Programs__c,
        Primary_Sales_Representative__r.Name,Primary_Sales_Representative__r.Phone,Primary_Sales_Representative__r.Email,
        Backup_Sales_Representative__r.Name,Backup_Sales_Representative__r.Phone,Backup_Sales_Representative__r.Email
        FROM Account
        WHERE DealerPrimaryPAAccountCode__c= :paCode 
        WITH SECURITY_ENFORCED    
        LIMIT 1
    ];
    
    if (dealerships?.size() > 0) {
      Account result = dealerships[0];
      return result;
    }
    else{
      return null;
    }
  }
}
