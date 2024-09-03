import { Application } from "@hotwired/stimulus";
import MapController from "./map_controller";

const application = Application.start();

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

// Register the "map" controller
application.register("map", MapController);  

export { application };
