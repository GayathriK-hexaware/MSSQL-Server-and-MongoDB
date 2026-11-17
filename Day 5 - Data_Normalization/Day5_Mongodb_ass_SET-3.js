
use("HospitalDB");

// Create clinical notes collection
db.createCollection("clinical_notes", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["patientId", "diagnosis", "noteDate"],
            properties: {
                patientId: {
                    bsonType: "int"
                },
                diagnosis: {
                    bsonType: "string"
                },
                noteDate: {
                    bsonType: "date"
                },
                prescription: {
                    bsonType: "array"
                },
                observations: {
                    bsonType: "object"
                },
                followUp: {
                    bsonType: "string"
                }
            }
        }
    }
});

// Insert documents with two different shapes
db.clinical_notes.insertMany([
    {
        patientId: 1,
        diagnosis: "Heart pain",
        noteDate: new Date("2026-11-01"),
        prescription: ["Medicine A", "Medicine B"],
        followUp: "After 7 days"
    },
    {
        patientId: 2,
        diagnosis: "Headache",
        noteDate: new Date("2026-11-05"),
        observations: {
            bloodPressure: "120/80",
            temperature: "98.6 F"
        },
        followUp: "After 3 days"
    },
    {
        patientId: 3,
        diagnosis: "Knee pain",
        noteDate: new Date("2026-10-10"),
        prescription: ["Pain relief tablet"]
    },
    {
        patientId: 4,
        diagnosis: "Tooth pain",
        noteDate: new Date("2026-11-12"),
        observations: {
            condition: "Mild infection"
        }
    }
]);

// View all clinical notes
db.clinical_notes.find();

// Find notes by diagnosis
db.clinical_notes.find({
    diagnosis: "Heart pain"
});
