# Cloud Function: onOrderCreated

This Cloud Function updates product stock and writes inventory logs whenever a new order document is created in Firestore under `orders/{orderId}`.

Why use this?
- Keeps product stock updates and inventory logging in a trusted server environment.
- Avoids giving client apps write access to `products` or `inventory_logs` collections.
- Ensures transactional stock validation and prevents race conditions.

Files
- `index.js` - Cloud Function source
- `package.json` - Node package manifest

Deploy steps
1. Install Firebase CLI and log in:

```bash
npm install -g firebase-tools
firebase login
```

2. Initialize functions in this repository (if not done already):

```bash
cd functions
firebase init functions
# Choose JavaScript, do not overwrite index.js if prompted (you can merge)
```

3. Install dependencies and deploy:

```bash
cd functions
npm install
firebase deploy --only functions:onOrderCreated
```

Firestore rules note
- Keep your `products` collection write-protected to admin only. The Cloud Function uses the Admin SDK and therefore can update product stock even when client rules block it.
- Example rule (snippet) to keep client updates blocked for products and inventory_logs:

```
match /products/{productId} {
  allow read: if true;
  allow create, update, delete: if request.auth != null && request.auth.token.admin == true; // admin-only
}

match /inventory_logs/{logId} {
  allow read: if request.auth != null && request.auth.token.admin == true;
  allow write: if false; // block client writes
}
```

Notes
- The Function marks the order document with `stockUpdateStatus: 'failed'` and `stockUpdateError` on failure so you can surface issues to admins.
- You may want to restrict stock decrements to only when order status transitions to confirmed/paid depending on business logic.

If you want, I can:
- Add a small admin UI to re-run failed stock updates,
- Add TypeScript support and more robust retries for the function,
- Provide the exact Firestore rules to paste into your console.


