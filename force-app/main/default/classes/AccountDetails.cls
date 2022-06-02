public with sharing class AccountDetails {
    // Used to create the class from JSON
    public static AccountDetails parse(String json) {
      
      return (AccountDetails) System.JSON.deserialize(
        json,
        AccountDetails.class
      );
    }
  
    // Apex class used to deserialize JSON object
    @InvocableVariable(label='Account Number' required=true)
    @AuraEnabled
    public string receivableAccountNumber;
  
    @InvocableVariable(label='Account Type' required=true)
    @AuraEnabled
    public string productType;

    @InvocableVariable(label='Monthly Payment' required=true)
    @AuraEnabled
    public string scheduledPaymentAmount;
  
    @InvocableVariable(label='Term' required=true)
    @AuraEnabled
    public string contractTermInMonths;
  
    @InvocableVariable(label='Last Payment Date' required=true)
    @AuraEnabled
    public string finalPaymentDueDate;

    @InvocableVariable(label='Term Date' required=false)
    @AuraEnabled
    public string currentScheduledTerminationDate;

  }
  