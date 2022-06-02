public with sharing class FordDirectService {
    @AuraEnabled
    public static String submitDealerLead(FordDirectDeliverRequest fordDirectDeliverRequest, Id chatTranscriptId){
        // FordDirectDeliverResponse fordDirectDeliverResponse;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(
          'callout:ApigeeFord/fccrmsalesforcedelivr/api/v1/ford-direct/dealerlead'
        );
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Set the body as a JSON object
        request.setBody(Json.serialize(fordDirectDeliverRequest));

        HttpResponse response = http.send(request);

        // Parse the JSON response
        if (response.getStatus() != '200') {
            FordErrorResponse fordErrorResponse = FordErrorResponse.parse(response.getBody());
            return fordErrorResponse.error.messages.get(0);
        } else {
            Map<String, Object> result = (Map<String, Object>)Json.deserializeUntyped(response.getBody());
            return (String) result.get('message');
        }
    }
}