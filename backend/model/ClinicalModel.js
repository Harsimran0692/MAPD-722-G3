import { mongoose, Schema } from "mongoose";

const ClinicalModel = new Schema(
  {
    patientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Patients",
      required: true,
    },
    status: {
      type: String,
      enum: ["Stable", "Critical", "Recovering"],
      default: "N/A",
    },
    systolicPressure: {
      type: Number,
      default: "N/A",
      required: true,
    },
    diastolicPressure: {
      type: Number,
      default: "N/A",
      required: true,
    },
    respirationRate: {
      type: Number,
      default: "N/A",
      required: true,
    },
    bloodOxygenation: {
      type: Number,
      default: "N/A",
      required: true,
    },
    heartRate: {
      type: Number,
      default: "N/A",
      required: true,
    },
    doctorNotes: [
      {
        note: { type: String },
        createdAt: { type: Date, default: Date.now },
      },
    ],
  },
  { timestamps: true }
);

export default mongoose.model("clinical_data", ClinicalModel);
