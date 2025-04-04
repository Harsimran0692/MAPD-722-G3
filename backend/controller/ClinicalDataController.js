import ClinicalModel from "../model/ClinicalModel.js";
import PatientModel from "../model/PatientModel.js";

export const getClinicalData = async (req, res) => {
  try {
    const clinicalRecords = await ClinicalModel.find().populate("patientId");
    res.status(200).json(clinicalRecords);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

export const getPatientClinicalData = async (req, res) => {
  try {
    const { id } = req.params; // This is the ID from the request (e.g., a patient's ID)

    // Search for a document where patientId matches the provided id
    const patient = await ClinicalModel.findOne({ patientId: id });

    if (patient) {
      res.status(200).json({ message: "Patient found", data: patient });
    } else {
      res.status(404).json({ message: "Patient not found" });
    }
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

export const getClinicalDataById = async (req, res) => {
  try {
    const { id } = req.params;
    const clinicalRecord = await ClinicalModel.findById(id).populate(
      "patientId"
    );
    if (!clinicalRecord) {
      return res.status(404).json({ message: "Clinical record not found." });
    }
    res.status(200).json(clinicalRecord);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

export const addClinicalData = async (req, res) => {
  try {
    const {
      patientId,
      status,
      systolicPressure,
      diastolicPressure,
      respirationRate,
      bloodOxygenation,
      heartRate,
      doctorNotes,
    } = req.body;

    // Check if all required fields are provided
    if (
      !patientId ||
      !systolicPressure ||
      !diastolicPressure ||
      !respirationRate ||
      !bloodOxygenation ||
      !heartRate
    ) {
      return res
        .status(400)
        .json({ message: "All required fields must be provided." });
    }

    // Validate that patientId exists in the Patients collection
    const patientExists = await PatientModel.findById(patientId);
    if (!patientExists) {
      return res
        .status(400)
        .json({ message: "Invalid patientId: Patient not found." });
    }

    // Check if a clinical record already exists for this patientId
    const existingRecord = await ClinicalModel.findOne({ patientId });
    if (existingRecord) {
      return res.status(409).json({
        message: "Clinical record already exists for this patient.",
      });
    }

    // Create new clinical record
    const newClinicalRecord = new ClinicalModel({
      patientId,
      status,
      systolicPressure,
      diastolicPressure,
      respirationRate,
      bloodOxygenation,
      heartRate,
      doctorNotes,
    });

    // Save to database
    await newClinicalRecord.save();

    // Optionally populate patientId in the response
    const populatedRecord = await ClinicalModel.findById(
      newClinicalRecord._id
    ).populate("patientId");

    res.status(201).json({
      message: "Clinical record created successfully.",
      clinicalRecord: populatedRecord || newClinicalRecord,
    });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Delete clinical record by ID
export const deleteClinicalDataById = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedRecord = await ClinicalModel.findByIdAndDelete(id);
    if (!deletedRecord) {
      return res.status(404).json({ message: "Clinical record not found." });
    }
    res.status(200).json({ message: "Clinical record deleted successfully." });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Update clinical record by ID
export const updateClinicalData = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body; // Get the updated data from the request body

    // Validate that updateData is provided
    if (!updateData || Object.keys(updateData).length === 0) {
      return res.status(400).json({ message: "No update data provided." });
    }

    // Find and update the clinical record
    const updatedRecord = await ClinicalModel.findByIdAndUpdate(
      id,
      { $set: updateData }, // Update all fields in updateData
      { new: true, runValidators: true } // Return the updated document and run schema validators
    );

    if (!updatedRecord) {
      return res.status(404).json({ message: "Clinical record not found." });
    }

    res.status(200).json({
      message: "Clinical record updated successfully.",
      clinicalRecord: updatedRecord,
    });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};
