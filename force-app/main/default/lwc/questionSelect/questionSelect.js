import { LightningElement, api, track } from "lwc";
import formInputPicklist from "./formInputPicklist.html";
import formInputRadioGroup from "./formInputRadioGroup.html";
import formInputCheckboxGroup from "./formInputCheckboxGroup.html";

export default class FormSelect extends LightningElement {
  @api recordId;
  @api formId;
  @api readOnly;

  @track _detail = {};

  @api get detail() {
    return this._detail;
  }
  set detail(value) {
    this._detail = Object.assign({}, value);
  }

  render() {
    switch (this.type) {
      case "lightning-checkbox-group":
        return formInputCheckboxGroup;
      case "lightning-combobox":
        return formInputPicklist;
      case "lightning-radio-group":
        return formInputRadioGroup;
      default:
        return null;
    }
  }

  get type() {
    switch (this.detail?.DataType__c) {
      case "InputCheckboxGroup":
        return "lightning-checkbox-group";
      case "InputPicklist":
        return "lightning-combobox";
      case "InputRadioGroup":
        return "lightning-radio-group";
      default:
        return null;
    }
  }

  @api get completed() {
    return [...this.template.querySelectorAll(this.type)].reduce(
      (validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      },
      true
    );
  }

  get id() {
    return this.detail?.Id;
  }
  get label() {
    return this.detail?.QuestionText__c;
  }
  get required() {
    return this.detail?.Required__c;
  }
  get val() {
    return this.type === "lightning-checkbox-group"
      ? this.detail?.InputText__c?.split(";") || []
      : this.detail?.InputText__c || this.defaultValue;
  }

  get defaultValue() {
    return this.detail?.DefaultValue__c || "";
  }

  get picklistValues() {
    return this.detail?.ResponseValues__c || "";
  }

  get options() {
    if (!this.picklistValues.length) {
      return [{ label: "empty N/A", value: "N/A" }];
    }
    if (!this.picklistValues.split("\n").length) {
      return [{ label: "split N/A", value: "N/A" }];
    }

    return this.picklistValues.split("\n").map((val) => {
      const value = val.trim();
      return {
        label: value,
        value
      };
    });
  }

  handleChange(event) {
    const value = event.detail.value;
    this.detail.InputText__c =
      this.type === "lightning-checkbox-group" ? value.join(";") : value;

    this.dispatchEvent(
      new CustomEvent("detailchange", {
        composed: true,
        bubbles: true,
        detail: {
          Id: this.id,
          InputText__c: this.detail.InputText__c
        }
      })
    );
  }

  // get dependentParentAnswer() {
  //   return this.detail?.Parent_Dependent_Answer__c || "";
  // }

  // get showChildRecords() {
  //   return this.hasChildRecords && this.dependentChildRecords.length;
  // }
  // get hasChildRecords() {
  //   return !!this.childRecords.length;
  // }
  // get childRecords() {
  //   return this.detail?.Parent_Form_Questions__r || [];
  // }
  // get dependentChildRecords() {
  //   return (
  //     this.childRecords.filter(
  //       (child) =>
  //         child?.Parent_Dependent_Answer__c === this.detail.Input_Text__c
  //     ) || []
  //   );
  // }
  // get childrenValidated() {
  //   const appDetailsTypes = this.template.querySelectorAll(
  //     "c-form-question-type.customInput"
  //   );

  //   let allValidArray = [];

  //   appDetailsTypes.forEach((curr) => {
  //     allValidArray.push(curr.isValid());
  //   });

  //   const isAllValid = allValidArray.every((item) => !!item);

  //   return isAllValid;
  // }
  // get childrenNodes() {
  //   return [
  //     ...this.template.querySelectorAll("c-form-question-type.customInput")
  //   ];
  // }
}
