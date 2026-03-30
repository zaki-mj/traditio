const admin = require('firebase-admin');
const fs = require('fs');
const csv = require('csv-parser');

// 1. Initialize Firebase Admin
// Replace 'serviceAccountKey.json' with the path to your downloaded key
const serviceAccount = require('./traditionalgems-4e869-firebase-adminsdk-fbsvc-7c02c77c54.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// 2. Configuration
const CSV_FILE_PATH = 'database.csv'; // Path to your generated CSV
const COLLECTION_NAME = 'points_of_interest';

async function uploadCSV() {
  const batch = db.batch();
  let count = 0;

  console.log('Starting upload...');

  fs.createReadStream(CSV_FILE_PATH)
    .pipe(csv())
    .on('data', (row) => {
      // Map CSV columns to your PointOfInterest Firestore Map structure
      const poiData = {
        name_ar: row.nameAR,
        name_fr: row.nameFR,
        wilaya_code: row.wilayaCode,
        wilaya_name_ar: row.wilayaNameAR,
        wilaya_name_fr: row.wilayaNameFR,
        city_name_ar: row.cityNameAR || null,
        city_name_fr: row.cityNameFR || null,
        rating: parseFloat(row.rating) || 0,
        category: parseInt(row.category) || 5,
        description_ar: row.descriptionAR || null,
        description_fr: row.descriptionFR || null,
        description_en: row.descriptionEN || null,
        // Computed description logic as per your Dart class
        description: row.descriptionFR || row.descriptionEN || row.descriptionAR || null,
        phone: row.phone || null,
        email: row.email || null,
        location_link: row.location_link || null,
        facebook_link: row.facebook_link || null,
        instagram_link: row.instagram_link || null,
        tiktok_link: row.tiktok_link || null,
        image_urls: row.image_urls ? row.image_urls.split(',') : [],
        created_at: row.created_at || new Date().toISOString(),
        updated_at: new Date().toISOString(),
        recommended: row.recommended === 'true'
      };

      // Create a new document reference with an auto-generated ID
      const docRef = db.collection(COLLECTION_NAME).doc();
      batch.set(docRef, poiData);
      
      count++;
    })
    .on('end', async () => {
      try {
        // Firestore batches are limited to 500 operations
        // For very large datasets, you might need to commit every 500 rows
        await batch.commit();
        console.log(`Successfully uploaded ${count} points of interest to ${COLLECTION_NAME}.`);
      } catch (error) {
        console.error('Error committing batch to Firestore:', error);
      }
    });
}

uploadCSV();