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
  const Patient = req.params.id;
  const { name, age, dob, email } = req.body;
  const updatedFields = {};

  try {
    const PatientExist = await PatientModel.findById(Patient);
    if (!PatientExist) {
      res.status(404).json({ message: "Patient not Found" });
      return;
    }
    if (name) updatedFields.name = name;
    if (age) updatedFields.age = age;
    if (dob) updatedFields.dob = dob;
    if (email) updatedFields.emai = email;

    const UpdatePatient = await PatientModel.findByIdAndUpdate(
      Patient,
      updatedFields,
      { new: true }
    );
    res
      .status(200)
      .json({ mesage: "Patient updated Successfully", patient: UpdatePatient });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error fetching Patient", error: error.message });
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
