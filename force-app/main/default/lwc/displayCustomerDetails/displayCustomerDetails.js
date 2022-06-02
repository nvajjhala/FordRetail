import { LightningElement, api } from "lwc";
import getInfoByTranscriptId from "@salesforce/apex/GetCustomerDetails.getInfoByTranscriptId";

export default class DisplayCustomerDetails extends LightningElement {
  @api recordId;
  customer = null;
  get custValues() {
    if (this.customer !== null) {
      const vals = [
        { id: 1, size: 6, title: "Name", value: this.customer.name },
        { id: 2, size: 6, title: "Email", value: this.customer.email },
        { id: 3, size: 6, title: "Phone", value: this.customer.phone },
        { id: 4, size: 6, title: "ZIP Code", value: this.customer.postalCode }
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
      this.customer = await getInfoByTranscriptId({ recordId: this.recordId });
      console.log("cust", this.customer);
    } catch (e) {
      console.log("fail", e);
    }
  }
}
