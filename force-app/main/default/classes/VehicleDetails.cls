public with sharing class VehicleDetails {
  // Used to create the class from JSON
  public static VehicleDetails parse(String json) {
    return (VehicleDetails) System.JSON.deserialize(json, VehicleDetails.class);
  }
  // Apex class used to deserialize JSON object
  @InvocableVariable(label='VIN Serial Number' required=true)
  @AuraEnabled
  public string vinSerialNumber;
  @InvocableVariable(label='Make Description' required=true)
  @AuraEnabled
  public string makeDescriptionText;
  @InvocableVariable(label='Model Description' required=true)
  @AuraEnabled
  public string modelDescriptionText;
  @InvocableVariable(label='Model Year' required=true)
  @AuraEnabled
  public String vehicleModelYear;
  @InvocableVariable(label='Vehicle Color' required=true)
  @AuraEnabled
  public string vehicleColorText;
}
