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
      default: "Stable",
    },
    systolicPressure: {
      type: Number,
      required: true,
    },
    diastolicPressure: {
      type: Number,
      required: true,
    },
    respirationRate: {
      type: Number,
      required: true,
    },
    bloodOxygenation: {
      type: Number,
      required: true,
    },
    heartRate: {
      type: Number,
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
