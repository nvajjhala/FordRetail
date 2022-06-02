import {
    LightningElement,
    api
} from 'lwc';

import getDealership from "@salesforce/apex/GetDealershipDetails.getDealershipByPACode";

export default class DisplayDealershipDetails extends LightningElement {
    @api recordId;
    dealership = null;
    mapMarkers = null;
    get dealershipValues() {
        console.log(JSON.stringify(this.dealership));
        return this.dealership;
    }

    get mapMarkers() {
        console.log(JSON.stringify(this.mapMarkers));
        return this.mapMarkers;
    }

    async connectedCallback() {
        console.log("connected");
        try {
            const result = await getDealership({
                paCode: '2750'
            });
            console.log("dlrshp", result);

            this.dealership = [{
                    id: 1,
                    size: 6,
                    title: "Name",
                    value: result.Name
                },
                {
                    id: 2,
                    size: 6,
                    title: "P & A Code",
                    value: result.DealerPrimaryPAAccountCode__c
                },
                {
                    id: 3,
                    size: 6,
                    title: "Primary Sales Representative",
                    value: result.Primary_Sales_Representative__r.Name
                },
                {
                    id: 4,
                    size: 6,
                    title: "Backup Sales Representative",
                    value: result.Backup_Sales_Representative__r.Name
                },
                {
                    id: 5,
                    size: 6,
                    title: "Primary Sales Representative Email",
                    value: result.Primary_Sales_Representative__r.Email
                },
                {
                    id: 6,
                    size: 6,
                    title: "Backup Sales Representative Email",
                    value: result.Backup_Sales_Representative__r.Email
                },
                {
                    id: 7,
                    size: 6,
                    title: "Primary Sales Representative Phone",
                    value: result.Primary_Sales_Representative__r.Phone
                },
                {
                    id: 8,
                    size: 6,
                    title: "Backup Sales Representative Phone",
                    value: result.Backup_Sales_Representative__r.Phone
                },
                {
                    id: 9,
                    size: 6,
                    title: "Services Offered",
                    value: result.Services_Offered__c
                },
                {
                    id: 10,
                    size: 6,
                    title: "Participating Programs",
                    value: result.Participating_Programs__c
                },
                {
                    id: 11,
                    size: 12,
                    title: "Sales Hours",
                    value: result.Sales_Hours__c
                },
                {
                    id: 12,
                    size: 12,
                    title: "Address",
                    value: result.BillingStreet + ", " + result.BillingCity + ", " + result.BillingState + ", " + result.BillingPostalCode
                }
            ];

            this.mapMarkers = [{
                location: {
                    Street: result.BillingStreet,
                    City: result.BillingCity,
                    State: result.BillingState,
                    PostalCode: result.BillingPostalCode,
                },
                title: result.Name
            }];
        } catch (e) {
            console.log("fail", e);
        }
    }
}