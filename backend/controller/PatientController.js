import ClinicalModel from "../model/ClinicalModel.js";
import PatientModel from "../model/PatientModel.js";

export const GetPatients = async (req, res) => {
  try {
    const patients = await PatientModel.find();
    res.status(200).json(patients);
  } catch (error) {
    res.status(500).json({ message: "server error", error: error.message });
  }
};

export const GetPatientById = async (req, res) => {
  const PatientId = req.params.id;
  try {
    const patient = await PatientModel.findById(PatientId);

    if (!patient) {
      res.status(404).json({ message: "Patient not Found" });
      return;
    }
    res.status(200).json({ patient });
  } catch (error) {
    res.status(500).json({
      message: "Error fetching Patient",
      error: error.message,
    });
  }
};

export const AddPatient = async (req, res) => {
  const { name, age, dob, gender, email } = req.body;

  try {
    let existingPatient = await PatientModel.findOne({ email });

    if (existingPatient) {
      res.status(400).json({
        message: "Patient already exist",
      });
      return;
    }
    const newPatient = await PatientModel.create({
      name,
      age,
      dob,
      gender,
      email,
    });

    res.status(201).json({
      message: "Patient added Successfully",
      patient: newPatient,
    });
  } catch (error) {
    res.status(500).json({ message: "server error", error: error.message });
  }
};

export const UpdatePatient = async (req, res) => {
  const patientId = req.params.id; // Renamed for clarity (Patient -> patientId)
  const { name, age, dob, email } = req.body;

  const updatedFields = {};

  try {
    // Check if patient exists
    const patientExist = await PatientModel.findById(patientId);
    if (!patientExist) {
      return res.status(404).json({ message: "Patient not Found" });
    }

    // Add fields to updatedFields only if they exist in req.body
    if (name) updatedFields.name = name;
    if (age) updatedFields.age = age;
    if (dob) updatedFields.dob = dob;
    if (email) {
      // Check if the new email is already in use by another patient
      const emailExists = await PatientModel.findOne({
        email: email.toLowerCase(),
      });
      if (emailExists && emailExists._id.toString() !== patientId) {
        return res
          .status(400)
          .json({ message: "Email already in use by another patient" });
      }
      updatedFields.email = email; // Use the correct field name
    }

    // Perform the update
    const updatedPatient = await PatientModel.findByIdAndUpdate(
      patientId,
      updatedFields,
      { new: true, runValidators: true } // Ensure validators are run
    );

    // Respond with success
    res.status(200).json({
      message: "Patient updated Successfully",
      patient: updatedPatient,
    });
  } catch (error) {
    // Handle specific errors
    if (error.name === "MongoError" && error.code === 11000) {
      return res
        .status(400)
        .json({ message: "Duplicate email error", error: error.message });
    }
    res
      .status(500)
      .json({ message: "Error updating patient", error: error.message });
  }
};

export const DeletePatient = async (req, res) => {
  const PatientId = req.params.id;

  try {
    const PatientExist = await PatientModel.findById(PatientId);

    if (!PatientExist) {
      res.status(404).json({ message: "Patient not Found" });
      return;
    }
    await ClinicalModel.deleteMany({ patientId: PatientId });
    const deletePatient = await PatientModel.findByIdAndDelete(PatientId);
    res
      .status(200)
      .json({ message: "Patient deleted Successfully", deletePatient });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error fetching Patient", error: error.mesage });
  }
};
