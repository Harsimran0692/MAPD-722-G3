import express from "express";
import {
  addClinicalData,
  deleteClinicalDataById,
  getClinicalData,
  getClinicalDataById,
  getPatientClinicalData,
  updateClinicalData,
} from "../controller/ClinicalDataController.js";

const ClinicalDataRoute = express.Router();

ClinicalDataRoute.get("/get-clinical-data", getClinicalData);
ClinicalDataRoute.get("/get-clinical-data/:id", getClinicalDataById);
ClinicalDataRoute.get("/get-patient-clinical-data/:id", getPatientClinicalData);
ClinicalDataRoute.post("/add-clinical-data", addClinicalData);
ClinicalDataRoute.put("/update-clinical-data/:id", updateClinicalData);
ClinicalDataRoute.delete("/delete-clinical-data/:id", deleteClinicalDataById);

export default ClinicalDataRoute;
