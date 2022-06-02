import { LightningElement, api } from "lwc";
import getInfoByTranscriptId from "@salesforce/apex/GetVehicleDetails.getInfoByTranscriptId";

export default class DisplayVehicleDetails extends LightningElement {
  @api recordId;
  vehicle = null;
  get vehValues() {
    if (this.vehicle !== null) {
      const vals = [
        { id: 1, size: 6, title: "VIN", value: this.vehicle.vinSerialNumber },
        { id: 2, size: 6, title: "Make", value: this.vehicle.makeDescriptionText },
        { id: 3, size: 6, title: "Model", value: this.vehicle.modelDescriptionText },
        { id: 4, size: 6, title: "Year", value: this.vehicle.vehicleModelYear },
        { id: 5, size: 6, title: "Color", value: this.vehicle.vehicleColorText }
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
      this.vehicle = await getInfoByTranscriptId({ recordId: this.recordId });
      console.log("veh", this.vehicle);
    } catch (e) {
      console.log("fail", e);
    }
  }
}
