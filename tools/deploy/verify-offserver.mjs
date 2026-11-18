// Secret chỉ nhận stdin từ bộ giải mã DPAPI; không argv/log/file plaintext.
import {dryRunArchive} from '../../server/dist/system/backup.js';
let raw='';for await(const b of process.stdin)raw+=b;
const result=await dryRunArchive(process.argv[2],raw.trim(),process.argv[3],23);
raw='';console.log(JSON.stringify({offserverRestoreVerified:true,...result}));
