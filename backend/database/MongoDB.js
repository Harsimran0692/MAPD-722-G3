import mongoose from "mongoose";
import dotenv from "dotenv";

dotenv.config();
const connectionUrl = process.env.MONGO_URL.replace(
  "${MONGO_PASS}",
  process.env.MONGO_PASS
);

const MongoDB = mongoose
  .connect(connectionUrl)
  .then(() => console.log("MongoDB Connected Successfully"))
  .catch((error) => console.error("MongoDB Connection Error:", error));

export default MongoDB;
