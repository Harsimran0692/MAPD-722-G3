import express from "express";
import {
  addClinicalData,
  deleteClinicalDataById,
  getClinicalData,
  getClinicalDataById,
  updateClinicalData,
} from "../controller/ClinicalDataController.js";

const ClinicalDataRoute = express.Router();

ClinicalDataRoute.get("/get-clinical-data", getClinicalData);
ClinicalDataRoute.get("/get-clinical-data/:id", getClinicalDataById);
ClinicalDataRoute.post("/add-clinical-data", addClinicalData);
ClinicalDataRoute.get("/update-clinical-data/:id", updateClinicalData);
ClinicalDataRoute.get("/delete-clinical-data/:id", deleteClinicalDataById);

export default ClinicalDataRoute;
