import HistoryModel from "../model/historyModel.js";
import PatientModel from "../model/PatientModel.js";

// Get history for a specific patient
export const getHistory = async (req, res) => {
  try {
    const patientId = req.params.patientId; // Assuming patientId is passed as a URL parameter

    // Find all history records for the given patient
    const history = await HistoryModel.find({ patientId: patientId })
      .populate("patientId", "name") // Optionally populate patient details
      .sort({ createdAt: -1 }); // Sort by most recent

    if (!history.length) {
      return res
        .status(404)
        .json({ message: "No history found for this patient" });
    }

    res.status(200).json({
      success: true,
      data: history,
      message: "History retrieved successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error retrieving history",
      error: error.message,
    });
  }
};

// Add new history for a patient
export const addHistory = async (req, res) => {
  try {
    const patientId = req.params.patientId; // Assuming patientId is passed as a URL parameter
    const {
      systolicPressure,
      diastolicPressure,
      respirationRate,
      bloodOxygenation,
      heartRate,
      doctorNotes,
    } = req.body;

    // Validate patient exists
    const patient = await PatientModel.findById(patientId);
    if (!patient) {
      return res.status(404).json({ message: "Patient not found" });
    }

    // Create new history record
    const newHistory = new HistoryModel({
      patientId,
      systolicPressure,
      diastolicPressure,
      respirationRate,
      bloodOxygenation,
      heartRate,
      doctorNotes: doctorNotes || [], // Default to empty array if no notes
    });

    const savedHistory = await newHistory.save();

    res.status(201).json({
      success: true,
      data: savedHistory,
      message: "History added successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error adding history",
      error: error.message,
    });
  }
};

// Update existing history for a patient
export const updateHistory = async (req, res) => {
  try {
    const historyId = req.params.historyId; // Assuming historyId is passed as a URL parameter
    const {
      systolicPressure,
      diastolicPressure,
      respirationRate,
      bloodOxygenation,
      heartRate,
      doctorNotes,
    } = req.body;

    // Find and update the history record
    const updatedHistory = await HistoryModel.findByIdAndUpdate(
      historyId,
      {
        systolicPressure,
        diastolicPressure,
        respirationRate,
        bloodOxygenation,
        heartRate,
        doctorNotes: doctorNotes || [], // Update or keep existing notes
        updatedAt: Date.now(), // Update the timestamp
      },
      { new: true, runValidators: true } // Return the updated document and run schema validation
    );

    if (!updatedHistory) {
      return res.status(404).json({ message: "History record not found" });
    }

    res.status(200).json({
      success: true,
      data: updatedHistory,
      message: "History updated successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error updating history",
      error: error.message,
    });
  }
};
