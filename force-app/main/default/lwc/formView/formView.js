import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getForm from "@salesforce/apex/FormLwcController.getForm";
import getFormQuestions from "@salesforce/apex/FormLwcController.getFormQuestions";
import formTemplate from "./form.html";
import sectionTemplate from "./formSection.html";
import childTemplate from "./formChild.html";
import formInModal from "c/formInModal";

export default class FormView extends LightningElement {
  @api recordId;
  @api mode;
  @api cancelButtonLabel = "Cancel";
  @api saveButtonLabel = "Save";
  @api bottomButtonLabel = "Submit";

  @track form = {};
  questions = [];
  size = 12;
  smallDeviceSize = 12;
  mediumDeviceSize = 6;
  largeDeviceSize = 4;

  isLoading = false;
  hasQuestions = false;

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
    await this.fetchFormData();
  }

  async fetchFormData() {
    try {
      this.isLoading = true;
      this.form = await getForm({ formId: this.recordId });
      this.questions = await getFormQuestions({ formId: this.recordId });
      this.hasQuestions = this.questions.length > 0;
    } catch (error) {
      this.showToastMessage("Error", error.body.message, "error");
    } finally {
      this.isLoading = false;
    }
  }
  get sections() {
    return this.form?.ChildForms__r || [];
  }

  get formDisplayName() {
    return this.form?.DisplayName__c || "Form Name";
  }

  get displayDescription() {
    return this.form?.DisplayDescription__c || "Form Description";
  }

  async openModal() {
    try {
      await formInModal.open({
        label: this.formDisplayName,
        recordId: this.recordId,
        questions: this.questions,
        sections: this.sections,
        isFormView: true,
        cancelButtonLabel: this.cancelButtonLabel,
        saveButtonLabel: this.saveButtonLabel
      });
    } catch (error) {
      console.error(error);
    }
  }

  handleLoading() {
    this.isLoading = this.isLoading ? false : true;
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
