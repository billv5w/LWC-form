import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getFormResponse from "@salesforce/apex/FormResponseLwcController.getFormResponse";
import saveFormResponse from "@salesforce/apex/FormResponseLwcController.saveFormResponse";
import getFormQuestionResponses from "@salesforce/apex/FormResponseLwcController.getFormQuestionResponses";
import saveFormQuestionResponses from "@salesforce/apex/FormResponseLwcController.saveFormQuestionResponses";
import formTemplate from "./form.html";
import sectionTemplate from "./formSection.html";
import childTemplate from "./formChild.html";
import formInModal from "c/formInModal";

export default class FormResponse extends LightningElement {
  @api recordId;
  @api mode;
  @api cancelButtonLabel = "Cancel";
  @api saveButtonLabel = "Save";
  @api bottomButtonLabel = "Submit";
  _readOnly = false;

  @track formResponse = {};
  questionResponses = [];
  size = 12;
  smallDeviceSize = 12;
  mediumDeviceSize = 6;
  largeDeviceSize = 4;

  isLoading = false;
  hasQuestions = false;
  hasInput = false;

  render() {
    switch (this.mode) {
      case "Section":
        return sectionTemplate;
      case "Child Form":
        return childTemplate;
      default:
        return formTemplate;
    }
  }

  async connectedCallback() {
    await this.fetchFormResponseData();
  }

  async fetchFormResponseData() {
    try {
      this.isLoading = true;
      this.formResponse = await getFormResponse({
        formResponseId: this.recordId
      });
      this.questionResponses = await getFormQuestionResponses({
        formResponseId: this.recordId
      });
      this.hasQuestions = this.questionResponses.length > 0;
      this.hasInput =
        this.questionResponses.filter(
          (response) => response.DisplayClass__c === "customInput"
        ).length > 0;
    } catch (error) {
      this.showToastMessage("Error", error.body.message, "error");
    } finally {
      this.isLoading = false;
    }
  }

  handleDetailChange(event) {
    const detail = JSON.parse(JSON.stringify(event.detail));
    const newDetail = {
      ...this.questionResponses.find((item) => item.Id === detail.Id),
      ...detail
    };
    const index = this.questionResponses.findIndex(
      (item) => item.Id === detail.Id
    );
    this.questionResponses[index] = newDetail;
  }

  get sections() {
    return this.formResponse?.ChildFormResponses__r || [];
  }

  get formDisplayName() {
    return this.formResponse?.DisplayName__c || "Form Name";
  }

  get displayDescription() {
    return this.formResponse?.DisplayDescription__c || "Form Description";
  }

  set readOnly(value) {
    this._readOnly = value || this.formResponse?.ReadOnly__c || false;
  }
  @api get readOnly() {
    return this._readOnly;
  }

  get stopSubmit() {
    return (
      this.formResponse?.ChildFormResponses__r?.some(
        (child) => child.RequiredCompleted__c !== true
      ) ||
      this.formResponse?.ReadOnly__c ||
      false
    );
  }

  // get cancelButtonLabell() {
  //   return this.form?.Modal_Cancel_Button_Label__c || "Cancel";
  // }

  // get saveButtonLabel() {
  //   return this.form?.Modal_Save_Button_Label__c || "Save";
  // }
  async openModal() {
    try {
      const modalResult = await formInModal.open({
        label: this.formDisplayName,
        recordId: this.recordId,
        readOnly: this.readOnly,
        questions: this.questionResponses,
        sections: this.sections,
        cancelButtonLabel: this.cancelButtonLabel,
        saveButtonLabel: this.saveButtonLabel,
        ondetailchange: (event) => this.handleDetailChange(event),
        onsave: (event) => this.handleSave(event)
      });
      if (modalResult === "save") {
        await this.handleSave();
      }
    } catch (error) {
      console.error(error);
    }
  }

  @api async handleSave() {
    this.dispatchEvent(new CustomEvent("loading"));
    const isAllValid = this.validateInputs();
    if (!isAllValid) {
      this.dispatchEvent(new CustomEvent("loading"));
      const validationError = new Error("Field validation failed");
      console.error(validationError);
      throw validationError;
    }
    try {
      await saveFormQuestionResponses({
        formResponseId: this.recordId,
        formQuestionResponses: this.questionResponses
      });
      await this.fetchFormResponseData();
      this.dispatchEvent(new CustomEvent("refresh"));
    } catch (error) {
      this.showToastMessage(
        "Error",
        "Something went wrong with the server call",
        "error"
      );
      throw error;
    } finally {
      this.dispatchEvent(new CustomEvent("loading"));
    }
  }

  @api async handleSubmit() {
    this.dispatchEvent(new CustomEvent("loading"));
    try {
      const childFormResponses =
        this.template.querySelectorAll("c-form-response");
      const promises = Array.from(childFormResponses).map((child) =>
        child.handleSave()
      );
      const results = await Promise.allSettled(promises);
      const rejectedPromises = results.filter(
        (result) => result.status === "rejected"
      );
      if (rejectedPromises.length > 0) {
        const childError = new Error(
          `${rejectedPromises.length} section(s) failed to submit`
        );
        console.error(childError);
        throw childError;
      }
      await this.handleSave();
      const response = {
        Id: this.recordId,
        Status__c: "Submitted"
      };
      this.formResponse = await saveFormResponse({ response });
    } catch (error) {
      this.showToastMessage(
        "Error",
        error.body?.message ||
          "Something went wrong with saving the response. Please check the error messages.",
        "error"
      );
      throw error;
    } finally {
      this.dispatchEvent(new CustomEvent("loading"));
    }
  }

  handleRefresh() {
    this.fetchFormResponseData();
  }

  handleLoading() {
    this.isLoading = this.isLoading ? false : true;
  }

  validateInputs() {
    const questionTypes = this.template.querySelectorAll(
      "c-form-question-type.customInput"
    );
    let allValidArray = [];
    let firstErrorElement = null;
    questionTypes.forEach((curr) => {
      allValidArray.push(curr.isValid());
      if (!firstErrorElement && !curr.isValid()) {
        firstErrorElement = curr;
        firstErrorElement.scrollIntoView({
          behavior: "smooth",
          block: "center"
        });
      }
    });
    return allValidArray.every((item) => !!item);
  }

  showToastMessage(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title,
        message,
        variant
      })
    );
  }
}
