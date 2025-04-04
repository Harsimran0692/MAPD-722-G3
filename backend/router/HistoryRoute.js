import express from "express";
import {
  addHistory,
  getHistory,
  updateHistory,
} from "../controller/HistoryController.js";

const HistoryRoute = express.Router();

HistoryRoute.get("/get-history/:patientId", getHistory);
HistoryRoute.post("/add-history/:patientId", addHistory);
HistoryRoute.put("/edit-history/:historyId", updateHistory);

export default HistoryRoute;
