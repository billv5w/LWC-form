import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class FormInModal extends LightningModal {
  @api label;
  @api recordId;
  @api readOnly;
  @api cancelButtonLabel = "Cancel";
  @api saveButtonLabel = "Save";

  @api questions = [];
  @api sections = [];
  @api isFormView = false;

  get editable() {
    return !this.readOnly;
  }

  handleClose() {
    this.close("closed");
  }

  handleDetailChange(event) {
    const detail = JSON.parse(JSON.stringify(event.detail));
    console.log("detail", detail);
    // const newDetail = {
    //   ...this.questions.find((item) => item.Id === detail.Id),
    //   ...detail
    // };
  }
  async handleSave() {
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
      return;
    }
    const questionTypes = this.template.querySelectorAll(
      "c-form-question-type.customInput"
    );
    let allValidArray = [];
    let firstErrorElement = null;
    questionTypes.forEach((question) => {
      allValidArray.push(question.isValid());
      if (!firstErrorElement && !question.isValid()) {
        firstErrorElement = question;
        firstErrorElement.scrollIntoView({
          behavior: "smooth",
          block: "center"
        });
      }
    });
    const isAllValid = allValidArray.every((item) => !!item);

    if (!isAllValid) {
      return;
    }

    this.close("save");
  }
}
