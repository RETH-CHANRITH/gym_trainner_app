const {onRequest} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');

admin.initializeApp();

const db = admin.firestore();
const app = express();
app.use(cors({origin: true}));
app.use(express.json());

const rolePermissions = {
  super_admin: ['*'],
  admin: [
    'users.read',
    'users.write',
    'trainers.read',
    'trainers.write',
    'bookings.read',
    'bookings.write',
    'support.read',
    'support.write',
    'analytics.read',
    'finance.read',
    'finance.write',
    'payouts.read',
    'payouts.write',
    'refunds.read',
    'refunds.write',
    'marketing.read',
    'marketing.write',
    'content.read',
    'content.write',
    'community.read',
    'community.write',
    'reports.read',
    'reports.write',
    'audit.read',
    'gdpr.read',
    'gdpr.write',
    'system.read',
    'system.write'
  ],
  support_admin: ['users.read', 'support.read', 'support.write', 'gdpr.read', 'gdpr.write'],
  finance_admin: ['finance.read', 'finance.write', 'payouts.read', 'payouts.write', 'refunds.read', 'refunds.write'],
  moderator: ['users.read', 'community.read', 'community.write', 'reports.read', 'reports.write'],
  read_only_admin: ['users.read', 'trainers.read', 'bookings.read', 'analytics.read', 'audit.read']
};

const endpointPermissions = {
  'POST /admin/auth/verify-session': 'system.read',
  'POST /admin/auth/force-logout-user': 'users.write',
  'POST /admin/auth/reset-user-password': 'users.write',

  'GET /admin/users': 'users.read',
  'GET /admin/users/:uid': 'users.read',
  'PATCH /admin/users/:uid': 'users.write',
  'POST /admin/users/:uid/suspend': 'users.write',
  'POST /admin/users/:uid/reactivate': 'users.write',
  'DELETE /admin/users/:uid': 'users.write',
  'GET /admin/users/:uid/login-activity': 'users.read',

  'GET /admin/trainer-applications': 'trainers.read',
  'GET /admin/trainer-applications/:id': 'trainers.read',
  'POST /admin/trainer-applications/:id/approve': 'trainers.write',
  'POST /admin/trainer-applications/:id/reject': 'trainers.write',
  'POST /admin/trainers/:id/verify-credentials': 'trainers.write',
  'POST /admin/trainers/:id/suspend': 'trainers.write',
  'POST /admin/trainers/:id/ban': 'trainers.write',
  'POST /admin/trainers/:id/warn': 'trainers.write',
  'PATCH /admin/trainers/:id/badge-level': 'trainers.write',
  'GET /admin/trainers/:id/performance': 'trainers.read',

  'GET /admin/bookings': 'bookings.read',
  'PATCH /admin/bookings/:id': 'bookings.write',
  'POST /admin/bookings/:id/cancel': 'bookings.write',
  'POST /admin/bookings/:id/reassign': 'bookings.write',
  'GET /admin/disputes': 'reports.read',
  'POST /admin/disputes/:id/assign': 'reports.write',
  'POST /admin/disputes/:id/resolve': 'reports.write',

  'GET /admin/finance/revenue-summary': 'finance.read',
  'GET /admin/finance/transactions': 'finance.read',
  'GET /admin/refunds': 'refunds.read',
  'POST /admin/refunds/:id/approve': 'refunds.write',
  'POST /admin/refunds/:id/reject': 'refunds.write',
  'POST /admin/refunds/:id/process': 'refunds.write',
  'GET /admin/payouts': 'payouts.read',
  'POST /admin/payouts/:id/approve': 'payouts.write',
  'POST /admin/payouts/:id/reject': 'payouts.write',
  'POST /admin/payouts/:id/mark-paid': 'payouts.write',
  'PATCH /admin/commission-rates': 'finance.write',
  'GET /admin/subscription-plans': 'finance.read',
  'PATCH /admin/subscription-plans/:id': 'finance.write',

  'GET /admin/analytics/user-growth': 'analytics.read',
  'GET /admin/analytics/booking-conversion': 'analytics.read',
  'GET /admin/analytics/popular-trainers': 'analytics.read',
  'GET /admin/analytics/peak-usage': 'analytics.read',
  'GET /admin/analytics/retention-churn': 'analytics.read',
  'POST /admin/reports/export': 'analytics.read',

  'GET /admin/coupons': 'marketing.read',
  'POST /admin/coupons': 'marketing.write',
  'PATCH /admin/coupons/:code': 'marketing.write',
  'POST /admin/coupons/:code/disable': 'marketing.write',
  'GET /admin/campaigns': 'marketing.read',
  'POST /admin/campaigns': 'marketing.write',
  'PATCH /admin/campaigns/:id': 'marketing.write',
  'POST /admin/campaigns/:id/send': 'marketing.write',
  'GET /admin/campaigns/:id/performance': 'marketing.read',

  'GET /admin/challenges': 'content.read',
  'POST /admin/challenges': 'content.write',
  'PATCH /admin/challenges/:id': 'content.write',
  'DELETE /admin/challenges/:id': 'content.write',
  'GET /admin/content-library': 'content.read',
  'POST /admin/content-library': 'content.write',
  'PATCH /admin/content-library/:id': 'content.write',
  'DELETE /admin/content-library/:id': 'content.write',
  'GET /admin/community/reports': 'community.read',
  'POST /admin/community/reports/:id/action': 'community.write',

  'GET /admin/roles-permissions': 'system.read',
  'PATCH /admin/roles-permissions': 'system.write',
  'GET /admin/audit-logs': 'audit.read',
  'POST /admin/system/backup': 'system.write',
  'POST /admin/system/restore': 'system.write',
  'GET /admin/system/health': 'system.read',
  'PATCH /admin/system/settings': 'system.write',

  'GET /admin/gdpr-requests': 'gdpr.read',
  'POST /admin/gdpr-requests/:id/verify-identity': 'gdpr.write',
  'POST /admin/gdpr-requests/:id/complete': 'gdpr.write'
};

