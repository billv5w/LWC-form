import { LightningElement, api } from "lwc";

export default class FormQuestionType extends LightningElement {
  @api recordId;
  @api readOnly;
  @api question = {};

  @api isValid() {
    return this.refs.input?.completed;
  }

  errorCallback(error, stack) {
    console.error(error);
    console.log(stack);
  }

  get dataType() {
    return this.question?.DataType__c;
  }

  get inputDisplayClass() {
    return this.dataType.includes("Input") ? "customInput" : "customDisplay";
  }

  get isDisplay() {
    return (
      this.dataType === "DisplayText" || this.dataType === "DisplayRichText"
    );
  }

  get isInput() {
    return [
      "InputCurrency",
      "InputCheckbox",
      "InputDate",
      "InputDateTime",
      "InputEmail",
      "InputNumber",
      "InputTelephone",
      "InputText",
      "InputTextArea",
      "InputUrl",
      "InputTime"
    ].includes(this.dataType);
  }
  get isSelect() {
    return ["InputCheckboxGroup", "InputPicklist", "InputRadioGroup"].includes(
      this.dataType
    );
  }

  get isInputFile() {
    return this.dataType === "InputFile";
  }

  // get isInputDatatable() {
  //   return this.dataType === "InputDatatable";
  // }
  // get isInputFlow() {
  //   return this.dataType === "Input_Flow";
  // }
  // get isInputRecordList() {
  //   return this.dataType === "Input_Record_List";
  // }
}
