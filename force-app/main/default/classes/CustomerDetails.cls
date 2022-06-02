public with sharing class CustomerDetails {
  // Used to create the class from JSON
  public static CustomerDetails parse(String json) {
    return (CustomerDetails) System.JSON.deserialize(
      json,
      CustomerDetails.class
    );
  }

  // Apex class used to deserialize JSON object
  @InvocableVariable(label='Name of Customer' required=true)
  @AuraEnabled
  public string name;

  @InvocableVariable(label='Customer email' required=true)
  @AuraEnabled
  public string email;

  @InvocableVariable(label='Customer phone' required=true)
  @AuraEnabled
  public string phone;

  @InvocableVariable(label='Customer Postal Code' required=true)
  @AuraEnabled
  public string postalCode;
}
