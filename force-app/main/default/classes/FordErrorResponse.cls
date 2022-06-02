public with sharing class FordErrorResponse {
    public String type {get;set;}
    public String title {get;set;}
    public Integer status {get;set;}
    public Error error {get;set;}

    public class Error {
        public List<String> messages{get;set;}
    }

    public static FordErrorResponse parse(String json) {
        return (FordErrorResponse) System.JSON.deserialize(json, FordErrorResponse.class);
    }
}