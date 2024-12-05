const {onRequest} = require("firebase-functions/v2/https"); // v2에서 onRequest import
const admin = require("firebase-admin");

const serviceAccount = require("./test-d4ee5-firebase-adminsdk-ens7s-989f70ba1b.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

exports.createCustomToken = onRequest(async (request, response) => {
  const user = request.body;

  const uid = `kakao:${user.uid}`;
  const updateParams = {
    email: user.email,
    photoURL: user.photoURL,
    displayName: user.displayName,
  };

  try {
    await admin.auth().updateUser(uid, updateParams);
  } catch (e) {
    updateParams["uid"] = uid;
    await admin.auth().createUser(updateParams);
  }

  // 수정된 부분: createCustomToken에서 uid만 아니라 필요한 데이터도 전달
  const token = await admin.auth().createCustomToken(uid, {
    email: user.email,
    displayName: user.displayName,
    photoURL: user.photoURL,
  });

  response.send({token});
});
