export function audit(db, adminId, action, target, summary, before = null, after = null, createdAt = Date.now()) {
    db.prepare('INSERT INTO admin_audit(admin_id,action,target_user_id,created_at,summary,before_state,after_state) VALUES(?,?,?,?,?,?,?)')
        .run(adminId, action, target, createdAt, summary, JSON.stringify(before), JSON.stringify(after));
}
export function adminError(message, statusCode = 422) { throw Object.assign(new Error(message), { statusCode }); }
