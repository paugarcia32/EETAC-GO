import { sign, verify } from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "token.01010101";

//A partir del mail y rol generamos y firmamos el token
const generateToken = (email: string, role: string) => {
  const jwt = sign({ email, role }, JWT_SECRET, {
    expiresIn: "2h",
  });
  return jwt;
};

const generateTokenCompleted = (idUser: string, name: string, surname: string, username: string, role:string, level:Number, imageURL:string, experience:Number) => {
  const jwt = sign({ idUser, name, surname, username, role, level, imageURL, experience }, JWT_SECRET, {
    expiresIn: "2h",
  });
  return jwt;
};

//Verificamos la firma del token que nos llega como parametro
const verifyToken = (jwt: string) => {
  try {
    const isOk = verify(jwt, JWT_SECRET); //verificamos 
    return isOk;
  } catch(err) {
    return null;
  }
};

export { generateToken, verifyToken, generateTokenCompleted };