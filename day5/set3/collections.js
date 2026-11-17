
// DAY 5 ASSIGNMENT - SET 3
// Hospital Patient Records and Clinical Notes

use HospitalManagementDB

// Create clinicalNotes collection with JSON Schema validation
db.createCollection("clinicalNotes", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: [
                "patientId",
                "visitId",
                "diagnosis",
                "noteDate"
            ],
            properties: {
                patientId: {
                    bsonType: "int"
                },
                visitId: {
                    bsonType: "int"
                },
                diagnosis: {
                    bsonType: "string"
                },
                noteDate: {
                    bsonType: "date"
                },
                symptoms: {
                    bsonType: "array",
                    items: {
                        bsonType: "string"
                    }
                },
                observations: {
                    bsonType: "object"
                },
                medications: {
                    bsonType: "array"
                },
                followUp: {
                    bsonType: "string"
                },
                doctorNotes: {
                    bsonType: "string"
                }
            }
        }
    },
    validationLevel: "strict",
    validationAction: "error"
});



// Document 1 - Clinical note with symptoms and medications
db.clinicalNotes.insertOne({
    patientId: NumberInt(1),
    visitId: NumberInt(1),
    diagnosis: "Heart Pain",
    noteDate: new Date("2026-10-01"),
    symptoms: [
        "Chest pain",
        "Breathing difficulty",
        "Fatigue"
    ],
    observations: {
        bloodPressure: "130/90",
        heartRate: 95,
        temperature: "98.6F"
    },
    medications: [
        {
            name: "Medicine A",
            dosage: "One tablet daily"
        },
        {
            name: "Medicine B",
            dosage: "Twice daily"
        }
    ],
    followUp: "After 7 days"
});


// Document 2 - Clinical note with different structure
db.clinicalNotes.insertOne({
    patientId: NumberInt(2),
    visitId: NumberInt(2),
    diagnosis: "Headache",
    noteDate: new Date("2026-10-05"),
    symptoms: [
        "Headache",
        "Dizziness"
    ],
    doctorNotes: "Patient advised to take rest and drink sufficient water.",
    followUp: "After 3 days"
});



// Display all clinical notes
db.clinicalNotes.find().pretty();

// Display only patient ID and diagnosis
db.clinicalNotes.find(
    {},
    {
        patientId: 1,
        diagnosis: 1,
        _id: 0
    }
);



// Find patients diagnosed with Heart Pain
db.clinicalNotes.find({
    diagnosis: "Heart Pain"
});

// Find patients diagnosed with Headache
db.clinicalNotes.find({
    diagnosis: "Headache"
});

// Find all notes with a diagnosis containing "Heart"
db.clinicalNotes.find({
    diagnosis: {
        $regex: "Heart",
        $options: "i"
    }
});



// Update clinical note
db.clinicalNotes.updateOne(
    {
        patientId: NumberInt(1)
    },
    {
        $set: {
            followUp: "After 10 days",
            doctorNotes: "Patient condition improved"
        }
    }
);

// Verify update
db.clinicalNotes.find({
    patientId: NumberInt(1)
});

// Delete one clinical note
db.clinicalNotes.deleteOne({
    patientId: NumberInt(2)
});

// Verify deletion
db.clinicalNotes.find();
