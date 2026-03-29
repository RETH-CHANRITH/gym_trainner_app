// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE: Simple Node.js + Express Backend for Your Flutter App
// This shows the structure your APIs should follow
// ═══════════════════════════════════════════════════════════════════════════

// FILE: server.js
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Firebase
admin.initializeApp({
  credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

const db = admin.firestore();

// ───────────────────────────────────────────────────────────────────────────
// MIDDLEWARE: Verify Firebase ID Token
// ───────────────────────────────────────────────────────────────────────────

const verifyToken = async (req, res, next) => {
  const token = req.headers.authorization?.split('Bearer ')[1];
  if (!token) {
    return res.status(401).json({ error: 'No auth token provided' });
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// ───────────────────────────────────────────────────────────────────────────
// USER ENDPOINTS
// ───────────────────────────────────────────────────────────────────────────

// GET /api/v1/users/profile - Get current user's profile
app.get('/api/v1/users/profile', verifyToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      success: true,
      data: {
        id: userDoc.id,
        ...userDoc.data(),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch profile',
    });
  }
});

// PUT /api/v1/users/profile - Update user profile
app.put('/api/v1/users/profile', verifyToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const { name, bio, photoUrl, fitnessProfile } = req.body;

    // Validation
    if (!name || name.trim().length === 0) {
      return res.status(400).json({ error: 'Name is required' });
    }

    await db.collection('users').doc(userId).update({
      name: name.trim(),
      bio: bio?.trim() || '',
      photoUrl: photoUrl || null,
      fitnessProfile: fitnessProfile || {},
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const updatedDoc = await db.collection('users').doc(userId).get();

    res.json({
      success: true,
      data: {
        id: updatedDoc.id,
        ...updatedDoc.data(),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to update profile',
    });
  }
});

// GET /api/v1/users/search - Search users (admin or pagination)
app.get('/api/v1/users/search', verifyToken, async (req, res) => {
  try {
    const { q, page = 1, pageSize = 20 } = req.query;
    const skip = (page - 1) * pageSize;

    let query = db.collection('users');

    // Apply search filter if provided
    if (q) {
      query = query.where('name', '>=', q).where('name', '<=', q + '\uf8ff');
    }

    const snapshot = await query
      .orderBy('createdAt', 'desc')
      .offset(skip)
      .limit(parseInt(pageSize) + 1)
      .get();

    const items = snapshot.docs.slice(0, pageSize).map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    const hasMore = snapshot.docs.length > pageSize;

    res.json({
      success: true,
      data: {
        items,
        total: snapshot.size,
        page: parseInt(page),
        pageSize: parseInt(pageSize),
        hasMore,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Search failed',
    });
  }
});

// ───────────────────────────────────────────────────────────────────────────
// TRAINER ENDPOINTS
// ───────────────────────────────────────────────────────────────────────────

// GET /api/v1/trainers - Get all trainers with filters
app.get('/api/v1/trainers', async (req, res) => {
  try {
    const {
      specialization,
      location,
      minRating,
      page = 1,
      pageSize = 20,
    } = req.query;

    const skip = (page - 1) * pageSize;

    let query = db.collection('users').where('role', '==', 'trainer');

    if (specialization) {
      query = query.where('specialization', '==', specialization);
    }

    if (minRating) {
      query = query.where('rating', '>=', parseFloat(minRating));
    }

    const snapshot = await query
      .orderBy('rating', 'desc')
      .offset(skip)
      .limit(parseInt(pageSize) + 1)
      .get();

    const items = snapshot.docs.slice(0, pageSize).map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    const hasMore = snapshot.docs.length > pageSize;

    res.json({
      success: true,
      data: {
        items,
        total: snapshot.size,
        page: parseInt(page),
        pageSize: parseInt(pageSize),
        hasMore,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to load trainers',
    });
  }
});

// POST /api/v1/trainers/applications - Apply to become trainer
app.post('/api/v1/trainers/applications', verifyToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const { bio, specialization, certifications, hourlyRate } = req.body;

    // Validation
    if (!bio || !specialization || !hourlyRate) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const applicationRef = await db.collection('trainerApplications').add({
      userId,
      bio,
      specialization,
      certifications: certifications || [],
      hourlyRate: parseFloat(hourlyRate),
      status: 'pending',
      submittedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const appDoc = await applicationRef.get();

    res.json({
      success: true,
      data: {
        id: appDoc.id,
        ...appDoc.data(),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Application submission failed',
    });
  }
});

// GET /api/v1/trainers/availability/:trainerId - Get trainer availability
app.get('/api/v1/trainers/availability/:trainerId', async (req, res) => {
  try {
    const { trainerId } = req.params;

    const availDoc = await db
      .collection('trainers')
      .doc(trainerId)
      .collection('availability')
      .orderBy('startTime')
      .get();

    const slots = availDoc.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json({
      success: true,
      data: {
        trainerId,
        slots,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to load availability',
    });
  }
});

// ───────────────────────────────────────────────────────────────────────────
// BOOKING ENDPOINTS
// ───────────────────────────────────────────────────────────────────────────

// POST /api/v1/bookings - Create new booking
app.post('/api/v1/bookings', verifyToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const { trainerId, scheduledAt, durationMinutes } = req.body;

    // Validation
    if (!trainerId || !scheduledAt || !durationMinutes) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Check trainer exists
    const trainerDoc = await db.collection('users').doc(trainerId).get();
    if (!trainerDoc.exists || trainerDoc.data().role !== 'trainer') {
      return res.status(404).json({ error: 'Trainer not found' });
    }

    // Calculate price (example: $50/hour)
    const hourlyRate = trainerDoc.data().hourlyRate || 50;
    const price = (durationMinutes / 60) * hourlyRate;

    // Create booking
    const bookingRef = await db.collection('bookings').add({
      userId,
      trainerId,
      scheduledAt: new Date(scheduledAt),
      durationMinutes: parseInt(durationMinutes),
      price,
      status: 'confirmed',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const bookingDoc = await bookingRef.get();

    res.json({
      success: true,
      data: {
        id: bookingDoc.id,
        ...bookingDoc.data(),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Booking creation failed',
    });
  }
});

// GET /api/v1/bookings - Get user's bookings
app.get('/api/v1/bookings', verifyToken, async (req, res) => {
  try {
    const userId = req.user.uid;
    const { status, page = 1, pageSize = 20 } = req.query;

    const skip = (page - 1) * pageSize;

    let query = db.collection('bookings').where('userId', '==', userId);

    if (status) {
      query = query.where('status', '==', status);
    }

    const snapshot = await query
      .orderBy('scheduledAt', 'desc')
      .offset(skip)
      .limit(parseInt(pageSize) + 1)
      .get();

    const items = snapshot.docs.slice(0, pageSize).map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    const hasMore = snapshot.docs.length > pageSize;

    res.json({
      success: true,
      data: {
        items,
        total: snapshot.size,
        page: parseInt(page),
        pageSize: parseInt(pageSize),
        hasMore,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to load bookings',
    });
  }
});

// DELETE /api/v1/bookings/:id/cancel - Cancel booking
app.delete('/api/v1/bookings/:id/cancel', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.uid;

    const bookingDoc = await db.collection('bookings').doc(id).get();

    if (!bookingDoc.exists) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    // Verify user owns booking
    if (bookingDoc.data().userId !== userId) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    await db.collection('bookings').doc(id).update({
      status: 'cancelled',
      cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      success: true,
      message: 'Booking cancelled',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Cancellation failed',
    });
  }
});

// ───────────────────────────────────────────────────────────────────────────
// HEALTH CHECK
// ───────────────────────────────────────────────────────────────────────────

app.get('/health', (req, res) => {
  res.json({ status: 'OK' });
});

// ───────────────────────────────────────────────────────────────────────────
// ERROR HANDLING
// ───────────────────────────────────────────────────────────────────────────

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
  });
});

// ───────────────────────────────────────────────────────────────────────────
// START SERVER
// ───────────────────────────────────────────────────────────────────────────

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});

// ═══════════════════════════════════════════════════════════════════════════

/*
DEPLOYMENT TIPS:

1. Local Development:
   npm install
   npm start

2. Environment Variables (.env):
   PORT=5000
   FIREBASE_PROJECT_ID=your-project
   FIREBASE_PRIVATE_KEY=...
   FIREBASE_CLIENT_EMAIL=...

3. Deploy to Flask/Render/Railway:
   git push heroku main

4. API Base URL Update:
   In api_models.dart:
   static const String baseUrl = 'https://your-deployed-api.com/api/v1';
*/
