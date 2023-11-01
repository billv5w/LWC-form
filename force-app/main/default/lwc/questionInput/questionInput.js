import { LightningElement, api, track } from "lwc";
import FormInputCheckbox from "./formInputCheckbox.html";
import FormInputCurrency from "./formInputCurrency.html";
import FormInputDate from "./formInputDate.html";
import FormInputDateTime from "./formInputDateTime.html";
import FormInputNumber from "./formInputNumber.html";
import FormInputText from "./formInputText.html";
import FormInputTextAreaLong from "./formInputTextAreaLong";

export default class FormInput extends LightningElement {
  @api recordId;
  @api formId;
  @api readOnly;

  @track _detail = {};

  @api get detail() {
    return this._detail;
  }
  set detail(value) {
    this._detail = Object.assign({}, value);
    this._detail.dataType = this._detail.DataType__c;
  }

  @api get completed() {
    const element =
      this.type === "textarea" ? "lightning-textarea" : "lightning-input";
    return [...this.template.querySelectorAll(element)].reduce(
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

  get valueFieldName() {
    let field = "";
    switch (this.detail?.DataType__c) {
      case "InputCheckbox":
        field = "InputCheckbox__c";
        break;
      case "InputCurrency":
        field = "InputCurrency__c";
        break;
      case "InputDate":
        field = "InputDate__c";
        break;
      case "InputDateTime":
        field = "InputDateTime__c";
        break;
      case "InputEmail":
        field = "InputEmail__c";
        break;
      case "InputNumber":
        field = "InputNumber__c";
        break;
      case "InputTextArea":
        field = "InputTextArea__c";
        break;
      case "InputTime":
        field = "InputTime__c";
        break;
      case "InputUrl":
        field = "InputUrl__c";
        break;
      default:
        field = "InputText__c";
    }
    return field;
  }

  render() {
    switch (this.type) {
      case "checkbox":
        return FormInputCheckbox;
      case "currency":
        return FormInputCurrency;
      case "date":
        return FormInputDate;
      case "datetime":
        return FormInputDateTime;
      case "number":
        return FormInputNumber;
      case "textarea":
        return FormInputTextAreaLong;
      default:
        return FormInputText;
    }
  }

  get val() {
    return this.detail?.[this.valueFieldName];
  }

  get type() {
    let type = "";
    switch (this.detail?.DataType__c) {
      case "InputCheckbox":
        type = "checkbox";
        break;
      case "InputCurrency":
      case "InputNumber":
        type = "number";
        break;
      case "InputDate":
        type = "date";
        break;
      case "InputDateTime":
        type = "datetime";
        break;
      case "InputEmail":
        type = "email";
        break;
      case "InputTextArea":
        type = "textarea";
        break;
      case "InputTime":
        type = "time";
        break;
      case "InputUrl":
        type = "url";
        break;
      default:
        type = "text";
    }
    return type;
  }

  get min() {
    return this.detail?.Minimum__c;
  }
  get max() {
    return this.detail?.Maximum__c;
  }
  get step() {
    return this.detail?.Step__c;
  }

  get pattern() {
    return this.detail?.Pattern__c;
  }
  get patternMessage() {
    return this.detail?.Message_When_Pattern_Mismatch__c;
  }
  handleChange(event) {
    let value = event.detail.value;
    if (value === undefined) {
      value = event.detail.checked;
    }

    this.detail[this.valueFieldName] = value;

    this.dispatchEvent(
      new CustomEvent("detailchange", {
        composed: true,
        bubbles: true,
        detail: {
          Id: this.id,
          [this.valueFieldName]: value
        }
      })
    );
  }
}
