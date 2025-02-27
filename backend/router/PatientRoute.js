import express from "express";
import {
  GetPatients,
  AddPatient,
  GetPatientById,
  UpdatePatient,
  DeletePatient,
} from "../controller/PatientController.js";

const PatientRoute = express.Router();

PatientRoute.get("/get-patients", GetPatients);
PatientRoute.get("/get-patient/:id", GetPatientById);
PatientRoute.post("/add-patient", AddPatient);
PatientRoute.put("/update-patient/:id", UpdatePatient);
PatientRoute.delete("/delete-patient/:id", DeletePatient);

export default PatientRoute;
