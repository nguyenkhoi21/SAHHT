import { argon2, randomBytes, timingSafeEqual } from 'node:crypto';
const parameters = { parallelism: 1, tagLength: 32, memory: 65536, passes: 3 };
function derive(password, salt) {
    return new Promise((resolve, reject) => argon2('argon2id', { ...parameters, message: password, nonce: salt }, (error, key) => error ? reject(error) : resolve(key)));
}
export async function hashPassword(password) {
    const salt = randomBytes(16);
    const key = await derive(password, salt);
    return `$argon2id$v=19$m=65536,t=3,p=1$${salt.toString('base64').replace(/=+$/, '')}$${key.toString('base64').replace(/=+$/, '')}`;
}
export async function verifyPassword(password, encoded) {
    const match = /^\$argon2id\$v=19\$m=65536,t=3,p=1\$([A-Za-z0-9+/]{22})\$([A-Za-z0-9+/]{43})$/.exec(encoded);
    if (!match)
        return false;
    const expected = Buffer.from(match[2], 'base64');
    const actual = await derive(password, Buffer.from(match[1], 'base64'));
    return expected.length === actual.length && timingSafeEqual(expected, actual);
}
