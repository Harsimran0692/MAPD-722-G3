import express from "express";
import dotenv from "dotenv";
import PatientRoute from "./router/PatientRoute.js";
import MongoDB from "./database/MongoDB.js";
import ClinicalDataRoute from "./router/ClinicalDataRoute.js";
import HistoryRoute from "./router/HistoryRoute.js";

const app = express();
dotenv.config();
const PORT = process.env.PORT || 8001;

app.use(express.json());
app.use("/api", PatientRoute);
app.use("/api", ClinicalDataRoute);
app.use("/api", HistoryRoute);

MongoDB.then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}).catch((error) => {
  console.error("Failed to connect to MongoDB:", error);
});
