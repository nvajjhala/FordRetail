/* @group: Webservice
 * @description: Service class to create CustMergeReq__c records based on request from GDIA
 * @payload : [{
	"winner": "11296017050",
    "loser": "31180061453",
    "merged_date_time": "2022-03-28T07:59:22Z"
	}]
  */

@RestResource(urlMapping='/custmerge')
global class CustomerMergeRequestAPI {

    /* @description: HTTPPost method to create records as per request from GDIA
     * @returnType: String
    */
    @HttpPost
    global static String doPost() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();
        Set<String> winnerIdSet = new Set<String>();
        Set<String> loserIdSet = new Set<String>();
        Map<String,CustMergeReq__c> custMergeMap = new Map<String,CustMergeReq__c>();
        List<CustomerRequestWrapper> jsonList = new List<CustomerRequestWrapper>();
        try{
            //deserialize the request body
            jsonList = (List<CustomerRequestWrapper>)JSON.deserialize(body,
        											List<CustomerRequestWrapper>.class);
        }
        catch(JSONException ex){
            String error = '{"status":"Error","responseCode": 400, "description" : "'+ex.getMessage()+'"}';  //generateJsonString('Error', 400, ex.getMessage());
            return error;
        }

        for(CustomerRequestWrapper obj : jsonList){
            loserIdSet.add(obj.loser);
            winnerIdSet.add(obj.winner);
            CustMergeReq__c custMergeObj = new CustMergeReq__c();
            if(!String.isBlank(obj.loser)){
                custMergeObj.loser__c = obj.loser;
            }
            if(!String.isBlank(obj.winner)){
                custMergeObj.winner__c = obj.winner;
            }
            custMergeObj.merged_date_time__c = obj.mergedDateTime;
            custMergeMap.put(obj.loser,custMergeObj);
        }
        AccountMergeService.handleAccountMerge(winnerIdSet,loserIdSet,custMergeMap);
        String successJson = '{"status":"Success","responseCode": 200, "description" : "OK"}';//generateJsonString('Success', 200, 'OK');
        return successJson;
    }

    public class CustomerRequestWrapper{
        public String winner{get;set;}
        public String loser{get;set;}
        public DateTime mergedDateTime {get;set;}
    }
}