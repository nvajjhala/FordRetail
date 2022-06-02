import { LightningElement, api } from "lwc";
import getInfoByTranscriptId from "@salesforce/apex/GetAccountDetails.getInfoByTranscriptId";

export default class DisplayAccountDetails extends LightningElement {
  @api recordId;
  account = null;

  get accountValues() {

    if (this.account.contractTermInMonths !== ""){
    this.account.contractTermInMonths += " months";
    }

    if (this.account.scheduledPaymentAmount !== ""){
    this.account.scheduledPaymentAmount = "$" + this.account.scheduledPaymentAmount;
    }

    if (this.account !== null && this.account.productType == "Lease") {
   
      const vals = [
        { id: 1, size: 6, title: "Account Number", value: this.account.receivableAccountNumber },
        { id: 2, size: 6, title: "Account Type", value: this.account.productType },
        { id: 3, size: 6, title: "Monthly Payment", value: this.account.scheduledPaymentAmount },
        { id: 4, size: 6, title: "Term", value: this.account.contractTermInMonths },
        { id: 5, size: 6, title: "Last Payment Date", value: this.account.finalPaymentDueDate },
        { id: 6, size: 6, title: "Term Date", value: this.account.currentScheduledTerminationDate }
      ];


      console.log(JSON.stringify(vals));
      return vals;

    } else if (this.account !== null && this.account.productType == "Retail") {
   
      const vals = [
        { id: 1, size: 6, title: "Account Number", value: this.account.receivableAccountNumber },
        { id: 2, size: 6, title: "Account Type", value: this.account.productType },
        { id: 3, size: 6, title: "Monthly Payment", value: this.account.scheduledPaymentAmount },
        { id: 4, size: 6, title: "Term", value: this.account.contractTermInMonths },
        { id: 5, size: 6, title: "Last Payment Date", value: this.account.finalPaymentDueDate }
      ];


      console.log(JSON.stringify(vals));
      return vals;

    } else {
      return [];
    }
  }

  async connectedCallback() {
    console.log("connected");
    try {
      this.account = await getInfoByTranscriptId({ recordId: this.recordId });
      console.log("account", this.account);
    } catch (e) {
      console.log("fail", e);
    }
  }
}
