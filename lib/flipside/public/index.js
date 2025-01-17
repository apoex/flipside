import { Application } from "@hotwired/stimulus";
import ToggleController from "toggle_controller";

const application = Application.start();
application.register("toggle", ToggleController);
