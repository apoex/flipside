import { Application } from "@hotwired/stimulus"
import ToggleController from "toggle_controller"
import SearchController from "search_controller"
import ModalController from "modal_controller"
import InlineEditController from "inline_edit_controller"

const application = Application.start()
application.register("toggle", ToggleController)
application.register("search", SearchController)
application.register("modal", ModalController)
application.register("inline-edit", InlineEditController)
