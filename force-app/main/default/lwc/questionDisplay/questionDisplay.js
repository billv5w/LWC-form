import { LightningElement, api } from "lwc";

export default class FormDisplay extends LightningElement {
  @api recordId;
  @api formId;
  @api detail;

  connectedCallback() {
    console.log(JSON.parse(JSON.stringify(this.detail)));
  }

  errorCallback(error, stack) {
    console.log(error, stack);
  }

  @api get completed() {
    return true;
  }
  get alignment() {
    return this.detail?.Alignment__c;
  }
  get displayClass() {
    if (["Right", "Left"].includes(this.alignment)) {
      return `slds-float_${this.alignment.toLowerCase()}`;
    }
    return "slds-align_absolute-center";
  }

  get displayRichText() {
    return this.detail?.DisplayRichText__c;
  }

  get displayText() {
    return this.detail?.DisplayText__c;
  }
}
