const crypto = require("crypto");
const dotenv = require('dotenv');
dotenv.config();

const aesKey = crypto.randomBytes(32);
const iv = crypto.randomBytes(16);

console.log("AESKEY:", aesKey.toString("hex"));
console.log("IVKEY:", iv.toString("hex"));

const plaintext = 'mydbpassword';

const cipher = crypto.createCipheriv("aes-256-cbc", aesKey, iv);
let encrypted = cipher.update(plaintext, "utf8", "base64");
encrypted += cipher.final("base64");

console.log("DBPASS:", encrypted);

const decipher = crypto.createDecipheriv("aes-256-cbc", aesKey, iv);
let decrypted = decipher.update(encrypted, "base64", "utf8");
decrypted += decipher.final("utf8");

console.log("Decrypted:", decrypted);