function traceId(req) {
  return req.get('x-request-id') || req.get('x-correlation-id') || `${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
}

async function writeAuditLog({actorId, action, targetId, before, after, requestId, status}) {
  await db.collection('auditLogs').add({
    actorId,
    action,
    targetId: targetId || null,
    before: before || null,
    after: after || null,
    requestId,
    status,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
}

async function withAdmin(req, res, next) {
  try {
    const authHeader = req.get('authorization') || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
    if (!token) {
      return res.status(401).json({error: 'missing_token'});
    }

    const decoded = await admin.auth().verifyIdToken(token, true);
    const userDoc = await db.collection('users').doc(decoded.uid).get();
    const role =
      decoded.adminRole ||
      decoded.role ||
      (userDoc.exists ? userDoc.data().role : null) ||
      'user';

    req.adminContext = {
      uid: decoded.uid,
      role,
      permissions: rolePermissions[role] || []
    };

    return next();
  } catch (err) {
    return res.status(401).json({error: 'invalid_session'});
  }
}

function requires(permission) {
  return async (req, res, next) => {
    const requestId = traceId(req);
    const ctx = req.adminContext || {permissions: []};
    const allowed = ctx.permissions.includes('*') || ctx.permissions.includes(permission);

    if (!allowed) {
      await writeAuditLog({
        actorId: ctx.uid || null,
        action: `forbidden:${req.method} ${req.route.path}`,
        requestId,
        status: 'denied'
      });
      return res.status(403).json({error: 'forbidden', requestId});
    }

    req.requestId = requestId;
    return next();
  };
}

function registerStub(method, path) {
  const key = `${method.toUpperCase()} ${path}`;
  const permission = endpointPermissions[key] || 'system.read';

  app[method](path, withAdmin, requires(permission), async (req, res) => {
    await writeAuditLog({
      actorId: req.adminContext.uid,
      action: `stub:${key}`,
      targetId: req.params.id || req.params.uid || req.params.code || null,
      requestId: req.requestId,
      status: 'not_implemented'
    });

    return res.status(501).json({
      message: 'Endpoint scaffolded but not implemented yet',
      endpoint: key,
      requestId: req.requestId
    });
  });
}

app.post('/admin/auth/verify-session', withAdmin, requires('system.read'), async (req, res) => {
  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'verify-session',
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({
    ok: true,
    uid: req.adminContext.uid,
    role: req.adminContext.role,
    permissions: req.adminContext.permissions
  });
});

app.get('/admin/roles-permissions', withAdmin, requires('system.read'), (req, res) => {
  return res.json({rolePermissions});
});

app.get('/admin/system/health', withAdmin, requires('system.read'), (req, res) => {
  return res.json({ok: true, service: 'admin-api', timestamp: Date.now()});
});

app.post('/admin/users/:uid/suspend', withAdmin, requires('users.write'), async (req, res) => {
  const uid = req.params.uid;
  const reason = req.body.reason || null;
  const ref = db.collection('users').doc(uid);
  const beforeDoc = await ref.get();
  const before = beforeDoc.exists ? beforeDoc.data() : null;

  await ref.set(
    {
      accountStatus: 'suspended',
      suspendedReason: reason,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );

  const afterDoc = await ref.get();
  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'users.suspend',
    targetId: uid,
    before,
    after: afterDoc.data(),
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, uid, accountStatus: 'suspended', requestId: req.requestId});
});

app.post('/admin/users/:uid/reactivate', withAdmin, requires('users.write'), async (req, res) => {
  const uid = req.params.uid;
  const ref = db.collection('users').doc(uid);
  const beforeDoc = await ref.get();
  const before = beforeDoc.exists ? beforeDoc.data() : null;

  await ref.set(
    {
      accountStatus: 'active',
      suspendedReason: admin.firestore.FieldValue.delete(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );

  const afterDoc = await ref.get();
  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'users.reactivate',
    targetId: uid,
    before,
    after: afterDoc.data(),
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, uid, accountStatus: 'active', requestId: req.requestId});
});

app.post('/admin/trainer-applications/:id/approve', withAdmin, requires('trainers.write'), async (req, res) => {
  const id = req.params.id;
  const appRef = db.collection('trainerApplications').doc(id);
  const beforeDoc = await appRef.get();
  if (!beforeDoc.exists) {
    return res.status(404).json({error: 'not_found', requestId: req.requestId});
  }

  const before = beforeDoc.data();
  const userId = before.userId || null;

  await appRef.set(
    {
      status: 'approved',
      reviewedBy: req.adminContext.uid,
      reviewedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );

  if (userId) {
    await db.collection('users').doc(userId).set(
      {
        role: 'trainer',
        accountStatus: 'active',
        trainerApproved: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.adminContext.uid
      },
      {merge: true}
    );
  }

  const afterDoc = await appRef.get();
  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'trainer-applications.approve',
    targetId: id,
    before,
    after: afterDoc.data(),
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, id, status: 'approved', requestId: req.requestId});
});

app.post('/admin/trainer-applications/:id/reject', withAdmin, requires('trainers.write'), async (req, res) => {
  const id = req.params.id;
  const notes = req.body.notes || null;
  const appRef = db.collection('trainerApplications').doc(id);
  const beforeDoc = await appRef.get();
  if (!beforeDoc.exists) {
    return res.status(404).json({error: 'not_found', requestId: req.requestId});
  }

  const before = beforeDoc.data();
  await appRef.set(
    {
      status: 'rejected',
      reviewerNotes: notes,
      reviewedBy: req.adminContext.uid,
      reviewedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );

  const afterDoc = await appRef.get();
  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'trainer-applications.reject',
    targetId: id,
    before,
    after: afterDoc.data(),
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, id, status: 'rejected', requestId: req.requestId});
});

app.post('/admin/bookings/:id/cancel', withAdmin, requires('bookings.write'), async (req, res) => {
  const id = req.params.id;
  const reason = req.body.reason || null;
  const ref = db.collection('bookings').doc(id);
  const beforeDoc = await ref.get();
  if (!beforeDoc.exists) {
    return res.status(404).json({error: 'not_found', requestId: req.requestId});
  }

  const before = beforeDoc.data();
  await ref.set(
    {
      status: 'cancelled',
      cancelledBy: req.adminContext.uid,
      cancelReason: reason,
      cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );

  const afterDoc = await ref.get();
  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'bookings.cancel',
    targetId: id,
    before,
    after: afterDoc.data(),
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, id, status: 'cancelled', requestId: req.requestId});
});

function parseLimit(req) {
  const raw = Number.parseInt(req.query.limit, 10);
  if (Number.isNaN(raw)) return 25;
  return Math.max(1, Math.min(raw, 100));
}

function normalizeText(value) {
  return (value || '').toString().trim().toLowerCase();
}

function applySearch(items, search, fields) {
  if (!search) return items;
  const needle = normalizeText(search);
  if (!needle) return items;

  return items.filter((item) => {
    return fields.some((field) => normalizeText(item[field]).includes(needle));
  });
}

async function readStartAfterDoc(collectionName, startAfterId) {
  if (!startAfterId) return null;
  const snap = await db.collection(collectionName).doc(startAfterId).get();
  return snap.exists ? snap : null;
}

function docsToList(docs) {
  return docs.map((doc) => ({id: doc.id, ...doc.data()}));
}

async function queryCollectionPage({
  collectionName,
  limit,
  startAfterId,
  orderByField,
  whereClauses = []
}) {
  let query = db.collection(collectionName);
  whereClauses.forEach(([field, op, value]) => {
    query = query.where(field, op, value);
  });

  query = query.orderBy(orderByField, 'desc');

  const startAfterDoc = await readStartAfterDoc(collectionName, startAfterId);
  if (startAfterDoc) {
    query = query.startAfter(startAfterDoc);
  }

  const snap = await query.limit(limit).get();
  const items = docsToList(snap.docs);
  const nextCursor = snap.docs.length === limit ? snap.docs[snap.docs.length - 1].id : null;
  return {items, nextCursor};
}

app.get('/admin/users', withAdmin, requires('users.read'), async (req, res) => {
  try {
    const limit = parseLimit(req);
    const startAfterId = req.query.startAfterId || null;
    const role = req.query.role || null;
    const status = req.query.status || null;
    const search = req.query.search || '';

    const whereClauses = [];
    if (role) whereClauses.push(['role', '==', role]);
    if (status) whereClauses.push(['accountStatus', '==', status]);

    const page = await queryCollectionPage({
      collectionName: 'users',
      limit,
      startAfterId,
      orderByField: 'createdAt',
      whereClauses
    });

    const filtered = applySearch(page.items, search, ['name', 'fullName', 'email', 'role']);
    return res.json({items: filtered, nextCursor: page.nextCursor, requestId: req.requestId});
  } catch (err) {
    return res.status(500).json({error: 'users_query_failed', requestId: req.requestId});
  }
});

app.get('/admin/users/:uid', withAdmin, requires('users.read'), async (req, res) => {
  const uid = req.params.uid;
  const userDoc = await db.collection('users').doc(uid).get();
  if (!userDoc.exists) {
    return res.status(404).json({error: 'not_found', requestId: req.requestId});
  }
  return res.json({item: {id: userDoc.id, ...userDoc.data()}, requestId: req.requestId});
});

app.get('/admin/users/:uid/login-activity', withAdmin, requires('users.read'), async (req, res) => {
  try {
    const uid = req.params.uid;
    const limit = parseLimit(req);
    const snap = await db
      .collection('auditLogs')
      .where('targetId', '==', uid)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    const activity = docsToList(snap.docs);
    return res.json({items: activity, requestId: req.requestId});
  } catch (err) {
    return res.status(500).json({error: 'login_activity_failed', requestId: req.requestId});
  }
});

app.get('/admin/trainer-applications', withAdmin, requires('trainers.read'), async (req, res) => {
  try {
    const limit = parseLimit(req);
    const startAfterId = req.query.startAfterId || null;
    const status = req.query.status || null;
    const search = req.query.search || '';

    const whereClauses = [];
    if (status) whereClauses.push(['status', '==', status]);

    const page = await queryCollectionPage({
      collectionName: 'trainerApplications',
      limit,
      startAfterId,
      orderByField: 'submittedAt',
      whereClauses
    });

    const filtered = applySearch(page.items, search, ['name', 'fullName', 'email', 'status']);
    return res.json({items: filtered, nextCursor: page.nextCursor, requestId: req.requestId});
  } catch (err) {
    return res.status(500).json({error: 'trainer_applications_query_failed', requestId: req.requestId});
  }
});

app.get('/admin/trainer-applications/:id', withAdmin, requires('trainers.read'), async (req, res) => {
  const id = req.params.id;
  const doc = await db.collection('trainerApplications').doc(id).get();
  if (!doc.exists) {
    return res.status(404).json({error: 'not_found', requestId: req.requestId});
  }
  return res.json({item: {id: doc.id, ...doc.data()}, requestId: req.requestId});
});

app.get('/admin/bookings', withAdmin, requires('bookings.read'), async (req, res) => {
  try {
    const limit = parseLimit(req);
    const startAfterId = req.query.startAfterId || null;
    const status = req.query.status || null;
    const trainerId = req.query.trainerId || null;
    const search = req.query.search || '';

    const whereClauses = [];
    if (status) whereClauses.push(['status', '==', status]);
    if (trainerId) whereClauses.push(['trainerId', '==', trainerId]);

    const page = await queryCollectionPage({
      collectionName: 'bookings',
      limit,
      startAfterId,
      orderByField: 'scheduledAt',
      whereClauses
    });

    const filtered = applySearch(page.items, search, ['trainerName', 'userName', 'clientName', 'status']);
    return res.json({items: filtered, nextCursor: page.nextCursor, requestId: req.requestId});
  } catch (err) {
    return res.status(500).json({error: 'bookings_query_failed', requestId: req.requestId});
  }
});

app.get('/admin/disputes', withAdmin, requires('reports.read'), async (req, res) => {
  try {
    const limit = parseLimit(req);
    const startAfterId = req.query.startAfterId || null;
    const status = req.query.status || null;

    const whereClauses = [];
    if (status) whereClauses.push(['status', '==', status]);

    const page = await queryCollectionPage({
      collectionName: 'disputes',
      limit,
      startAfterId,
      orderByField: 'createdAt',
      whereClauses
    });

    return res.json({items: page.items, nextCursor: page.nextCursor, requestId: req.requestId});
  } catch (err) {
    return res.status(500).json({error: 'disputes_query_failed', requestId: req.requestId});
  }
});

app.get('/admin/finance/transactions', withAdmin, requires('finance.read'), async (req, res) => {
  try {
    const limit = parseLimit(req);
    const startAfterId = req.query.startAfterId || null;
    const type = req.query.type || null;

    const whereClauses = [];
    if (type) whereClauses.push(['type', '==', type]);

    const page = await queryCollectionPage({
      collectionName: 'transactions',
      limit,
      startAfterId,
      orderByField: 'createdAt',
      whereClauses
    });

    return res.json({items: page.items, nextCursor: page.nextCursor, requestId: req.requestId});
  } catch (err) {
    return res.status(500).json({error: 'transactions_query_failed', requestId: req.requestId});
  }
});

app.get('/admin/finance/revenue-summary', withAdmin, requires('finance.read'), async (req, res) => {
  try {
    const txSnap = await db.collection('transactions').where('type', '==', 'payment').get();
    let totalRevenue = 0;
    let successfulPayments = 0;

    txSnap.docs.forEach((doc) => {
      const data = doc.data();
      const status = normalizeText(data.status);
      if (status === 'success' || status === 'completed' || status === 'paid') {
        successfulPayments += 1;
        totalRevenue += Number(data.amount || 0);
      }
    });

    return res.json({
      summary: {
        totalRevenue,
        successfulPayments,
        transactionCount: txSnap.size
      },
      requestId: req.requestId
    });
  } catch (err) {
    return res.status(500).json({error: 'revenue_summary_failed', requestId: req.requestId});
  }
});

app.get('/admin/refunds', withAdmin, requires('refunds.read'), async (req, res) => {
  try {
    const limit = parseLimit(req);
    const startAfterId = req.query.startAfterId || null;
    const status = req.query.status || null;

    const whereClauses = [];
    if (status) whereClauses.push(['status', '==', status]);

    const page = await queryCollectionPage({
      collectionName: 'refunds',
      limit,
      startAfterId,
      orderByField: 'createdAt',
      whereClauses
    });

    return res.json({items: page.items, nextCursor: page.nextCursor, requestId: req.requestId});
  } catch (err) {
    return res.status(500).json({error: 'refunds_query_failed', requestId: req.requestId});
  }
});

app.get('/admin/payouts', withAdmin, requires('payouts.read'), async (req, res) => {
  try {
    const limit = parseLimit(req);
    const startAfterId = req.query.startAfterId || null;
    const status = req.query.status || null;

    const whereClauses = [];
    if (status) whereClauses.push(['status', '==', status]);

    const page = await queryCollectionPage({
      collectionName: 'payouts',
      limit,
      startAfterId,
      orderByField: 'requestedAt',
      whereClauses
    });

    return res.json({items: page.items, nextCursor: page.nextCursor, requestId: req.requestId});
  } catch (err) {
    return res.status(500).json({error: 'payouts_query_failed', requestId: req.requestId});
  }
});

app.get('/admin/gdpr-requests', withAdmin, requires('gdpr.read'), async (req, res) => {
  try {
    const limit = parseLimit(req);
    const startAfterId = req.query.startAfterId || null;
    const status = req.query.status || null;

    const whereClauses = [];
    if (status) whereClauses.push(['status', '==', status]);

    const page = await queryCollectionPage({
      collectionName: 'gdprRequests',
      limit,
      startAfterId,
      orderByField: 'createdAt',
      whereClauses
    });

    return res.json({items: page.items, nextCursor: page.nextCursor, requestId: req.requestId});
  } catch (err) {
    return res.status(500).json({error: 'gdpr_query_failed', requestId: req.requestId});
  }
});

app.get('/admin/audit-logs', withAdmin, requires('audit.read'), async (req, res) => {
  try {
    const limit = parseLimit(req);
    const startAfterId = req.query.startAfterId || null;
    const actorId = req.query.actorId || null;

    const whereClauses = [];
    if (actorId) whereClauses.push(['actorId', '==', actorId]);

    const page = await queryCollectionPage({
      collectionName: 'auditLogs',
      limit,
      startAfterId,
      orderByField: 'createdAt',
      whereClauses
    });

    return res.json({items: page.items, nextCursor: page.nextCursor, requestId: req.requestId});
  } catch (err) {
    return res.status(500).json({error: 'audit_logs_query_failed', requestId: req.requestId});
  }
});

app.post('/admin/auth/force-logout-user', withAdmin, requires('users.write'), async (req, res) => {
  const uid = req.body.uid;
  if (!uid) {
    return res.status(400).json({error: 'uid_required', requestId: req.requestId});
  }

  await admin.auth().revokeRefreshTokens(uid);
  await db.collection('users').doc(uid).set(
    {
      forceLogoutAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );

  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'auth.force-logout-user',
    targetId: uid,
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, uid, requestId: req.requestId});
});

app.post('/admin/auth/reset-user-password', withAdmin, requires('users.write'), async (req, res) => {
  const uid = req.body.uid;
  if (!uid) {
    return res.status(400).json({error: 'uid_required', requestId: req.requestId});
  }

  const userRecord = await admin.auth().getUser(uid);
  const resetLink = await admin.auth().generatePasswordResetLink(userRecord.email);

  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'auth.reset-user-password',
    targetId: uid,
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, uid, email: userRecord.email, resetLink, requestId: req.requestId});
});

app.patch('/admin/users/:uid', withAdmin, requires('users.write'), async (req, res) => {
  const uid = req.params.uid;
  const ref = db.collection('users').doc(uid);
  const beforeDoc = await ref.get();
  if (!beforeDoc.exists) {
    return res.status(404).json({error: 'not_found', requestId: req.requestId});
  }

  const allowed = ['name', 'fullName', 'email', 'phone', 'role', 'accountStatus'];
  const patch = {};
  allowed.forEach((key) => {
    if (Object.prototype.hasOwnProperty.call(req.body, key)) patch[key] = req.body[key];
  });

  patch.updatedAt = admin.firestore.FieldValue.serverTimestamp();
  patch.updatedBy = req.adminContext.uid;

  await ref.set(patch, {merge: true});
  const afterDoc = await ref.get();

  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'users.patch',
    targetId: uid,
    before: beforeDoc.data(),
    after: afterDoc.data(),
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, item: {id: afterDoc.id, ...afterDoc.data()}, requestId: req.requestId});
});

app.delete('/admin/users/:uid', withAdmin, requires('users.write'), async (req, res) => {
  const uid = req.params.uid;
  const ref = db.collection('users').doc(uid);
  const beforeDoc = await ref.get();
  if (!beforeDoc.exists) {
    return res.status(404).json({error: 'not_found', requestId: req.requestId});
  }

  await ref.set(
    {
      accountStatus: 'deleted',
      deletedAt: admin.firestore.FieldValue.serverTimestamp(),
      deletedBy: req.adminContext.uid,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );

  const afterDoc = await ref.get();
  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'users.delete.soft',
    targetId: uid,
    before: beforeDoc.data(),
    after: afterDoc.data(),
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, uid, requestId: req.requestId});
});

app.post('/admin/trainers/:id/verify-credentials', withAdmin, requires('trainers.write'), async (req, res) => {
  const id = req.params.id;
  const ref = db.collection('users').doc(id);
  await ref.set(
    {
      credentialsVerified: true,
      credentialsVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      credentialsVerifiedBy: req.adminContext.uid,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );

  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'trainers.verify-credentials',
    targetId: id,
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, id, credentialsVerified: true, requestId: req.requestId});
});

app.post('/admin/trainers/:id/suspend', withAdmin, requires('trainers.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('users').doc(id).set(
    {
      accountStatus: 'suspended',
      trainerStatus: 'suspended',
      suspensionReason: req.body.reason || null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );

  return res.json({ok: true, id, status: 'suspended', requestId: req.requestId});
});

app.post('/admin/trainers/:id/ban', withAdmin, requires('trainers.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('users').doc(id).set(
    {
      accountStatus: 'banned',
      trainerStatus: 'banned',
      banReason: req.body.reason || null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'banned', requestId: req.requestId});
});

app.post('/admin/trainers/:id/warn', withAdmin, requires('trainers.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('trainerWarnings').add({
    trainerId: id,
    message: req.body.message || req.body.reason || 'Policy warning issued',
    issuedBy: req.adminContext.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  return res.json({ok: true, id, warned: true, requestId: req.requestId});
});

app.patch('/admin/trainers/:id/badge-level', withAdmin, requires('trainers.write'), async (req, res) => {
  const id = req.params.id;
  const badgeLevel = req.body.badgeLevel || req.body.level;
  if (!badgeLevel) {
    return res.status(400).json({error: 'badge_level_required', requestId: req.requestId});
  }

  await db.collection('users').doc(id).set(
    {
      badgeLevel,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );
  return res.json({ok: true, id, badgeLevel, requestId: req.requestId});
});

app.get('/admin/trainers/:id/performance', withAdmin, requires('trainers.read'), async (req, res) => {
  const id = req.params.id;
  const bookingSnap = await db.collection('bookings').where('trainerId', '==', id).get();
  const bookings = docsToList(bookingSnap.docs);
  const completed = bookings.filter((b) => normalizeText(b.status) === 'completed').length;
  const cancelled = bookings.filter((b) => normalizeText(b.status) === 'cancelled').length;
  const total = bookings.length;

  const ratingSnap = await db.collection('trainerRatings').where('trainerId', '==', id).get();
  const ratings = ratingSnap.docs.map((d) => Number(d.data().rating || 0)).filter((n) => n > 0);
  const averageRating = ratings.length ? ratings.reduce((a, b) => a + b, 0) / ratings.length : 0;

  return res.json({
    trainerId: id,
    metrics: {
      totalBookings: total,
      completedBookings: completed,
      cancelledBookings: cancelled,
      completionRate: total ? completed / total : 0,
      averageRating,
      totalRatings: ratings.length
    },
    requestId: req.requestId
  });
});

app.patch('/admin/bookings/:id', withAdmin, requires('bookings.write'), async (req, res) => {
  const id = req.params.id;
  const ref = db.collection('bookings').doc(id);
  const beforeDoc = await ref.get();
  if (!beforeDoc.exists) {
    return res.status(404).json({error: 'not_found', requestId: req.requestId});
  }

  const allowed = ['status', 'scheduledAt', 'startTime', 'endTime', 'notes'];
  const patch = {};
  allowed.forEach((key) => {
    if (Object.prototype.hasOwnProperty.call(req.body, key)) patch[key] = req.body[key];
  });
  patch.updatedAt = admin.firestore.FieldValue.serverTimestamp();
  patch.updatedBy = req.adminContext.uid;

  await ref.set(patch, {merge: true});
  const afterDoc = await ref.get();

  await writeAuditLog({
    actorId: req.adminContext.uid,
    action: 'bookings.patch',
    targetId: id,
    before: beforeDoc.data(),
    after: afterDoc.data(),
    requestId: req.requestId,
    status: 'success'
  });

  return res.json({ok: true, item: {id: afterDoc.id, ...afterDoc.data()}, requestId: req.requestId});
});

app.post('/admin/bookings/:id/reassign', withAdmin, requires('bookings.write'), async (req, res) => {
  const id = req.params.id;
  const newTrainerId = req.body.newTrainerId || req.body.trainerId;
  if (!newTrainerId) {
    return res.status(400).json({error: 'new_trainer_id_required', requestId: req.requestId});
  }

  const ref = db.collection('bookings').doc(id);
  await ref.set(
    {
      trainerId: newTrainerId,
      reassignedBy: req.adminContext.uid,
      reassignedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );

  return res.json({ok: true, id, trainerId: newTrainerId, requestId: req.requestId});
});

app.post('/admin/disputes/:id/assign', withAdmin, requires('reports.write'), async (req, res) => {
  const id = req.params.id;
  const assigneeId = req.body.assigneeId || req.adminContext.uid;
  await db.collection('disputes').doc(id).set(
    {
      assigneeId,
      assignedAt: admin.firestore.FieldValue.serverTimestamp(),
      assignedBy: req.adminContext.uid,
      status: 'in_review',
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );

  return res.json({ok: true, id, assigneeId, requestId: req.requestId});
});

app.post('/admin/disputes/:id/resolve', withAdmin, requires('reports.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('disputes').doc(id).set(
    {
      status: 'resolved',
      resolution: req.body.resolution || null,
      resolvedBy: req.adminContext.uid,
      resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'resolved', requestId: req.requestId});
});

app.post('/admin/refunds/:id/approve', withAdmin, requires('refunds.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('refunds').doc(id).set(
    {
      status: 'approved',
      approvedBy: req.adminContext.uid,
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'approved', requestId: req.requestId});
});

app.post('/admin/refunds/:id/reject', withAdmin, requires('refunds.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('refunds').doc(id).set(
    {
      status: 'rejected',
      rejectionReason: req.body.reason || null,
      rejectedBy: req.adminContext.uid,
      rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'rejected', requestId: req.requestId});
});

app.post('/admin/refunds/:id/process', withAdmin, requires('refunds.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('refunds').doc(id).set(
    {
      status: 'processed',
      processedBy: req.adminContext.uid,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      processorRef: req.body.processorRef || null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'processed', requestId: req.requestId});
});

app.post('/admin/payouts/:id/approve', withAdmin, requires('payouts.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('payouts').doc(id).set(
    {
      status: 'approved',
      approvedBy: req.adminContext.uid,
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'approved', requestId: req.requestId});
});

app.post('/admin/payouts/:id/reject', withAdmin, requires('payouts.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('payouts').doc(id).set(
    {
      status: 'rejected',
      rejectionReason: req.body.reason || null,
      rejectedBy: req.adminContext.uid,
      rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'rejected', requestId: req.requestId});
});

app.post('/admin/payouts/:id/mark-paid', withAdmin, requires('payouts.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('payouts').doc(id).set(
    {
      status: 'paid',
      paidBy: req.adminContext.uid,
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
      paymentReference: req.body.paymentReference || null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'paid', requestId: req.requestId});
});

app.patch('/admin/commission-rates', withAdmin, requires('finance.write'), async (req, res) => {
  const updates = req.body || {};
  await db.collection('systemConfig').doc('commissionRates').set(
    {
      ...updates,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );
  return res.json({ok: true, requestId: req.requestId});
});

app.get('/admin/subscription-plans', withAdmin, requires('finance.read'), async (req, res) => {
  const snap = await db.collection('subscriptionPlans').orderBy('updatedAt', 'desc').get();
  return res.json({items: docsToList(snap.docs), requestId: req.requestId});
});

app.patch('/admin/subscription-plans/:id', withAdmin, requires('finance.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('subscriptionPlans').doc(id).set(
    {
      ...req.body,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );
  return res.json({ok: true, id, requestId: req.requestId});
});

app.get('/admin/analytics/user-growth', withAdmin, requires('analytics.read'), async (req, res) => {
  const days = Math.max(1, Math.min(Number.parseInt(req.query.days || '30', 10), 120));
  const start = new Date();
  start.setDate(start.getDate() - days + 1);

  const snap = await db.collection('users').where('createdAt', '>=', start).get();
  const byDay = {};
  for (let i = 0; i < days; i += 1) {
    const d = new Date(start);
    d.setDate(start.getDate() + i);
    byDay[d.toISOString().slice(0, 10)] = 0;
  }

  snap.docs.forEach((doc) => {
    const ts = doc.data().createdAt;
    const date = ts && ts.toDate ? ts.toDate() : null;
    if (!date) return;
    const key = date.toISOString().slice(0, 10);
    if (Object.prototype.hasOwnProperty.call(byDay, key)) byDay[key] += 1;
  });

  const series = Object.keys(byDay).sort().map((date) => ({date, count: byDay[date]}));
  return res.json({series, requestId: req.requestId});
});

app.get('/admin/analytics/booking-conversion', withAdmin, requires('analytics.read'), async (req, res) => {
  const snap = await db.collection('bookings').get();
  let completed = 0;
  let cancelled = 0;
  let pending = 0;

  snap.docs.forEach((doc) => {
    const status = normalizeText(doc.data().status);
    if (status === 'completed') completed += 1;
    else if (status === 'cancelled') cancelled += 1;
    else pending += 1;
  });

  const total = snap.size;
  return res.json({
    total,
    completed,
    cancelled,
    pending,
    completionRate: total ? completed / total : 0,
    cancellationRate: total ? cancelled / total : 0,
    requestId: req.requestId
  });
});

app.get('/admin/analytics/popular-trainers', withAdmin, requires('analytics.read'), async (req, res) => {
  const limit = Math.max(1, Math.min(Number.parseInt(req.query.limit || '10', 10), 50));
  const snap = await db.collection('bookings').get();
  const countByTrainer = {};

  snap.docs.forEach((doc) => {
    const data = doc.data();
    const trainerId = data.trainerId;
    if (!trainerId) return;
    countByTrainer[trainerId] = (countByTrainer[trainerId] || 0) + 1;
  });

  const items = Object.keys(countByTrainer)
    .map((trainerId) => ({trainerId, bookingCount: countByTrainer[trainerId]}))
    .sort((a, b) => b.bookingCount - a.bookingCount)
    .slice(0, limit);

  return res.json({items, requestId: req.requestId});
});

app.get('/admin/analytics/peak-usage', withAdmin, requires('analytics.read'), async (req, res) => {
  const snap = await db.collection('bookings').get();
  const byHour = Array.from({length: 24}, (_, idx) => ({hour: idx, count: 0}));

  snap.docs.forEach((doc) => {
    const ts = doc.data().scheduledAt || doc.data().createdAt;
    const date = ts && ts.toDate ? ts.toDate() : null;
    if (!date) return;
    byHour[date.getHours()].count += 1;
  });

  const peak = byHour.reduce((max, item) => (item.count > max.count ? item : max), {hour: 0, count: 0});
  return res.json({byHour, peakHour: peak.hour, peakCount: peak.count, requestId: req.requestId});
});

app.get('/admin/analytics/retention-churn', withAdmin, requires('analytics.read'), async (req, res) => {
  const now = new Date();
  const currentStart = new Date(now);
  currentStart.setDate(now.getDate() - 30);
  const previousStart = new Date(now);
  previousStart.setDate(now.getDate() - 60);

  const currentSnap = await db.collection('bookings').where('createdAt', '>=', currentStart).get();
  const previousSnap = await db.collection('bookings').where('createdAt', '>=', previousStart).where('createdAt', '<', currentStart).get();

  const currentUsers = new Set(currentSnap.docs.map((d) => d.data().userId).filter(Boolean));
  const previousUsers = new Set(previousSnap.docs.map((d) => d.data().userId).filter(Boolean));

  let retained = 0;
  previousUsers.forEach((uid) => {
    if (currentUsers.has(uid)) retained += 1;
  });

  const retentionRate = previousUsers.size ? retained / previousUsers.size : 0;
  const churnRate = 1 - retentionRate;

  return res.json({
    previousPeriodUsers: previousUsers.size,
    currentPeriodUsers: currentUsers.size,
    retainedUsers: retained,
    retentionRate,
    churnRate,
    requestId: req.requestId
  });
});

app.post('/admin/reports/export', withAdmin, requires('analytics.read'), async (req, res) => {
  const format = req.body.format || 'json';
  const exportRef = await db.collection('reportExports').add({
    status: 'ready',
    format,
    requestedBy: req.adminContext.uid,
    requestedAt: admin.firestore.FieldValue.serverTimestamp(),
    filters: req.body.filters || null,
    dataUrl: null
  });

  return res.json({ok: true, exportId: exportRef.id, status: 'ready', requestId: req.requestId});
});

app.get('/admin/coupons', withAdmin, requires('marketing.read'), async (req, res) => {
  const snap = await db.collection('coupons').orderBy('updatedAt', 'desc').get();
  return res.json({items: docsToList(snap.docs), requestId: req.requestId});
});

app.post('/admin/coupons', withAdmin, requires('marketing.write'), async (req, res) => {
  const code = (req.body.code || '').toString().trim().toUpperCase();
  if (!code) {
    return res.status(400).json({error: 'code_required', requestId: req.requestId});
  }

  await db.collection('coupons').doc(code).set({
    ...req.body,
    code,
    active: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: req.adminContext.uid,
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  }, {merge: true});

  return res.status(201).json({ok: true, code, requestId: req.requestId});
});

app.patch('/admin/coupons/:code', withAdmin, requires('marketing.write'), async (req, res) => {
  const code = req.params.code.toUpperCase();
  await db.collection('coupons').doc(code).set(
    {
      ...req.body,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );
  return res.json({ok: true, code, requestId: req.requestId});
});

app.post('/admin/coupons/:code/disable', withAdmin, requires('marketing.write'), async (req, res) => {
  const code = req.params.code.toUpperCase();
  await db.collection('coupons').doc(code).set(
    {
      active: false,
      disabledBy: req.adminContext.uid,
      disabledAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, code, active: false, requestId: req.requestId});
});

app.get('/admin/campaigns', withAdmin, requires('marketing.read'), async (req, res) => {
  const snap = await db.collection('campaigns').orderBy('updatedAt', 'desc').get();
  return res.json({items: docsToList(snap.docs), requestId: req.requestId});
});

app.post('/admin/campaigns', withAdmin, requires('marketing.write'), async (req, res) => {
  const ref = await db.collection('campaigns').add({
    ...req.body,
    status: req.body.status || 'draft',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: req.adminContext.uid,
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });
  return res.status(201).json({ok: true, id: ref.id, requestId: req.requestId});
});

app.patch('/admin/campaigns/:id', withAdmin, requires('marketing.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('campaigns').doc(id).set(
    {
      ...req.body,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );
  return res.json({ok: true, id, requestId: req.requestId});
});

app.post('/admin/campaigns/:id/send', withAdmin, requires('marketing.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('campaigns').doc(id).set(
    {
      status: 'sent',
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      sentBy: req.adminContext.uid,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'sent', requestId: req.requestId});
});

app.get('/admin/campaigns/:id/performance', withAdmin, requires('marketing.read'), async (req, res) => {
  const id = req.params.id;
  const doc = await db.collection('campaigns').doc(id).get();
  if (!doc.exists) {
    return res.status(404).json({error: 'not_found', requestId: req.requestId});
  }

  const data = doc.data();
  const performance = {
    delivered: Number(data.delivered || 0),
    opened: Number(data.opened || 0),
    clicked: Number(data.clicked || 0),
    converted: Number(data.converted || 0)
  };
  return res.json({campaignId: id, performance, requestId: req.requestId});
});

app.get('/admin/challenges', withAdmin, requires('content.read'), async (req, res) => {
  const snap = await db.collection('challenges').orderBy('updatedAt', 'desc').get();
  return res.json({items: docsToList(snap.docs), requestId: req.requestId});
});

app.post('/admin/challenges', withAdmin, requires('content.write'), async (req, res) => {
  const ref = await db.collection('challenges').add({
    ...req.body,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: req.adminContext.uid,
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });
  return res.status(201).json({ok: true, id: ref.id, requestId: req.requestId});
});

app.patch('/admin/challenges/:id', withAdmin, requires('content.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('challenges').doc(id).set(
    {
      ...req.body,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );
  return res.json({ok: true, id, requestId: req.requestId});
});

app.delete('/admin/challenges/:id', withAdmin, requires('content.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('challenges').doc(id).delete();
  return res.json({ok: true, id, requestId: req.requestId});
});

app.get('/admin/content-library', withAdmin, requires('content.read'), async (req, res) => {
  const snap = await db.collection('contentLibrary').orderBy('updatedAt', 'desc').get();
  return res.json({items: docsToList(snap.docs), requestId: req.requestId});
});

app.post('/admin/content-library', withAdmin, requires('content.write'), async (req, res) => {
  const ref = await db.collection('contentLibrary').add({
    ...req.body,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: req.adminContext.uid,
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });
  return res.status(201).json({ok: true, id: ref.id, requestId: req.requestId});
});

app.patch('/admin/content-library/:id', withAdmin, requires('content.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('contentLibrary').doc(id).set(
    {
      ...req.body,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );
  return res.json({ok: true, id, requestId: req.requestId});
});

app.delete('/admin/content-library/:id', withAdmin, requires('content.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('contentLibrary').doc(id).delete();
  return res.json({ok: true, id, requestId: req.requestId});
});

app.get('/admin/community/reports', withAdmin, requires('community.read'), async (req, res) => {
  const snap = await db.collection('communityReports').orderBy('createdAt', 'desc').limit(parseLimit(req)).get();
  return res.json({items: docsToList(snap.docs), requestId: req.requestId});
});

app.post('/admin/community/reports/:id/action', withAdmin, requires('community.write'), async (req, res) => {
  const id = req.params.id;
  const action = req.body.action || 'reviewed';
  await db.collection('communityReports').doc(id).set(
    {
      moderationAction: action,
      moderationNotes: req.body.notes || null,
      moderatedBy: req.adminContext.uid,
      moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
      status: req.body.status || 'actioned',
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, action, requestId: req.requestId});
});

app.patch('/admin/roles-permissions', withAdmin, requires('system.write'), async (req, res) => {
  const updates = req.body || {};
  Object.keys(updates).forEach((role) => {
    const permissions = Array.isArray(updates[role]) ? updates[role] : null;
    if (permissions) {
      rolePermissions[role] = permissions;
    }
  });

  await db.collection('systemConfig').doc('rolePermissions').set(
    {
      rolePermissions,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );

  return res.json({ok: true, rolePermissions, requestId: req.requestId});
});

app.post('/admin/system/backup', withAdmin, requires('system.write'), async (req, res) => {
  const collections = [
    'users',
    'trainerApplications',
    'bookings',
    'disputes',
    'transactions',
    'refunds',
    'payouts',
    'gdprRequests'
  ];

  const counts = {};
  await Promise.all(
    collections.map(async (name) => {
      const snap = await db.collection(name).get();
      counts[name] = snap.size;
    })
  );

  const ref = await db.collection('systemBackups').add({
    type: req.body.type || 'logical-manifest',
    requestedBy: req.adminContext.uid,
    requestedAt: admin.firestore.FieldValue.serverTimestamp(),
    status: 'completed',
    counts
  });

  return res.json({ok: true, backupId: ref.id, counts, requestId: req.requestId});
});

app.post('/admin/system/restore', withAdmin, requires('system.write'), async (req, res) => {
  const ref = await db.collection('systemRestoreRequests').add({
    backupId: req.body.backupId || null,
    requestedBy: req.adminContext.uid,
    requestedAt: admin.firestore.FieldValue.serverTimestamp(),
    status: 'queued'
  });
  return res.json({ok: true, restoreRequestId: ref.id, status: 'queued', requestId: req.requestId});
});

app.patch('/admin/system/settings', withAdmin, requires('system.write'), async (req, res) => {
  await db.collection('systemConfig').doc('settings').set(
    {
      ...req.body,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: req.adminContext.uid
    },
    {merge: true}
  );
  return res.json({ok: true, requestId: req.requestId});
});

app.post('/admin/gdpr-requests/:id/verify-identity', withAdmin, requires('gdpr.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('gdprRequests').doc(id).set(
    {
      identityVerified: true,
      identityVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      identityVerifiedBy: req.adminContext.uid,
      status: 'identity_verified',
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'identity_verified', requestId: req.requestId});
});

app.post('/admin/gdpr-requests/:id/complete', withAdmin, requires('gdpr.write'), async (req, res) => {
  const id = req.params.id;
  await db.collection('gdprRequests').doc(id).set(
    {
      status: 'completed',
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
      completedBy: req.adminContext.uid,
      completionNotes: req.body.notes || null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    {merge: true}
  );
  return res.json({ok: true, id, status: 'completed', requestId: req.requestId});
});

const clientApp = express();
clientApp.use(cors({origin: true}));
clientApp.use(express.json());

async function withUser(req, res, next) {
  try {
    const authHeader = req.get('authorization') || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
    if (!token) {
      return res.status(401).json({error: 'missing_token'});
    }

    const decoded = await admin.auth().verifyIdToken(token, true);
    req.userContext = {
      uid: decoded.uid,
      role: decoded.role || 'user'
    };
    return next();
  } catch (err) {
    return res.status(401).json({error: 'invalid_session'});
  }
}

function canEditTrainerProfile(ctx, trainerId) {
  if (!ctx || !ctx.uid) return false;
  if (ctx.uid === trainerId) return true;
  return ctx.role === 'admin' || ctx.role === 'super_admin';
}

clientApp.get('/v1/health', (_req, res) => {
  return res.json({ok: true, service: 'client-api', timestamp: Date.now()});
});

clientApp.get('/v1/trainers/:id/profile', async (req, res) => {
  try {
    const trainerId = req.params.id;
    const [userDoc, profileDoc] = await Promise.all([
      db.collection('users').doc(trainerId).get(),
      db.collection('trainerProfiles').doc(trainerId).get()
    ]);

    if (!userDoc.exists && !profileDoc.exists) {
      return res.status(404).json({error: 'not_found'});
    }

    const user = userDoc.exists ? userDoc.data() : {};
    const profile = profileDoc.exists ? profileDoc.data() : {};

    return res.json({
      id: trainerId,
      name: user.name || user.fullName || 'Trainer',
      email: user.email || '',
      photoUrl: profile.photoUrl || user.photoUrl || '',
      bio: profile.bio || '',
      sessionPrice: Number(profile.sessionPrice || 0),
      specializations: Array.isArray(profile.specializations) ? profile.specializations : [],
      languages: Array.isArray(profile.languages) ? profile.languages : [],
      sessionLocations: Array.isArray(profile.sessionLocations) ? profile.sessionLocations : [],
      availability: profile.availability || {}
    });
  } catch (err) {
    return res.status(500).json({error: 'trainer_profile_fetch_failed'});
  }
});

clientApp.patch('/v1/trainers/:id/profile', withUser, async (req, res) => {
  try {
    const trainerId = req.params.id;
    if (!canEditTrainerProfile(req.userContext, trainerId)) {
      return res.status(403).json({error: 'forbidden'});
    }

    const allowed = ['bio', 'sessionPrice', 'specializations', 'languages', 'sessionLocations', 'availability', 'photoUrl'];
    const patch = {};
    allowed.forEach((key) => {
      if (Object.prototype.hasOwnProperty.call(req.body, key)) {
        patch[key] = req.body[key];
      }
    });

    patch.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    patch.updatedBy = req.userContext.uid;

    await db.collection('trainerProfiles').doc(trainerId).set(patch, {merge: true});
    const afterDoc = await db.collection('trainerProfiles').doc(trainerId).get();

    return res.json({ok: true, id: trainerId, profile: afterDoc.data() || {}});
  } catch (err) {
    return res.status(500).json({error: 'trainer_profile_update_failed'});
  }
});

clientApp.get('/v1/trainers/:id/reviews', async (req, res) => {
  try {
    const trainerId = req.params.id;
    const limit = parseLimit(req);
    const snap = await db
      .collection('reviews')
      .where('trainerId', '==', trainerId)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    const items = docsToList(snap.docs).map((item) => ({
      id: item.id,
      rating: Number(item.rating || 0),
      comment: item.comment || '',
      reviewerId: item.userId || item.reviewerId || item.clientId || '',
      reviewerName: item.userName || item.reviewerName || item.clientName || 'User',
      reviewerPhotoUrl: item.userPhotoUrl || item.reviewerPhotoUrl || item.clientPhotoUrl || '',
      createdAt: item.createdAt || null
    }));

    const ratings = items.map((i) => i.rating).filter((n) => Number.isFinite(n) && n > 0);
    const avgRating = ratings.length ? ratings.reduce((a, b) => a + b, 0) / ratings.length : 0;

    return res.json({
      trainerId,
      totalReviews: items.length,
      avgRating,
      items
    });
  } catch (err) {
    return res.status(500).json({error: 'trainer_reviews_fetch_failed'});
  }
});

function toTimestampOrNull(value) {
  if (!value) return null;
  if (value && typeof value.toDate === 'function') return value;
  if (value instanceof Date) return admin.firestore.Timestamp.fromDate(value);
  if (typeof value === 'string' || typeof value === 'number') {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) {
      return admin.firestore.Timestamp.fromDate(parsed);
    }
  }
  return null;
}

async function isBookingOwnerOrTrainer(ctx, bookingId) {
  const doc = await db.collection('bookings').doc(bookingId).get();
  if (!doc.exists) return {allowed: false, item: null};
  const item = {id: doc.id, ...doc.data()};
  const userId = (item.userId || item.clientId || '').toString();
  const trainerId = (item.trainerId || '').toString();
  const allowed =
    ctx.uid === userId ||
    ctx.uid === trainerId ||
    ctx.role === 'admin' ||
    ctx.role === 'super_admin';
  return {allowed, item};
}

clientApp.post('/v1/bookings', withUser, async (req, res) => {
  try {
    const requestId = traceId(req);
    const idempotencyKey = (req.get('x-idempotency-key') || '').trim();
    if (!idempotencyKey) {
      return res.status(400).json({
        error: 'idempotency_key_required',
        message: 'Provide x-idempotency-key for booking creation.',
        requestId
      });
    }

    const trainerId = (req.body.trainerId || '').toString().trim();
    if (!trainerId) {
      return res.status(400).json({
        error: 'trainer_id_required',
        message: 'trainerId is required.',
        requestId
      });
    }

    const dedupeId = `${req.userContext.uid}:${idempotencyKey}`;
    const dedupeRef = db.collection('clientRequestKeys').doc(dedupeId);
    const dedupeDoc = await dedupeRef.get();
    if (dedupeDoc.exists) {
      const existing = dedupeDoc.data() || {};
      return res.status(200).json({
        ok: true,
        id: existing.bookingId || null,
        deduped: true,
        requestId
      });
    }

    const scheduledAt =
      toTimestampOrNull(req.body.scheduledAt || req.body.sessionAt || req.body.dateTime) ||
      admin.firestore.Timestamp.now();

    const payload = {
      userId: req.userContext.uid,
      trainerId,
      status: 'pending',
      amount: Number(req.body.amount || req.body.price || 0),
      notes: req.body.notes || '',
      startTime: req.body.startTime || '',
      endTime: req.body.endTime || '',
      scheduledAt,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: req.userContext.uid,
      source: 'clientApi'
    };

    const ref = await db.collection('bookings').add(payload);
    await dedupeRef.set({
      uid: req.userContext.uid,
      bookingId: ref.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    const createdDoc = await ref.get();
    return res.status(201).json({
      ok: true,
      id: ref.id,
      item: {id: createdDoc.id, ...createdDoc.data()},
      requestId
    });
  } catch (err) {
    return res.status(500).json({
      error: 'booking_create_failed',
      message: 'Failed to create booking.',
      requestId: traceId(req)
    });
  }
});

clientApp.get('/v1/bookings/mine', withUser, async (req, res) => {
  try {
    const requestId = traceId(req);
    const limit = parseLimit(req);
    const status = (req.query.status || '').toString().trim();

    let query = db.collection('bookings').where('userId', '==', req.userContext.uid);
    if (status) {
      query = query.where('status', '==', status);
    }
    const snap = await query.orderBy('scheduledAt', 'desc').limit(limit).get();

    return res.json({
      items: docsToList(snap.docs),
      requestId
    });
  } catch (err) {
    return res.status(500).json({
      error: 'my_bookings_fetch_failed',
      message: 'Failed to load your bookings.',
      requestId: traceId(req)
    });
  }
});

clientApp.get('/v1/trainers/:id/bookings', withUser, async (req, res) => {
  try {
    const requestId = traceId(req);
    const trainerId = req.params.id;
    if (!canEditTrainerProfile(req.userContext, trainerId)) {
      return res.status(403).json({
        error: 'forbidden',
        message: 'You cannot access this trainer booking list.',
        requestId
      });
    }

    const limit = parseLimit(req);
    const status = (req.query.status || '').toString().trim();
    let query = db.collection('bookings').where('trainerId', '==', trainerId);
    if (status) {
      query = query.where('status', '==', status);
    }
    const snap = await query.orderBy('scheduledAt', 'desc').limit(limit).get();

    return res.json({items: docsToList(snap.docs), requestId});
  } catch (err) {
    return res.status(500).json({
      error: 'trainer_bookings_fetch_failed',
      message: 'Failed to load trainer bookings.',
      requestId: traceId(req)
    });
  }
});

clientApp.post('/v1/bookings/:id/cancel', withUser, async (req, res) => {
  try {
    const requestId = traceId(req);
    const bookingId = req.params.id;
    const permission = await isBookingOwnerOrTrainer(req.userContext, bookingId);
    if (!permission.item) {
      return res.status(404).json({
        error: 'not_found',
        message: 'Booking not found.',
        requestId
      });
    }
    if (!permission.allowed) {
      return res.status(403).json({
        error: 'forbidden',
        message: 'You cannot cancel this booking.',
        requestId
      });
    }

    await db.collection('bookings').doc(bookingId).set(
      {
        status: 'cancelled',
        cancelReason: req.body.reason || null,
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        cancelledBy: req.userContext.uid,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: req.userContext.uid
      },
      {merge: true}
    );

    const afterDoc = await db.collection('bookings').doc(bookingId).get();
    return res.json({
      ok: true,
      id: bookingId,
      item: {id: afterDoc.id, ...afterDoc.data()},
      requestId
    });
  } catch (err) {
    return res.status(500).json({
      error: 'booking_cancel_failed',
      message: 'Failed to cancel booking.',
      requestId: traceId(req)
    });
  }
});

exports.adminApi = onRequest({region: 'us-central1'}, app);
exports.clientApi = onRequest({region: 'us-central1'}, clientApp);
