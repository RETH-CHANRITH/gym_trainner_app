const admin = require('firebase-admin');

/**
 * Lazy-load Firestore instance to ensure Firebase is initialized first
 */
let dbInstance = null;

function getDb() {
  if (!dbInstance) {
    dbInstance = admin.firestore();
  }
  return dbInstance;
}

/**
 * Database service for Firestore operations
 */
class DatabaseService {
  /**
   * Get a document by ID
   */
  static async getDoc(collection, docId) {
    try {
      const doc = await getDb().collection(collection).doc(docId).get();
      return doc.exists ? { id: doc.id, ...doc.data() } : null;
    } catch (error) {
      console.error(`Error fetching ${collection}/${docId}:`, error);
      throw error;
    }
  }

  /**
   * Create a new document
   */
  static async createDoc(collection, data, customId = null) {
    try {
      const docRef = customId
        ? getDb().collection(collection).doc(customId)
        : getDb().collection(collection).doc();

      await docRef.set({
        ...data,
        createdAt: new Date(),
        updatedAt: new Date()
      });

      return { id: docRef.id, ...data };
    } catch (error) {
      console.error(`Error creating document in ${collection}:`, error);
      throw error;
    }
  }

  /**
   * Update a document
   */
  static async updateDoc(collection, docId, data) {
    try {
      await getDb().collection(collection).doc(docId).update({
        ...data,
        updatedAt: new Date()
      });

      return { id: docId, ...data };
    } catch (error) {
      console.error(`Error updating ${collection}/${docId}:`, error);
      throw error;
    }
  }

  /**
   * Delete a document
   */
  static async deleteDoc(collection, docId) {
    try {
      await getDb().collection(collection).doc(docId).delete();
      return { success: true };
    } catch (error) {
      console.error(`Error deleting ${collection}/${docId}:`, error);
      throw error;
    }
  }

  /**
   * Query documents with filters
   */
  static async query(collection, filters = [], orderBy = null, limit = 20, offset = 0) {
    try {
      let query = getDb().collection(collection);

      // Apply filters
      filters.forEach(({ field, operator, value }) => {
        query = query.where(field, operator, value);
      });

      // Apply ordering
      if (orderBy) {
        query = query.orderBy(orderBy.field, orderBy.direction || 'asc');
      }

      // Get total count
      const snapshot = await query.get();
      const total = snapshot.size;

      // Apply pagination
      const data = await query
        .limit(limit)
        .offset(offset)
        .get();

      return {
        items: data.docs.map(doc => ({ id: doc.id, ...doc.data() })),
        total,
        page: Math.floor(offset / limit) + 1,
        limit,
        hasMore: offset + limit < total
      };
    } catch (error) {
      console.error(`Error querying ${collection}:`, error);
      throw error;
    }
  }

  /**
   * Batch write operations
   */
  static async batch(operations) {
    try {
      const batch = getDb().batch();

      operations.forEach(({ type, collection, docId, data }) => {
        const docRef = getDb().collection(collection).doc(docId);
        switch (type) {
          case 'set':
            batch.set(docRef, data);
            break;
          case 'update':
            batch.update(docRef, data);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      });

      await batch.commit();
      return { success: true };
    } catch (error) {
      console.error('Batch operation error:', error);
      throw error;
    }
  }

  /**
   * Increment a numeric field
   */
  static async increment(collection, docId, field, value = 1) {
    try {
      await getDb().collection(collection).doc(docId).update({
        [field]: admin.firestore.FieldValue.increment(value)
      });
      return { success: true };
    } catch (error) {
      console.error(`Error incrementing ${field}:`, error);
      throw error;
    }
  }
}

module.exports = DatabaseService;
